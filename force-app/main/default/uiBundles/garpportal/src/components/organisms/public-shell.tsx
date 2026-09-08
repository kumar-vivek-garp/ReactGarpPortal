import { useEffect } from "react"
import type { ReactNode } from "react"
import { LogIn } from "lucide-react"
import { Link, useRouterState } from "@tanstack/react-router"

import { Button } from "@/components/atoms/button"
import { GarpLogoMark } from "@/components/atoms/garp-logo-mark"
import { PageContainer } from "@/components/molecules/page-container"
import { PageEnterFade } from "@/components/molecules/page-enter-fade"
import { ThemeToggle } from "@/components/molecules/theme-toggle"
import { Footer } from "@/components/organisms/footer"
import { LOGIN_PATH } from "@/auth/constants"
import { getReturnPath } from "@/auth/return-path"
import { useScrolledNav } from "@/hooks/use-scrolled-nav"
import { APP_SCROLL_ID } from "@/lib/app-scroll"
import { dismissBootSplash } from "@/lib/boot-splash"
import { cn } from "@/lib/utils"

/**
 * The guest-facing chrome: garp.org logo, theme toggle, Sign In — no session
 * required, no sidebar. Lifted out of `_publicFormLayout` (the `AppLayoutShell`
 * precedent) so a second consumer — the guest 404 — can wear the same chrome
 * without belonging to that layout group.
 *
 * Toolbar geometry mirrors `Navbar` exactly (`h-16` / `app:h-20` plus a spacer
 * of the same height). Still load-bearing, though for a plainer reason than it
 * once was: the forms no longer measure the toolbar themselves — the spacer
 * takes its row in the frame below and the scroller gets what is left — but a
 * form served under two shells of different heights would still pin its submit
 * bar at two different offsets.
 */
function PublicHeader() {
	const location = useRouterState({ select: (state) => state.location })
	const scrolled = useScrolledNav()

	return (
		<>
			{/* Same solid white chrome as `Navbar`: hairline below, shadow lift
			    once content scrolls beneath it. */}
			<header
				className={cn(
					"fixed top-0 right-0 left-0 z-[1000] box-border flex h-16 max-w-[100vw] items-center border-b border-border bg-toolbar text-toolbar-foreground transition-shadow duration-200 app:h-20",
					scrolled && "shadow-xs",
				)}
			>
				<a
					href="https://www.garp.org/"
					className="flex shrink-0 items-center pl-shell-inset"
				>
					<GarpLogoMark className="h-auto w-[125px]" />
				</a>

				<div className="ml-auto flex shrink-0 items-center gap-1 pr-shell-gutter">
					<ThemeToggle variant="toolbar" />
					{/*
					 * Signing in is a full navigation and a form is not persisted,
					 * so this belongs in the chrome — offered before anything has been
					 * typed — rather than as a rescue halfway down a form.
					 */}
					<Button asChild size="sm" className="cursor-pointer gap-2">
						<Link
							to={LOGIN_PATH}
							search={{ startUrl: getReturnPath(location) }}
						>
							<LogIn className="size-4" />
							Sign In
						</Link>
					</Button>
				</div>
			</header>

			{/* Spacer so content clears the fixed toolbar. */}
			<div className="h-16 shrink-0 app:h-20" aria-hidden="true" />
		</>
	)
}

function PublicShell({ children }: { children?: ReactNode }) {
	useEffect(() => {
		dismissBootSplash()
	}, [])

	return (
		<PageEnterFade>
			{/* Same frame as `AppLayoutShell`, minus the rail: the viewport is
			    fixed, the main column scrolls, the footer rides inside it. The two
			    shells must agree — a registration form is served under both. */}
			<div className="flex h-screen flex-col overflow-hidden">
				<PublicHeader />
				<div
					id={APP_SCROLL_ID}
					data-scroll-restoration-id={APP_SCROLL_ID}
					className="min-h-0 flex-1 overflow-y-auto [scrollbar-width:none] [&::-webkit-scrollbar]:hidden"
				>
					<main className="min-h-full min-w-0">
						<PageContainer className="py-6">{children}</PageContainer>
					</main>
					<Footer />
				</div>
			</div>
		</PageEnterFade>
	)
}

export { PublicShell }
