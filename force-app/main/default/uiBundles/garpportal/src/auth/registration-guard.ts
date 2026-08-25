import type { QueryClient } from "@tanstack/react-query"
import { redirect } from "@tanstack/react-router"

import type { CurrentUser } from "@/api/auth/current-user"
import { authQueryKeys, ensureCurrentUser } from "@/api/auth/query-options"
import type { RegistrationSearch } from "@/config/registration"
import {
	isPaymentReturn,
	MEMBER_REGISTRATION_ROUTE,
	PUBLIC_REGISTRATION_ROUTE,
} from "@/lib/registration-paths"

type GuardArgs = {
	context: { queryClient: QueryClient }
	params: { programType: string }
	search: RegistrationSearch
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
 * Guard for the **member** route: someone with no session is sent to the
 * public form rather than to Login.
 *
 * Registration is the one member route where a guest has somewhere better to
 * go than a sign-in wall — the same form is served publicly, and demanding an
 * account first is exactly the barrier the public route exists to remove.
 */
export function redirectGuestToPublicForm({
	context,
	params,
	search,
}: GuardArgs): void | Promise<void> {
	return withSession(context.queryClient, (user) => {
		if (user || isPaymentReturn(search)) return
		throw redirect({
			to: PUBLIC_REGISTRATION_ROUTE,
			params: { programType: params.programType },
			search,
		})
	})
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
