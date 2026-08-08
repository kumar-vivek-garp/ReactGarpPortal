/**
 * Localhost-only Salesforce CLI token proxy.
 *
 * Binds 127.0.0.1 only. Never deploy this to Experience / production.
 * Usage: npm run local-sf  (from repo root)
 */
import { spawnSync } from "node:child_process"
import http from "node:http"
import { URL } from "node:url"

const HOST = "127.0.0.1"
const PORT = Number(process.env.LOCAL_SF_PORT || 8787)
const TARGET_ORG = process.env.SF_TARGET_ORG || "devjuly25a"

/** @type {{ accessToken: string, instanceUrl: string, username?: string, orgId?: string, fetchedAt: number } | null} */
let cachedAuth = null

function readCliAuth() {
	const env = {
		...process.env,
		SF_TEMP_SHOW_SECRETS: "true",
	}
	const result = spawnSync(
		"sf",
		["org", "display", "--target-org", TARGET_ORG, "--json"],
		{
			encoding: "utf8",
			env,
			shell: process.platform === "win32",
		},
	)

	if (result.error) {
		throw new Error(`Failed to run sf CLI: ${result.error.message}`)
	}

	const stdout = (result.stdout || "").trim()
	if (!stdout) {
		throw new Error(
			`sf org display returned no output (exit ${result.status}). stderr: ${result.stderr || ""}`,
		)
	}

	let parsed
	try {
		parsed = JSON.parse(stdout)
	} catch {
		throw new Error(`sf org display did not return JSON: ${stdout.slice(0, 200)}`)
	}

	if (parsed.status !== 0) {
		const msg =
			parsed.message ||
			parsed.warnings?.join("; ") ||
			JSON.stringify(parsed)
		throw new Error(`sf org display failed: ${msg}`)
	}

	const accessToken = parsed.result?.accessToken
	const instanceUrl = parsed.result?.instanceUrl
	if (!accessToken || !instanceUrl) {
		throw new Error(
			"sf org display missing accessToken/instanceUrl. Run: sf org login web --alias " +
				TARGET_ORG,
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
				const auth = getAuth()
				return sendJson(res, 200, {
					ok: true,
					username: auth.username ?? null,
					orgId: auth.orgId ?? null,
					targetOrg: TARGET_ORG,
					instanceUrl: auth.instanceUrl,
				})
			} catch (error) {
				return sendJson(res, 503, {
					ok: false,
					error: error instanceof Error ? error.message : String(error),
					hint: `Run: sf org login web --alias ${TARGET_ORG}`,
				})
			}
		}

		// Proxy Salesforce REST / GraphQL under /services/*
		if (url.pathname.startsWith("/services/")) {
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
	console.log(
		`[local-sf] listening on http://${HOST}:${PORT} (org alias: ${TARGET_ORG})`,
	)
	console.log(`[local-sf] health: http://${HOST}:${PORT}/health`)
	try {
		const auth = getAuth()
		console.log(`[local-sf] authenticated as ${auth.username}`)
	} catch (error) {
		console.warn(
			`[local-sf] CLI auth not ready yet: ${error instanceof Error ? error.message : error}`,
		)
	}
})
