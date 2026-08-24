import { GarpLogoMark } from "@/components/atoms/garp-logo-mark"
import { MobileNavBar } from "@/components/organisms/mobile-nav-bar"
import { NavMegaMenu } from "@/components/organisms/nav-mega-menu"
import { SignOutButton } from "@/components/molecules/sign-out-button"
import { ThemeToggle } from "@/components/molecules/theme-toggle"

/**
 * App chrome header.
 *
 * Desktop geometry is derived from the shell grid tokens rather than the magic
 * margins this bar used to carry, so three edges line up down the page:
 *
 *   |<-- shell-rail -->|<- gutter ->|
 *   |  [GARP]          |  FRM  SCR  …        ← toolbar
 *   |  (avatar) NAME   |  Dashboard…         ← sidebar / main column
 *
 * The mega-menu, its scrim, and the overflow logic all live in `NavMegaMenu`.
 */
function Navbar() {
	return (
		<>
			{/* Fixed 80px black bar, desktop only. */}
			<header className="fixed top-0 right-0 left-0 z-[1000] box-border hidden h-20 max-w-[100vw] items-center bg-toolbar text-toolbar-foreground app:flex">
				{/* Logo slot is exactly the sidebar's width, inset to the sidebar avatar. */}
				<a
					href="https://www.garp.org/"
					className="flex w-shell-rail shrink-0 items-center pl-shell-inset"
				>
					<GarpLogoMark className="h-auto w-[125px]" />
				</a>

				<NavMegaMenu />

				<div className="flex shrink-0 items-center gap-1 pr-shell-gutter">
					<ThemeToggle variant="toolbar" />
					<SignOutButton className="whitespace-nowrap text-body" />
				</div>
			</header>

			{/* Mobile toolbar + full-screen menu (< 960px). */}
			<MobileNavBar />

			{/* Spacer so page content clears the fixed toolbars. */}
			<div className="h-16 shrink-0 app:h-20" aria-hidden="true" />
		</>
	)
}

export { Navbar }
