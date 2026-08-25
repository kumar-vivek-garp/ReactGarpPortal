import type { RegistrationSearch } from "@/config/registration"

/**
 * The two routes the registration form is served from.
 *
 * Exported as the router's own path patterns rather than pre-built strings so
 * `redirect({ to })` stays type-checked against the generated route tree — and
 * so the guest bounced off the member route and the member bounced off the
 * public one cannot disagree about where the other lives. Two hardcoded
 * strings that drift apart is not a broken link, it is a redirect loop.
 */

/** Inside the portal shell, session required. */
export const MEMBER_REGISTRATION_ROUTE = "/programs/$programType/register" as const

/** Public — served to a visitor with no session. */
export const PUBLIC_REGISTRATION_ROUTE = "/registration/$programType" as const

/**
 * Affiliate membership sign-up — this app's "Create Account".
 *
 * A **static** sibling of `PUBLIC_REGISTRATION_ROUTE`, and that is what makes
 * it work: TanStack Router sorts routes by specificity, so a static segment is
 * always matched ahead of a dynamic one and `/registration/affiliate` never
 * reaches `$programType`. It must not: `$programType` dispatches the *exam*
 * kind, whose panel prices a cart and whose guard bounces a member to
 * `/programs/<type>/register` — a page affiliate has no equivalent of.
 *
 * It has no member twin at all. Someone with a session already has an account,
 * which is the only thing this form creates, so the guard sends them to their
 * dashboard rather than to an in-portal version of the form.
 */
export const AFFILIATE_REGISTRATION_ROUTE = "/registration/affiliate" as const

/**
 * The address this form used to live at, kept as a redirect.
 *
 * Not a live route any more, but it has been the affiliate sign-up's public
 * URL and is linked from outside the app, so it forwards rather than 404s.
 */
export const LEGACY_AFFILIATE_ROUTE = "/affiliate" as const

/**
 * True when this load is the payment provider returning.
 *
 * Neither guard may redirect on a payment return. The checkout success URL is
 * built from `window.location` at submit time, so the provider comes back to
 * whichever route started the payment, carrying `oid`/`on` and nothing else.
 * Bouncing it to the route that suits the current session drops those params,
 * and the candidate loses the confirmation for an order already charged.
 */
export function isPaymentReturn(
	search: Pick<RegistrationSearch, "stripe_return">,
): boolean {
	return search.stripe_return === "1"
}

/**
 * The programme whose public form stands in for this member path, or null when
 * the path has no public equivalent.
 *
 * `_appLayout`'s guard asks this before falling back to the sign-in wall, which
 * is what lets the member registration route stay *inside* the app layout.
 * Giving it its own layout group instead — so its guard could run first —
 * meant the entire portal shell unmounted and remounted whenever anyone
 * navigated in or out of it: a full-screen flash, and the alert bar refetching
 * on a query that is supposed to be mounted once.
 */
export function publicRegistrationFallback(
	pathname: string,
): { programType: string } | null {
	const match = /^\/programs\/([^/]+)\/register\/?$/.exec(pathname)
	return match ? { programType: match[1] } : null
}
