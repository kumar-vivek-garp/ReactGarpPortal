/**
 * Cookie read/clear.
 *
 * `config/order-history.ts` already writes one; these are the other two halves.
 * Kept here rather than inlined a third time so the domain handling below lives
 * in exactly one place.
 */

/** A cookie's decoded value, or null. Safe to call during SSR / tests. */
export function readCookie(name: string): string | null {
	if (typeof document === "undefined") return null
	const match = document.cookie.match(
		new RegExp(`(?:^|; )${name.replace(/[.*+?^${}()|[\]\\]/g, "\\$&")}=([^;]*)`),
	)
	if (!match) return null
	try {
		return decodeURIComponent(match[1])
	} catch {
		// A malformed percent-escape is not worth throwing over.
		return match[1]
	}
}

/**
 * Clears a cookie on the current host **and** on `garp.org`.
 *
 * Cookies set by the marketing site carry the parent domain, and a cookie can
 * only be cleared by a request whose domain matches the one it was set with —
 * so clearing the current host alone leaves it in place and the next
 * navigation sees it again.
 */
export function clearCookie(name: string, parentDomain = "garp.org"): void {
	if (typeof document === "undefined") return
	const expired = "Thu, 01 Jan 1970 00:00:01 GMT"
	document.cookie = `${name}=; Path=/; Expires=${expired}`
	document.cookie = `${name}=; Path=/; Expires=${expired}; domain=${parentDomain}`
	document.cookie = `${name}=; Path=/; Expires=${expired}; domain=.${parentDomain}`
}
