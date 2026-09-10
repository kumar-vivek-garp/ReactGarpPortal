import { useEffect } from "react"
import type { ReactNode } from "react"
import { LogIn } from "lucide-react"
import { Link, useRouterState } from "@tanstack/react-router"

import { Button } from "@/components/atoms/button"
import { GarpLogoMark } from "@/components/atoms/garp-logo-mark"
import { PageContainer } from "@/components/molecules/page-container"
import { PageEnterFade } from "@/components/molecules/page-enter-fade"
import { ThemeToggle } from "@/components/molecules/theme-toggle"
import { PublicFooter } from "@/components/organisms/public-footer"
import { RegistrationBanner } from "@/components/organisms/registration-banner"
import type { ProgramChrome } from "@/config/program-chrome"
import { LOGIN_PATH } from "@/auth/constants"
import { getReturnPath } from "@/auth/return-path"
import { useScrolledNav } from "@/hooks/use-scrolled-nav"
import { APP_SCROLL_ID } from "@/lib/app-scroll"
import { dismissBootSplash } from "@/lib/boot-splash"
import { registrationChromeForPath } from "@/lib/registration-chrome"
import { isPublicRegistrationFormPath } from "@/lib/registration-paths"
import { cn } from "@/lib/utils"

/**
 * The programme lockup in the guest navbar, correct in both themes.
 *
 * GARP publishes this lockup as raster only — there is no SVG for it, in Figma
 * or on garp.org (only the GARP mark itself is vector, which is why
 * `GarpLogoMark` can just follow `currentColor`). So the two published variants
 * are swapped by the `dark:` variant rather than recoloured: knockout on the
 * dark toolbar, dark ink on the light one. CSS rather than JS, so the right one
 * is there on first paint with no flash.
 *
 * RAI has no published dark-ink short lockup, so it is darkened with a filter
 * instead. Its knockout is 99% monochrome white — 8 coloured pixels out of 915
 * — which is why that reads as the real thing rather than as a hack. Give it a
 * `wordmarkInk` and this branch stops applying.
 *
 * Both images are decorative; the wrapping link carries the accessible name.
 */
function ProgramWordmark({ chrome }: { chrome: ProgramChrome }) {
	const size = "h-auto w-26.25 app:w-32.5"

	if (!chrome.wordmarkInk) {
		return (
			<img
				src={chrome.wordmark}
				alt=""
				aria-hidden="true"
				decoding="async"
				fetchPriority="high"
				className={cn(size, "brightness-0 dark:brightness-100")}
			/>
		)
	}

	return (
		<>
			<img
				src={chrome.wordmarkInk}
				alt=""
				aria-hidden="true"
				decoding="async"
				fetchPriority="high"
				className={cn(size, "dark:hidden")}
			/>
			<img
				src={chrome.wordmark}
				alt=""
				aria-hidden="true"
				decoding="async"
				fetchPriority="high"
				className={cn(size, "hidden dark:block")}
			/>
		</>
	)
}

/**
 * The guest-facing chrome: logo, theme toggle, Sign In — no session required,
 * no sidebar. Lifted out of `_publicFormLayout` (the `AppLayoutShell`
 * precedent) so a second consumer — the guest 404 — can wear the same chrome
 * without belonging to that layout group.
 *
 * On a programme registration path the bar swaps the GARP wordmark for the
 * programme's own. The bar itself keeps the portal's toolbar tokens rather than
 * the designs' flat black, so it follows light/dark like every other surface —
 * which is why the lockup needs a per-theme variant (see [ProgramWordmark]).
 * `chrome` is `undefined` everywhere else and the bar stays exactly as it was —
 * that fallback is the contract, not a gap.
 *
 * Toolbar geometry mirrors `Navbar` exactly (`h-16` / `app:h-20` plus a spacer
 * of the same height). Still load-bearing, though for a plainer reason than it
 * once was: the forms no longer measure the toolbar themselves — the spacer
 * takes its row in the frame below and the scroller gets what is left — but a
 * form served under two shells of different heights would still pin its submit
 * bar at two different offsets. The designs draw this bar 77px tall; matching
 * that would break the agreement with `Navbar` for 3px nobody can see.
 */
function PublicHeader({ chrome }: { chrome?: ProgramChrome }) {
	const location = useRouterState({ select: (state) => state.location })
	const scrolled = useScrolledNav()

	return (
		<>
			{/* Hairline below, shadow lift once content scrolls beneath it. Same
			    toolbar tokens the portal navbar uses, so this bar follows the theme
			    in both modes rather than being painted a fixed colour. */}
			<header
				className={cn(
					"fixed top-0 right-0 left-0 z-[1000] box-border flex h-16 max-w-[100vw] items-center border-b border-border bg-toolbar text-toolbar-foreground transition-shadow duration-200 app:h-20",
					scrolled && "shadow-xs",
				)}
			>
				{/*
				 * The link carries the accessible name, not the images: the lockup is
				 * two `<img>`s swapped by theme, and naming both would expose the
				 * programme twice to a screen reader depending on the mode.
				 */}
				<a
					href="https://www.garp.org/"
					aria-label={chrome ? chrome.label : "GARP"}
					className="flex shrink-0 items-center pl-shell-inset"
				>
					{chrome ? <ProgramWordmark chrome={chrome} /> : <GarpLogoMark label={null} className="h-auto w-31.25" />}
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

	/*
	 * Derived from the path, not from route context: this shell is an ancestor
	 * of the route that owns `$programType`, so it cannot read the param. Pure
	 * and synchronous, so the right chrome is there on the first paint — a
	 * store written from the leaf would show the default for a frame, then swap.
	 */
	const pathname = useRouterState({ select: (state) => state.location.pathname })
	/*
	 * Two different scopes, deliberately. The wider gutter is a LAYOUT fix and
	 * every guest registration form gets it — including the ones with no Figma
	 * frame, which keep the old chrome. The banner, wordmark and canvas are
	 * CHROME and only appear for the programmes that were actually redesigned.
	 */
	const isRegistrationForm = isPublicRegistrationFormPath(pathname)
	const guest = registrationChromeForPath(pathname)

	return (
		<PageEnterFade>
			{/* Same frame as `AppLayoutShell`, minus the rail: the viewport is
			    fixed, the main column scrolls, the footer rides inside it. The two
			    shells must agree — a registration form is served under both. */}
			<div className="flex h-screen flex-col overflow-hidden">
				<PublicHeader chrome={guest?.chrome} />
				{/*
				 * `bg-background` on the scroller, not just on `body`, because the
				 * canvas class reassigns `--background` for this subtree — the
				 * scroller has to paint it for the tint to appear at all, and
				 * everything inside that already uses `bg-background` (the form's
				 * sticky submit bar above all) then follows it for free.
				 */}
				<div
					id={APP_SCROLL_ID}
					data-scroll-restoration-id={APP_SCROLL_ID}
					className={cn(
						"min-h-0 flex-1 overflow-y-auto bg-background [scrollbar-width:none] [&::-webkit-scrollbar]:hidden",
						isRegistrationForm && "guest-form-gutter",
						guest?.chrome.canvas,
					)}
				>
					<main className="min-h-full min-w-0">
						{/* Inside `main` so the banner's `h1` sits in the landmark it
						    titles, and above the container so it can be full-bleed. */}
						{guest ? (
							<RegistrationBanner
								chrome={guest.chrome}
								heading={guest.heading}
							/>
						) : null}
						<PageContainer className="py-6">{children}</PageContainer>
					</main>
					<PublicFooter />
				</div>
			</div>
		</PageEnterFade>
	)
}

export { PublicShell }
