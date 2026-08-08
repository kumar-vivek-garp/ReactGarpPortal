import { authQueryKeys } from "@/api/auth/query-options"
import { LOGIN_PATH, LOGOUT_URL } from "@/auth/constants"
import { markLocallyLoggedOut } from "@/auth/local-session"
import { getSfdcEnv, isLocalViteHost } from "@/auth/sfdc-env"
import { queryClient } from "@/api/client"

function siteBasePath(): string {
	return (getSfdcEnv()?.basePath ?? "").replace(/\/+$/, "")
}

/**
 * Absolute URL guests can open after logout (public SPA home).
 * Confirmed reachable as guest; React guards then route to Login.
 */
export function getPostLogoutReturnUrl(): string {
	const base = siteBasePath()
	const path = !base || base === "/" ? "/" : `${base}/`
	return `${window.location.origin}${path}`
}

/**
 * Domain-root `/secur/logout.jsp` + absolute `retURL`.
 *
 * Do not use `/{basePath}/secur/logout.jsp` on this React UI Bundle site — that
 * path 404s. Do not use `startURL` — on this shared domain it forwards through
 * My GARP’s `/Login`.
 */
function buildExperienceLogoutUrl(retURL: string): string {
	const url = new URL(LOGOUT_URL, window.location.origin)
	url.searchParams.set("retURL", retURL)
	return `${url.pathname}${url.search}`
}

function resolveReturnUrl(override?: string): string {
	if (!override) return getPostLogoutReturnUrl()
	if (override.startsWith("https://") || override.startsWith("http://")) {
		return override
	}
	if (override.startsWith("/") && !override.startsWith("//")) {
		return `${window.location.origin}${override}`
	}
	return getPostLogoutReturnUrl()
}

/**
 * Ends the Salesforce session.
 *
 * - Experience: `/secur/logout.jsp?retURL=<absolute public site home>`.
 * - Local Vite: clear client auth cache / local flag and go to Login.
 */
export function logoutToSalesforce(returnUrl?: string) {
	queryClient.removeQueries({ queryKey: authQueryKeys.all })

	if (isLocalViteHost()) {
		markLocallyLoggedOut()
		window.location.replace(LOGIN_PATH)
		return
	}

	window.location.replace(buildExperienceLogoutUrl(resolveReturnUrl(returnUrl)))
}
