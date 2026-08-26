import { useEffect } from "react"
import { LogIn } from "lucide-react"
import {
	createFileRoute,
	Link,
	Outlet,
	useRouterState,
} from "@tanstack/react-router"

import { Button } from "@/components/atoms/button"
import { GarpLogoMark } from "@/components/atoms/garp-logo-mark"
import { PageContainer } from "@/components/molecules/page-container"
import { PageEnterFade } from "@/components/molecules/page-enter-fade"
import { ThemeToggle } from "@/components/molecules/theme-toggle"
import { Footer } from "@/components/organisms/footer"
import { LOGIN_PATH } from "@/auth/constants"
import { getReturnPath } from "@/auth/return-path"
import { useScrolledNav } from "@/hooks/use-scrolled-nav"
import { dismissBootSplash } from "@/lib/boot-splash"
import { cn } from "@/lib/utils"

/**
 * Chrome for forms served to someone with no session.
 *
 * Deliberately not `_authLayout`: that one is a vertically-centred splash for a
 * single narrow card, and its guard throws a signed-in user to `/dashboard` —
 * which would fight the per-form guards and, worse, silently drop the
 * `stripe_return` params on a payment return. This one carries no guard at all;
 * each form guards itself, because the redirect target depends on
 * `params.programType` and a pathless layout above that segment cannot see it.
 *
 * Toolbar geometry mirrors `Navbar` exactly (`h-16` / `app:h-20` plus a spacer
 * of the same height). That is load-bearing, not cosmetic: the forms size
 * themselves with `h-[calc(100vh-4rem)]` / `app:h-[calc(100vh-5rem)]`, so a
 * header of any other height would leave the sticky submit bar off-screen.
 *
 * Built to carry the other programme forms as they are written, not just FRM.
 */
export const Route = createFileRoute("/_publicFormLayout")({
	component: PublicFormLayout,
})

function PublicFormHeader() {
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
					 * Signing in is a full navigation and the form is not persisted,
					 * so this belongs in the chrome — offered before anything has been
					 * typed — rather than as a rescue halfway down the form.
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

function PublicFormLayout() {
	useEffect(() => {
		dismissBootSplash()
	}, [])

	return (
		<PageEnterFade>
			<div className="flex min-h-screen flex-col">
				<PublicFormHeader />
				<main className="min-h-[calc(100vh-4rem)] min-w-0 flex-1 app:min-h-[calc(100vh-5rem)]">
					<PageContainer className="py-6">
						<Outlet />
					</PageContainer>
				</main>
				<Footer />
			</div>
		</PageEnterFade>
	)
}
