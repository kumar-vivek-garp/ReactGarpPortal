import type { ReactNode } from "react"
import { useEffect } from "react"
import { createFileRoute, Outlet, redirect } from "@tanstack/react-router"

import type { CurrentUser } from "@/api/auth/current-user"
import { authQueryKeys, ensureCurrentUser } from "@/api/auth/query-options"
import { MainLoadingBar } from "@/components/molecules/main-loading-bar"
import { PageContainer } from "@/components/molecules/page-container"
import { PageEnterFade } from "@/components/molecules/page-enter-fade"
import { AppRoutePending } from "@/components/molecules/route-pending-fallback"
import { AlertBar } from "@/components/organisms/alert-bar"
import { AppSidebar } from "@/components/organisms/app-sidebar"
import { Footer } from "@/components/organisms/footer"
import { Navbar } from "@/components/organisms/navbar"
import { useCurrentUser } from "@/hooks/use-current-user"
import { LOGIN_PATH } from "@/auth/constants"
import { getReturnPath } from "@/auth/return-path"
import { dismissBootSplash } from "@/lib/boot-splash"

function redirectToLogin(location: { href?: string; pathname: string; searchStr: string }) {
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

function AppLayoutShell({
	showLoadingBar,
	children,
}: {
	showLoadingBar: boolean
	children?: ReactNode
}) {
	return (
		<div className="flex min-h-screen flex-col">
			<Navbar />
			{/* Footer in the main column + sticky sidebar: same look, sidebar stays while footer scrolls. */}
			<div className="flex flex-1">
				<AppSidebar />
				<div className="flex min-w-0 flex-1 flex-col">
					<MainLoadingBar visible={showLoadingBar} />
					{/* Fill viewport below the toolbar so short pages don’t show the tall footer in the first screen. */}
					<main className="min-h-[calc(100vh-4rem)] min-w-0 flex-1 app:min-h-[calc(100vh-5rem)]">
						<PageContainer className="py-6">{children}</PageContainer>
					</main>
					<Footer />
				</div>
			</div>
			{/* Chrome, not page content: it floats over the layout and is mounted
			    once, so the query is shared and navigating never refetches it. */}
			<AlertBar />
		</div>
	)
}

function AppLayout() {
	const { isPending, data: user } = useCurrentUser()
	// Background refetch must not flash the bar once identity is known.
	const showLoadingBar = isPending && !user

	useEffect(() => {
		dismissBootSplash()
	}, [])

	return (
		<PageEnterFade>
			<AppLayoutShell showLoadingBar={showLoadingBar}>
				<Outlet />
			</AppLayoutShell>
		</PageEnterFade>
	)
}
