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
