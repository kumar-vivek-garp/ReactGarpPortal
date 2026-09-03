/**
 * Localhost-only Salesforce CLI token proxy.
 *
 * Binds 127.0.0.1 only. Never deploy this to Experience / production.
 * Usage: npm run local-sf  (from repo root)
 *
 * Which org it proxies follows the Salesforce CLI's own precedence:
 *   1. SF_TARGET_ORG env var: explicit override for this process only
 *   2. the CLI default org (`sf config get target-org`): the project-local
 *      .sf/config.json when set, otherwise the global ~/.sf/config.json
 * Resolved once at startup. After `sf config set target-org <alias>`,
 * restart the gateway to pick the new org up.
 *
 * Forwards browser header `X-GARP-Dev-Contact` (Contact Id) to Salesforce so
 * GARP_Portal_Core.currentContact() can override DEV_FALLBACK_CONTACT for
 * Standard (internal) sessions. See doc/local-dev-contact-picker.md.
 */
import { spawnSync } from "node:child_process"
import http from "node:http"
import { fileURLToPath, URL } from "node:url"

const HOST = "127.0.0.1"
const PORT = Number(process.env.LOCAL_SF_PORT || 8787)
/** Same variable the Salesforce CLI itself honours as a target-org override. */
const TARGET_ORG_OVERRIDE = process.env.SF_TARGET_ORG || ""
/** Run `sf` from the repo root so the project-local .sf/config.json is found. */
const REPO_ROOT = fileURLToPath(new URL("../../", import.meta.url))

const SET_DEFAULT_HINT =
	"Run: sf config set target-org <alias>  (or start with SF_TARGET_ORG=<alias>)"

/** @type {{ alias: string, source: string } | null} */
let resolvedTargetOrg = null

/** @type {{ accessToken: string, instanceUrl: string, username?: string, orgId?: string, fetchedAt: number } | null} */
let cachedAuth = null

/**
 * Run an `sf` command with `--json` and return the parsed envelope.
 * Throws on spawn failure, empty or non-JSON output, or a non-zero CLI status.
 * @param {string[]} args
 * @param {{ env?: Record<string, string> }} [options]
 */
function runSfJson(args, { env = {} } = {}) {
	const label = `sf ${args.join(" ")}`
	const result = spawnSync("sf", [...args, "--json"], {
		cwd: REPO_ROOT,
		encoding: "utf8",
		env: { ...process.env, ...env },
		shell: process.platform === "win32",
	})

	if (result.error) {
		throw new Error(`Failed to run sf CLI: ${result.error.message}`)
	}

	const stdout = (result.stdout || "").trim()
	if (!stdout) {
		throw new Error(
			`${label} returned no output (exit ${result.status}). stderr: ${result.stderr || ""}`,
		)
	}

	let parsed
	try {
		parsed = JSON.parse(stdout)
	} catch {
		throw new Error(`${label} did not return JSON: ${stdout.slice(0, 200)}`)
	}

	if (parsed.status !== 0) {
		const msg =
			parsed.message ||
			parsed.warnings?.join("; ") ||
			JSON.stringify(parsed)
		throw new Error(`${label} failed: ${msg}`)
	}

	return parsed
}

/**
 * The org this process proxies to. See the file header for precedence.
 * Cached for the life of the process, like the CLI token.
 * @returns {{ alias: string, source: string }}
 */
function getTargetOrg() {
	if (resolvedTargetOrg) return resolvedTargetOrg

	if (TARGET_ORG_OVERRIDE) {
		resolvedTargetOrg = {
			alias: TARGET_ORG_OVERRIDE,
			source: "SF_TARGET_ORG env",
		}
		return resolvedTargetOrg
	}

	const parsed = runSfJson(["config", "get", "target-org"])
	const entries = Array.isArray(parsed.result) ? parsed.result : []
	const entry =
		entries.find((e) => e?.key === "target-org" || e?.name === "target-org") ??
		entries[0]
	const alias = typeof entry?.value === "string" ? entry.value.trim() : ""
	if (!alias) {
		throw new Error(`No default org is set. ${SET_DEFAULT_HINT}`)
	}

	resolvedTargetOrg = {
		alias,
		source: `CLI default, ${String(entry.location ?? "config").toLowerCase()} config`,
	}
	return resolvedTargetOrg
}

/** What to tell the user when the CLI side is not ready. */
function recoveryHint() {
	try {
		return `Run: sf org login web --alias ${getTargetOrg().alias}`
	} catch {
		return SET_DEFAULT_HINT
	}
}

function readCliAuth() {
	const { alias } = getTargetOrg()
	const parsed = runSfJson(["org", "display", "--target-org", alias], {
		env: { SF_TEMP_SHOW_SECRETS: "true" },
	})

	const accessToken = parsed.result?.accessToken
	const instanceUrl = parsed.result?.instanceUrl
	if (!accessToken || !instanceUrl) {
		throw new Error(
			`sf org display missing accessToken/instanceUrl. Run: sf org login web --alias ${alias}`,
		)
	}

	cachedAuth = {
		accessToken,
		instanceUrl: String(instanceUrl).replace(/\/+$/, ""),
		username: parsed.result?.username,
		orgId: parsed.result?.id,
		fetchedAt: Date.now(),
	}
	return cachedAuth
}

function getAuth({ force = false } = {}) {
	// Refresh at least every 90 minutes as a safety net.
	const stale =
		!cachedAuth || Date.now() - cachedAuth.fetchedAt > 90 * 60 * 1000
	if (force || stale) {
		return readCliAuth()
	}
	return cachedAuth
}

function sendJson(res, status, body) {
	const payload = JSON.stringify(body)
	res.writeHead(status, {
		"Content-Type": "application/json; charset=utf-8",
		"Content-Length": Buffer.byteLength(payload),
		"Cache-Control": "no-store",
	})
	res.end(payload)
}

/**
 * @param {import('node:http').IncomingMessage} req
 * @param {import('node:http').ServerResponse} res
 * @param {string} upstreamPath pathname + search on the Salesforce instance
 */
async function proxyToSalesforce(req, res, upstreamPath) {
	let auth = getAuth()

	// Buffer once so a 401 → token refresh retry can resend the body (e.g. GraphQL POST).
	const chunks = []
	for await (const chunk of req) {
		chunks.push(chunk)
	}
	const body =
		chunks.length && req.method !== "GET" && req.method !== "HEAD"
			? Buffer.concat(chunks)
			: undefined

	const tryOnce = async (token) => {
		const target = new URL(upstreamPath, auth.instanceUrl)
		const headers = { ...(req.headers || {}) }
		delete headers.host
		delete headers.connection
		delete headers["content-length"]
		delete headers.cookie
		delete headers.authorization
		headers.authorization = `Bearer ${token}`
		headers.host = new URL(auth.instanceUrl).host

		return fetch(target, {
			method: req.method || "GET",
			headers,
			body,
			redirect: "manual",
		})
	}

	let upstream = await tryOnce(auth.accessToken)
	if (upstream.status === 401) {
		auth = getAuth({ force: true })
		upstream = await tryOnce(auth.accessToken)
	}

	// Node fetch decompresses the body; strip encoding headers so browsers
	// don't try to gunzip already-plain bytes (ERR_CONTENT_DECODING_FAILED).
	const skipHeaders = new Set([
		"transfer-encoding",
		"content-encoding",
		"content-length",
		"connection",
	])
	const outHeaders = {}
	upstream.headers.forEach((value, key) => {
		if (skipHeaders.has(key)) return
		outHeaders[key] = value
	})
	const buf = Buffer.from(await upstream.arrayBuffer())
	outHeaders["content-length"] = String(buf.length)
	res.writeHead(upstream.status, outHeaders)
	res.end(buf)
}

const server = http.createServer(async (req, res) => {
	try {
		const url = new URL(req.url || "/", `http://${HOST}:${PORT}`)

		if (req.method === "GET" && url.pathname === "/health") {
			try {
				const target = getTargetOrg()
				const auth = getAuth()
				return sendJson(res, 200, {
					ok: true,
					username: auth.username ?? null,
					orgId: auth.orgId ?? null,
					targetOrg: target.alias,
					targetOrgSource: target.source,
					instanceUrl: auth.instanceUrl,
				})
			} catch (error) {
				return sendJson(res, 503, {
					ok: false,
					error: error instanceof Error ? error.message : String(error),
					hint: recoveryHint(),
				})
			}
		}

		// Proxy Salesforce REST / GraphQL under /services/*
		if (url.pathname.startsWith("/services/")) {
			const upstreamPath = `${url.pathname}${url.search}`
			return await proxyToSalesforce(req, res, upstreamPath)
		}

		// Profile photos / Attachments (Contact.Photo_URL__c FileDownload paths)
		if (url.pathname.startsWith("/servlet/")) {
			const upstreamPath = `${url.pathname}${url.search}`
			return await proxyToSalesforce(req, res, upstreamPath)
		}

		sendJson(res, 404, {
			ok: false,
			error: `Unknown path: ${url.pathname}`,
		})
	} catch (error) {
		sendJson(res, 500, {
			ok: false,
			error: error instanceof Error ? error.message : String(error),
		})
	}
})

server.listen(PORT, HOST, () => {
	console.log(`[local-sf] listening on http://${HOST}:${PORT}`)
	console.log(`[local-sf] health: http://${HOST}:${PORT}/health`)
	try {
		const { alias, source } = getTargetOrg()
		console.log(`[local-sf] target org: ${alias} (${source})`)
		const auth = getAuth()
		console.log(`[local-sf] authenticated as ${auth.username}`)
	} catch (error) {
		console.warn(
			`[local-sf] CLI not ready yet: ${error instanceof Error ? error.message : error}`,
		)
		console.warn(`[local-sf] ${recoveryHint()}`)
	}
})
