import { AUTH_REDIRECT_PARAM, DEFAULT_POST_LOGIN_PATH } from "@/auth/constants"

/**
 * Validates a post-login redirect path to prevent open redirects.
 * Only relative same-app paths are allowed.
 */
export function isSafeStartUrl(url: string): boolean {
	if (!url.startsWith("/") || url.startsWith("//")) return false
	if (url.includes("\\")) return false
	if (/[^\u0021-\u00ff]/.test(url)) return false
	return true
}

/** Resolve a safe startUrl from a raw query value. */
export function getSafeStartUrl(raw: string | null | undefined): string {
	if (raw && isSafeStartUrl(raw)) return raw
	return DEFAULT_POST_LOGIN_PATH
}

/** Read and sanitize startUrl from URLSearchParams. */
export function getStartUrlFromSearch(searchParams: URLSearchParams): string {
	return getSafeStartUrl(searchParams.get(AUTH_REDIRECT_PARAM))
}
