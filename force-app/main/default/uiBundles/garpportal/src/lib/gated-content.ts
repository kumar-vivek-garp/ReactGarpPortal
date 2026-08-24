import {
	GATED_ALLOWED_HOSTS,
	GATED_MEMBERSHIP_URL,
	GATED_URL_COOKIE,
} from "@/config/gated-content"
import { readCookie } from "@/lib/cookies"

/**
 * Whether a gated URL is somewhere we are willing to send a member.
 *
 * **This is the security check on this page.** The value comes from a cookie
 * and is handed straight to `window.location`, so without it anything able to
 * write that cookie can redirect a signed-in member anywhere — at the one
 * moment they are expecting to be forwarded and will not look twice.
 * GarpAppv1's implementation does not do this.
 *
 * `new URL` is what rejects the awkward shapes: a protocol-relative
 * `//evil.example` parses with that host rather than ours, and `javascript:`
 * fails the protocol test. Only https, only garp.org or a subdomain.
 */
export function isAllowedGatedUrl(url: string | null | undefined): boolean {
	const raw = url?.trim()
	if (!raw) return false

	let parsed: URL
	try {
		parsed = new URL(raw)
	} catch {
		// Relative or malformed — nothing we can verify the destination of.
		return false
	}

	if (parsed.protocol !== "https:") return false

	const host = parsed.hostname.toLowerCase()
	return (GATED_ALLOWED_HOSTS as readonly string[]).some(
		(allowed) => host === allowed || host.endsWith(`.${allowed}`),
	)
}

/**
 * The article the member was after, or null.
 *
 * Read **once**, by the caller, on mount: the cookie is cleared the moment it
 * is used, so a later re-read would look like an expired link. The legacy
 * stores the value wrapped in single or double quotes on some paths, so both
 * are stripped after decoding.
 *
 * A value that fails `isAllowedGatedUrl` is reported as absent rather than as
 * an error — from the member's side an unusable link and a missing one are the
 * same thing, and saying more would describe our own check to whoever set it.
 */
export function readGatedUrl(): string | null {
	const raw = readCookie(GATED_URL_COOKIE)
	if (!raw) return null
	const unquoted = raw.trim().replace(/^['"]|['"]$/g, "")
	return isAllowedGatedUrl(unquoted) ? unquoted : null
}

/**
 * The membership upsell, carrying the article along.
 *
 * The gated URL travels with the member so checkout can return them to what
 * they wanted. Built on the `track_cta` shape deliberately — four different URL
 * shapes reach the same registration flow and they are **not** interchangeable;
 * only the tagged ones carry attribution.
 */
export function gatedUpsellHref(gatedUrl: string | null): string {
	if (!gatedUrl) return GATED_MEMBERSHIP_URL
	return `${GATED_MEMBERSHIP_URL}&${new URLSearchParams({
		garp_gated_url: gatedUrl,
	})}`
}
