import { createFileRoute, Outlet, redirect } from "@tanstack/react-router"

import type { CurrentUser } from "@/api/auth/current-user"
import { authQueryKeys, ensureCurrentUser } from "@/api/auth/query-options"
import { AppRoutePending } from "@/components/molecules/route-pending-fallback"
import { AppLayoutShell } from "@/components/organisms/app-layout-shell"
import { LOGIN_PATH } from "@/auth/constants"
import { getReturnPath } from "@/auth/return-path"
import type { RegistrationSearch } from "@/config/registration"
import {
	publicRegistrationFallback,
	PUBLIC_REGISTRATION_ROUTE,
} from "@/lib/registration-paths"

type GuardLocation = {
	href?: string
	pathname: string
	searchStr: string
	search: Record<string, unknown>
}

/**
 * Where a visitor with no session goes.
 *
 * Usually the sign-in wall. Registration is the exception: the same form is
 * served publicly, and demanding an account first is the exact barrier the
 * public route exists to remove — so those paths hand off to their public twin,
 * carrying the query string (a `regCode` lost here silently reprices the
 * order).
 *
 * This lives in the layout guard rather than on the registration route because
 * a parent `beforeLoad` runs first and would reach Login before any child could
 * object. The alternative — a second layout group whose guard could run
 * instead — remounts this entire shell on every navigation across the
 * boundary, which is a visible full-screen flash.
 */
function redirectUnauthenticated(location: GuardLocation) {
	const fallback = publicRegistrationFallback(location.pathname)
	if (fallback) {
		throw redirect({
			to: PUBLIC_REGISTRATION_ROUTE,
			params: { programType: fallback.programType },
			search: location.search as RegistrationSearch,
		})
	}
	throw redirect({
		to: LOGIN_PATH,
		search: { startUrl: getReturnPath(location) },
	})
}

export const Route = createFileRoute("/_appLayout")({
	/**
	 * Must stay sync on cache hit. An `async` beforeLoad always returns a Promise,
	 * and with a low pendingMs that flashes AppRoutePending on every sidebar click.
	 */
	beforeLoad: ({ context, location }) => {
		const cached = context.queryClient.getQueryData<CurrentUser | null>(
			authQueryKeys.currentUser,
		)
		if (cached !== undefined) {
			if (!cached) redirectUnauthenticated(location)
			return
		}
		return ensureCurrentUser(context.queryClient).then((user) => {
			if (!user) redirectUnauthenticated(location)
		})
	},
	// Delay pending shell so sync/microtask auth resolves without a flash.
	// Still shows for real waits (cold identity + lazy layout chunk).
	pendingMs: 250,
	pendingComponent: AppRoutePending,
	component: AppLayout,
})

function AppLayout() {
	return (
		<AppLayoutShell>
			<Outlet />
		</AppLayoutShell>
	)
}
