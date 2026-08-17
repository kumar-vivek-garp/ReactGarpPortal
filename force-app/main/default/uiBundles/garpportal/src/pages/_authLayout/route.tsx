import { useEffect } from "react"
import { createFileRoute, Outlet, redirect } from "@tanstack/react-router"

import type { CurrentUser } from "@/api/auth/current-user"
import { authQueryKeys, ensureCurrentUser } from "@/api/auth/query-options"
import { PageEnterFade } from "@/components/molecules/page-enter-fade"
import { AuthRoutePending } from "@/components/molecules/route-pending-fallback"
import { DEFAULT_POST_LOGIN_PATH } from "@/auth/constants"
import { getSafeStartUrl } from "@/auth/start-url"
import { dismissBootSplash } from "@/lib/boot-splash"

export const Route = createFileRoute("/_authLayout")({
	beforeLoad: ({ context, location }) => {
		const finish = (user: CurrentUser | null) => {
			if (!user) return
			const params = new URLSearchParams(
				location.searchStr.startsWith("?")
					? location.searchStr.slice(1)
					: location.searchStr,
			)
			const startUrl = getSafeStartUrl(params.get("startUrl"))
			throw redirect({ href: startUrl || DEFAULT_POST_LOGIN_PATH })
		}

		const cached = context.queryClient.getQueryData<CurrentUser | null>(
			authQueryKeys.currentUser,
		)
		if (cached !== undefined) {
			finish(cached)
			return
		}
		return ensureCurrentUser(context.queryClient).then(finish)
	},
	pendingMs: 250,
	pendingComponent: AuthRoutePending,
	component: AuthLayout,
})

function AuthLayout() {
	useEffect(() => {
		dismissBootSplash()
	}, [])

	return (
		<PageEnterFade className="min-h-screen">
			<Outlet />
		</PageEnterFade>
	)
}
