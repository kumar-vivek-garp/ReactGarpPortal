import { createFileRoute, Outlet, redirect } from "@tanstack/react-router"

import type { CurrentUser } from "@/api/auth/current-user"
import { authQueryKeys, ensureCurrentUser } from "@/api/auth/query-options"
import { AppRoutePending } from "@/components/molecules/route-pending-fallback"
import { AppLayoutShell } from "@/components/organisms/app-layout-shell"
import { LOGIN_PATH } from "@/auth/constants"
import { getReturnPath } from "@/auth/return-path"

function redirectToLogin(location: {
	href?: string
	pathname: string
	searchStr: string
}) {
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
			if (!cached) redirectToLogin(location)
			return
		}
		return ensureCurrentUser(context.queryClient).then((user) => {
			if (!user) redirectToLogin(location)
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
