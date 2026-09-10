import type { EventVariant } from "@/api/registration/event-types"
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

/**
 * Public — served to a visitor with no session.
 *
 * `/registration/membership` is served by this same dynamic route rather than
 * as a static sibling like affiliate: it HAS a member twin, so the guard has
 * to bounce a member somewhere — and that somewhere is not
 * `/programs/membership/register` but `MEMBERSHIP_MEMBER_REGISTRATION_ROUTE`
 * below. `isMembershipProgramSlug` is how the guard tells the two apart.
 */
export const PUBLIC_REGISTRATION_ROUTE = "/registration/$programType" as const

/**
 * Individual membership — the member twin of `/registration/membership`.
 *
 * Under `/membership`, beside the benefits page it is reached from, rather
 * than under `/programs`: a membership is not a programme, and its Back link
 * returns to Membership Benefits. The guest twin is the public exam route
 * with the `membership` slug (aliased from the wire type `mem`).
 */
export const MEMBERSHIP_MEMBER_REGISTRATION_ROUTE = "/membership/register" as const

/** The slugs that name the membership programme in a URL. */
const MEMBERSHIP_PROGRAM_SLUGS = ["membership", "mem"] as const

/**
 * Whether a `$programType` param is the membership programme. Kept here, not
 * in the registry, so the guard layer does not have to import the programme
 * config to decide which twin a member belongs on.
 */
export function isMembershipProgramSlug(slug: string): boolean {
	return (MEMBERSHIP_PROGRAM_SLUGS as readonly string[]).includes(
		slug.trim().toLowerCase(),
	)
}

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
 * Event registration route pairs, one per object family.
 *
 * The public shapes are the LEGACY addresses already in GARP marketing email —
 * they must not change. Each is a **static** sibling chain
 * (`registration/webcast/…`) that outranks the dynamic
 * `/registration/$programType/$regCode` pair, the same specificity mechanism
 * `AFFILIATE_REGISTRATION_ROUTE` relies on; without that ranking,
 * `/registration/event/<id>` would fold the event id into `regCode` on the
 * exam form.
 *
 * The member twins carry the kind in the path deliberately: the layout guard
 * has to translate a guest's member URL into the right public twin, and only
 * the URL can tell it which object family that is.
 */
export const PUBLIC_EVENT_REGISTRATION_ROUTES = {
	event: "/registration/event/$eventId",
	webcast: "/registration/webcast/$eventId",
	chaptermeeting: "/registration/chaptermeeting/$eventId",
} as const satisfies Record<EventVariant, string>

export const MEMBER_EVENT_REGISTRATION_ROUTES = {
	event: "/events/event/$eventId/register",
	webcast: "/events/webcast/$eventId/register",
	chaptermeeting: "/events/chaptermeeting/$eventId/register",
} as const satisfies Record<EventVariant, string>

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
export type PublicRegistrationFallback =
	| { kind: "program"; programType: string }
	| { kind: "event"; variant: EventVariant; eventId: string }

export function publicRegistrationFallback(
	pathname: string,
): PublicRegistrationFallback | null {
	const program = /^\/programs\/([^/]+)\/register\/?$/.exec(pathname)
	if (program) return { kind: "program", programType: program[1] }

	// The membership twin lives under /membership, but its public form is the
	// ordinary `/registration/$programType` route with the `membership` slug.
	if (/^\/membership\/register\/?$/.test(pathname)) {
		return { kind: "program", programType: "membership" }
	}

	const event =
		/^\/events\/(event|webcast|chaptermeeting)\/([^/]+)\/register\/?$/.exec(
			pathname,
		)
	if (event) {
		return {
			kind: "event",
			variant: event[1] as EventVariant,
			eventId: event[2],
		}
	}

	return null
}

/**
 * The programme slug a PUBLIC registration path is for, or `undefined` when the
 * path is not one.
 *
 * `PublicShell` needs this to pick the guest chrome (navbar wordmark, banner,
 * page canvas), and it cannot read `$programType` from route context: it is an
 * *ancestor* of the route that owns the param. Deriving it from the pathname
 * keeps that a pure, synchronous read — the shell already subscribes to
 * `state.location` for the Sign In return path, so this costs nothing and adds
 * no effect. Setting it from the leaf via a store instead would paint the
 * default chrome for one frame first, then swap.
 *
 * `/registration/affiliate` returns `undefined` on purpose. It is a static
 * sibling of `/registration/$programType`, not a programme — it has no exam,
 * no seal and no banner in the designs — and TanStack Router matches it ahead
 * of the dynamic segment for exactly that reason.
 */
/**
 * True for any public registration FORM path — every programme plus affiliate.
 *
 * Broader than `publicRegistrationProgramSlug` on purpose, and the two answer
 * different questions. This one decides page *layout* (the wider gutter the
 * 2027 designs use), which every guest form gets. That one decides *chrome*
 * (banner, wordmark, canvas), which only the programmes with a Figma frame get.
 *
 * Excludes the guest 404, which wears this same shell but is not a form.
 */
export function isPublicRegistrationFormPath(pathname: string): boolean {
	return /^\/registration\/[^/]+\/?$/.test(pathname)
}

export function publicRegistrationProgramSlug(
	pathname: string,
): string | undefined {
	const match = /^\/registration\/([^/]+)\/?$/.exec(pathname)
	if (!match) return undefined

	const slug = match[1].toLowerCase()
	if (slug === "affiliate") return undefined

	return slug
}

/**
 * True when this load is the payment provider returning from a CANCELLED
 * checkout. Suppresses guard redirects for the same reason `isPaymentReturn`
 * does — this leg carries the `oid` the rollback needs, and a bounce drops it,
 * leaving an orphaned registration that reports `alreadyRegistered` forever.
 */
export function isCheckoutCancelled(search: {
	checkout_cancelled?: string | undefined
}): boolean {
	return search.checkout_cancelled === "1"
}

/**
 * True when the browser carries a staged registration to rebuild the form
 * from (deferred flow). The server appends `resume=<stagedId>` to the Stripe
 * cancel URL itself, so this arrives TOGETHER with `checkout_cancelled` on
 * that leg — and takes precedence over it: nothing was created for a staged
 * registration, so there is nothing to roll back and no dead end to show.
 */
export function isRegistrationResume(
	search: Pick<RegistrationSearch, "resume">,
): boolean {
	return Boolean(search.resume)
}

/** The three ways a registration page can be entered other than fresh. */
export type RegistrationLegProps = {
	/** The provider's success leg — the order is already charged. */
	paymentReturn: { statusId?: string; orderNumber?: string } | null
	/** The provider's cancel leg for an ORDER — roll it back, offer a restart. */
	checkoutCancelled: { orderId?: string } | null
	/** The staged row to rebuild the form from, when there is one. */
	resumeStagedId?: string
}

/**
 * Which leg this load is, from the validated search — decided in one place
 * so the member and public routes cannot disagree.
 *
 * Precedence, as GarpAppv1 applies it: a payment return first; then a resume,
 * which wins over a cancelled checkout because the cancel URL of a staged
 * checkout carries both and restoring the form is the better answer; then a
 * plain cancelled checkout; else a fresh form.
 */
export function registrationLegProps(
	search: RegistrationSearch,
): RegistrationLegProps {
	if (isPaymentReturn(search)) {
		return {
			paymentReturn: { statusId: search.oid, orderNumber: search.on },
			checkoutCancelled: null,
		}
	}
	if (isRegistrationResume(search)) {
		return {
			paymentReturn: null,
			checkoutCancelled: null,
			resumeStagedId: search.resume,
		}
	}
	if (isCheckoutCancelled(search)) {
		return { paymentReturn: null, checkoutCancelled: { orderId: search.oid } }
	}
	return { paymentReturn: null, checkoutCancelled: null }
}
