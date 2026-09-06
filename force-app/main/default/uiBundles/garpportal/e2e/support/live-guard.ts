import type { Page, Route } from "@playwright/test"

import { memberPortalEnvelope } from "@/testing/factories/envelope"

/**
 * THE BIG RULE, MECHANICALLY: the live suite reads a REAL org, so this
 * guard makes mutation requests physically impossible — installed on every
 * live page BEFORE navigation.
 *
 * Policy (each allowance verified against the Apex, see OVERNIGHT-REPORT):
 * - GET/HEAD pass. (The one known GET-that-writes — memberportal/me's
 *   login stamp — is skipped for the CLI admin session, verified.)
 * - POST passes ONLY for: GraphQL whose operation is a `query` (body
 *   inspected; mutations abort), and the two Apex actions verified
 *   DML-free: directorySearch, cvDocumentRequirement.
 * - memberportal/examResultViewed — a real org mutation auto-fired on the
 *   results page's mount — is FULFILLED with a fake success envelope: the
 *   org never sees it, the page doesn't error.
 * - Everything else non-GET aborts, and is recorded for assertion.
 */

const POST_ALLOWLIST = [
	"/memberportal/directorySearch",
	"/memberportal/cvDocumentRequirement",
]

export type OrgSafetyGuard = {
	/** Requests the guard refused (method + url), for the negative spec. */
	readonly blocked: string[]
	/** Mutations neutralized with a fake success (org never contacted). */
	readonly neutralized: string[]
}

function isGraphqlQuery(postData: string | null): boolean {
	if (!postData) return false
	try {
		const parsed = JSON.parse(postData) as { query?: unknown }
		return (
			typeof parsed.query === "string" &&
			parsed.query.trimStart().startsWith("query")
		)
	} catch {
		return false
	}
}

export async function installOrgSafetyGuard(
	page: Page,
): Promise<OrgSafetyGuard> {
	const blocked: string[] = []
	const neutralized: string[] = []

	async function guard(route: Route): Promise<void> {
		const request = route.request()
		const method = request.method()
		const url = request.url()

		if (method === "GET" || method === "HEAD") {
			await route.fallback()
			return
		}

		if (url.includes("/memberportal/examResultViewed")) {
			neutralized.push(`${method} ${url}`)
			await route.fulfill({ json: memberPortalEnvelope({}) })
			return
		}

		if (url.includes("/graphql") && isGraphqlQuery(request.postData())) {
			await route.fallback()
			return
		}

		if (POST_ALLOWLIST.some((path) => url.includes(path))) {
			await route.fallback()
			return
		}

		blocked.push(`${method} ${url}`)
		await route.abort("blockedbyclient")
	}

	await page.route("**/services/**", guard)
	await page.route("**/__local_sf/**", guard)

	return { blocked, neutralized }
}
