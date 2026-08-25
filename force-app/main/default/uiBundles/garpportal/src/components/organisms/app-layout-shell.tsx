import type { ReactNode } from "react"
import { useEffect } from "react"

import { MainLoadingBar } from "@/components/molecules/main-loading-bar"
import { PageContainer } from "@/components/molecules/page-container"
import { PageEnterFade } from "@/components/molecules/page-enter-fade"
import { AlertBar } from "@/components/organisms/alert-bar"
import { AppSidebar } from "@/components/organisms/app-sidebar"
import { Footer } from "@/components/organisms/footer"
import { Navbar } from "@/components/organisms/navbar"
import { useCurrentUser } from "@/hooks/use-current-user"
import { dismissBootSplash } from "@/lib/boot-splash"

function Chrome({
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

/**
 * The portal shell every signed-in page renders inside.
 *
 * Lifted out of `_appLayout/route.tsx` so a second layout group can wear the
 * same chrome under a *different* guard. `_appLayout` sends a guest to Login;
 * the registration form has to send them to its public twin instead, and a
 * parent `beforeLoad` runs before any child can say otherwise — so the two
 * cannot share one layout route, only this component.
 */
export function AppLayoutShell({ children }: { children?: ReactNode }) {
	const { isPending, data: user } = useCurrentUser()
	// Background refetch must not flash the bar once identity is known.
	const showLoadingBar = isPending && !user

	useEffect(() => {
		dismissBootSplash()
	}, [])

	return (
		<PageEnterFade>
			<Chrome showLoadingBar={showLoadingBar}>{children}</Chrome>
		</PageEnterFade>
	)
}
