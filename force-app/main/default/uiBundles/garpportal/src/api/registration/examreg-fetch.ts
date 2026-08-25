import { createDataSDK } from "@salesforce/platform-sdk"

import type { MemberPortalEnvelope } from "@/api/account/types"
import {
	normalizeHttpResponse,
	unwrapApiResult,
	unwrapMemberPortalEnvelope,
} from "@/api/client"
import { getSfdcEnv, isLocalViteHost } from "@/auth/sfdc-env"

/** `GARP_ExamReg_API` — one `@RestResource` for every registration programme. */
export const EXAMREG_BASE = "/services/apexrest/examreg"

export const EXAMREG_UNREACHABLE = "Unable to reach the registration service."

/** The site's API proxy base (e.g. `/garpportal/sf/api`), from the bootstrap. */
function proxyBase(): string {
	const base = getSfdcEnv()?.apiPath ?? ""
	/*
	 * A trailing slash cannot survive concatenation. `apiPath` is "/" on local
	 * dev, and "/" + "/services/…" is "//services/…" — a protocol-relative URL
	 * that the browser resolves against the host `services`, so every request
	 * dies as "Failed to fetch" rather than as anything diagnosable.
	 */
	return base === "/" ? "" : base.replace(/\/$/, "")
}

/**
 * A guest session cannot use the Data SDK.
 *
 * Before any POST the SDK fetches a CSRF token from `/ui-api/session/csrf` — a
 * Connect-family endpoint guest users are not entitled to ("The Chatter
 * Connect API is not enabled for this organization or user type"). The site
 * proxy itself accepts plain same-origin guest requests, so that is what a
 * guest gets instead.
 *
 * This is the one sanctioned exception to the "never call `fetch` for org
 * data" rule: there is no SDK path that works here, and the alternative is a
 * public form whose every POST fails.
 */
function guestFetch(path: string, init: RequestInit): Promise<Response> {
	return fetch(`${proxyBase()}${EXAMREG_BASE}${path}`, {
		...init,
		credentials: "same-origin",
	})
}

/** Recognises the CSRF/Connect refusal, from either a thrown error or a body. */
function isConnectBlocked(error: unknown, bodyText?: string): boolean {
	const message = error instanceof Error ? error.message : String(error ?? "")
	return (
		/Chatter Connect|ui-api\/session\/csrf/i.test(message) ||
		/Chatter Connect/i.test(bodyText ?? "")
	)
}

/** Memoised per page load — the session cannot change without a navigation. */
let sessionProbe: Promise<boolean> | null = null

/**
 * `GET examreg/whoami` — the module's query-less identity action.
 *
 * Deliberately not `fetchCurrentUser`: that asks UI-API GraphQL, which 403s
 * for guests and fills the console on a page that is *expected* to be visited
 * without a session. `whoami` answers from `UserInfo.getUserType()` and is
 * covered by the same guest grant as the rest of the module. Any failure is
 * read as "guest", which routes to the transport that works without a session.
 */
function probeIsAuthenticated(): Promise<boolean> {
	if (!sessionProbe) {
		/*
		 * Local dev talks to the CLI gateway, which signs every request as an
		 * admin. There is no guest to detect, and an unsigned same-origin call
		 * to the proxy is rejected outright — so the SDK is the only transport
		 * that works here, and asking would only produce a wrong answer.
		 */
		if (isLocalViteHost()) {
			sessionProbe = Promise.resolve(true)
			return sessionProbe
		}

		sessionProbe = fetch(`${proxyBase()}${EXAMREG_BASE}/whoami`, {
			headers: { Accept: "application/json" },
			credentials: "same-origin",
		})
			.then(async (response) => {
				const payload = await response.json()
				if (!response.ok || payload?.status === "Error") return true
				// Only an explicit `false` routes to the guest transport. Anything
				// else is "unknown", and unknown takes the SDK path — where a real
				// guest is still caught by the Connect fallback below, at the cost
				// of one wasted request rather than a form that cannot submit.
				return payload?.data?.isAuthenticated !== false
			})
			.catch(() => true)
	}
	return sessionProbe
}

/**
 * Picks the transport, then falls back if the pick was wrong.
 *
 * The probe avoids issuing a request that is known to fail, but it is a cached
 * answer and the session can outlive it — so a Connect refusal on the SDK path
 * still retries as a guest rather than surfacing as a broken form.
 */
async function examregRequest(
	path: string,
	init: RequestInit,
): Promise<Response | undefined> {
	if (!(await probeIsAuthenticated())) return guestFetch(path, init)

	try {
		const sdk = await createDataSDK()
		const response = await sdk.fetch?.(`${EXAMREG_BASE}${path}`, init)
		if (response && !response.ok) {
			const probe = await response.clone().text()
			if (isConnectBlocked(null, probe)) return guestFetch(path, init)
		}
		return response
	} catch (error) {
		if (isConnectBlocked(error)) return guestFetch(path, init)
		throw error
	}
}

/**
 * Shared transport for the registration endpoints.
 *
 * Guest-reachable by design — the same endpoint serves someone with no session
 * — and it answers with the portal-standard envelope. Which transport carries
 * the request is decided by `examregRequest`; the session, when there is one,
 * is what makes the load report `isAuthenticated`.
 */
export async function examregFetch<T>(
	path: string,
	init: RequestInit,
	messages: { unreachable: string; fallback: string },
): Promise<T> {
	const response = await examregRequest(path, {
		...init,
		headers: {
			Accept: "application/json",
			...(init.body ? { "Content-Type": "application/json" } : {}),
			...init.headers,
		},
	})

	const result = await normalizeHttpResponse<MemberPortalEnvelope<T>>(response, {
		unreachableMessage: messages.unreachable,
		fallbackErrorMessage: messages.fallback,
	})

	return unwrapMemberPortalEnvelope(unwrapApiResult(result), {
		fallbackErrorMessage: messages.fallback,
		missingDataMessage: messages.fallback,
		status: result.status,
	})
}
