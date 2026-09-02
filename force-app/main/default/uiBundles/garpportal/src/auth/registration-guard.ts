import type { QueryClient } from "@tanstack/react-query"
import { redirect } from "@tanstack/react-router"

import type { CurrentUser } from "@/api/auth/current-user"
import { authQueryKeys, ensureCurrentUser } from "@/api/auth/query-options"
import type { EventVariant } from "@/api/registration/event-types"
import { DEFAULT_POST_LOGIN_PATH } from "@/auth/constants"
import type { EventRegistrationSearch } from "@/config/event-registration"
import type { RegistrationSearch } from "@/config/registration"
import {
	isCheckoutCancelled,
	isPaymentReturn,
	MEMBER_EVENT_REGISTRATION_ROUTES,
	MEMBER_REGISTRATION_ROUTE,
} from "@/lib/registration-paths"

type GuardArgs = {
	context: { queryClient: QueryClient }
	params: { programType: string }
	search: RegistrationSearch
}

type EventGuardArgs = {
	context: { queryClient: QueryClient }
	params: { eventId: string }
	search: EventRegistrationSearch
}

/**
 * Resolves the session and hands it to `decide`, **synchronously** when it is
 * already cached.
 *
 * The sync path is the point: an `async` beforeLoad always returns a Promise,
 * which makes the router show its pending component on every single navigation
 * even though the answer was already known. Same shape as `_appLayout`.
 */
/*
 * Note both guards resolve the session even on a payment return, and suppress
 * only the *redirect*. The confirmation screen still has to know whether this
 * visitor has an account, because that decides where its buttons can point.
 */
function withSession(
	queryClient: QueryClient,
	decide: (user: CurrentUser | null) => void,
): void | Promise<void> {
	const cached = queryClient.getQueryData<CurrentUser | null>(
		authQueryKeys.currentUser,
	)
	if (cached !== undefined) return decide(cached)
	return ensureCurrentUser(queryClient).then(decide)
}

/**
 * Guard for the **public** route: a signed-in member is sent to the in-portal
 * form, which prefills from their contact record and keeps the portal chrome.
 *
 * Note this is a deliberate departure from the legacy app, whose public route
 * has no guard at all and simply hides the guest-only fields for a member.
 */
export function redirectMemberToPortalForm({
	context,
	params,
	search,
}: GuardArgs): void | Promise<void> {
	return withSession(context.queryClient, (user) => {
		if (!user || isPaymentReturn(search)) return
		throw redirect({
			to: MEMBER_REGISTRATION_ROUTE,
			params: { programType: params.programType },
			search,
		})
	})
}

/**
 * Guard factory for the **public event** routes — one per object family,
 * because the member twin's address carries the kind in its path.
 *
 * Suppressed on BOTH checkout return legs, not just the success one: the
 * cancel return carries the `oid` the rollback depends on, and bouncing it to
 * the member route drops the param — the abandoned order is then never rolled
 * back and its orphaned registration row reports `alreadyRegistered` forever.
 */
export function redirectMemberToEventForm(variant: EventVariant) {
	return ({
		context,
		params,
		search,
	}: EventGuardArgs): void | Promise<void> =>
		withSession(context.queryClient, (user) => {
			if (!user || isPaymentReturn(search) || isCheckoutCancelled(search)) {
				return
			}
			throw redirect({
				to: MEMBER_EVENT_REGISTRATION_ROUTES[variant],
				params: { eventId: params.eventId },
				search,
			})
		})
}

/**
 * Guard for the **affiliate** route, which has no member twin.
 *
 * Affiliate sign-up creates a GARP account; someone with a session already has
 * one, and the programme does not set `allowMemberPublicRegistration`, so the
 * server would answer their email with `mustSignIn` anyway. Sending them to
 * the dashboard says that before they fill anything in — and it is the same
 * answer `_authLayout` gave while the form lived at `/affiliate`, so moving
 * the route changes the address and nothing else.
 *
 * No payment-return suppression here, unlike the exam guard: an affiliate
 * order is a single zero-price AFREE line settled server-side, so this route
 * is never a checkout return and has no `oid`/`on` to protect.
 */
export function redirectMemberToDashboard({
	context,
}: Pick<GuardArgs, "context">): void | Promise<void> {
	return withSession(context.queryClient, (user) => {
		if (!user) return
		throw redirect({ to: DEFAULT_POST_LOGIN_PATH })
	})
}
