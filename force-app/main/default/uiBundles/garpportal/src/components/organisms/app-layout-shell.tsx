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
import { APP_SCROLL_ID } from "@/lib/app-scroll"
import { dismissBootSplash } from "@/lib/boot-splash"

function Chrome({
	showLoadingBar,
	children,
}: {
	showLoadingBar: boolean
	children?: ReactNode
}) {
	return (
		/*
		 * A frame, not a document: `h-screen` + `overflow-hidden` means the page
		 * itself never scrolls, so the toolbar and the rail hold their place
		 * because they are outside the scrolling box rather than because each of
		 * them re-derives the viewport height. Everything that moves, moves in one
		 * container — see `lib/app-scroll.ts`.
		 */
		<div className="flex h-screen flex-col overflow-hidden">
			{/* Renders its own `fixed` bar plus a spacer of the same height; the
			    spacer is what takes the row here. */}
			<Navbar />

			<div className="flex min-h-0 flex-1">
				<AppSidebar />
				<div className="flex min-w-0 flex-1 flex-col">
					{/* Above the scroller so a background refetch does not slide the
					    bar away with the content. */}
					<MainLoadingBar visible={showLoadingBar} />

					{/*
					 * The one scroll container in the app. The footer is its last
					 * child rather than a sibling, so it is reached by the same
					 * gesture that reads the page — which is the whole point of
					 * moving the overflow up here.
					 *
					 * The scrollbar is hidden to match every surface it replaced;
					 * `FooterBackToTop`'s progress ring is the affordance that
					 * survives. `data-scroll-restoration-id` is what lets the router
					 * cache and restore this element's offset across history entries,
					 * a job the browser only does for free when the document scrolls.
					 */}
					<div
						id={APP_SCROLL_ID}
						data-scroll-restoration-id={APP_SCROLL_ID}
						className="min-h-0 flex-1 overflow-y-auto [scrollbar-width:none] [&::-webkit-scrollbar]:hidden"
					>
						{/* Fills the scroller so a short page still puts the footer
						    below the fold instead of halfway up the screen. */}
						<main className="min-h-full min-w-0">
							<PageContainer className="py-6">{children}</PageContainer>
						</main>
						<Footer />
					</div>
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
