import { GarpLogoMark } from "@/components/atoms/garp-logo-mark"
import { AlertBarTrigger } from "@/components/molecules/alert-bar-trigger"
import { MobileNavBar } from "@/components/organisms/mobile-nav-bar"
import { NavMegaMenu } from "@/components/organisms/nav-mega-menu"
import { SignOutButton } from "@/components/molecules/sign-out-button"
import { ThemeToggle } from "@/components/molecules/theme-toggle"
import { useScrolledNav } from "@/hooks/use-scrolled-nav"
import { cn } from "@/lib/utils"

/**
 * App chrome header.
 *
 * Desktop geometry is derived from the shell grid tokens rather than the magic
 * margins this bar used to carry, so three edges line up down the page:
 *
 *   |<- toolbar-logo ->|<- gutter ->|
 *   |  [GARP]           |  FRM  SCR  …       ← toolbar
 *   |<-- shell-rail --->|
 *   |  (avatar) NAME    |  Dashboard…        ← sidebar / main column
 *
 * Only the *left* edges are shared: the logo starts on `shell-inset`, above the
 * sidebar avatar. The slot's width is `toolbar-logo`, not `shell-rail` — pinned
 * to the full rail it stranded the wordmark ~150px from the first nav label,
 * which read as a gap rather than as alignment. The nav row therefore starts
 * ahead of the content grid by design; see `--spacing-toolbar-logo`.
 *
 * The slot is a fixed width even while the sidebar is collapsed: following the
 * rail would reflow the toolbar every frame — which means `useNavOverflow`
 * re-measuring the mega-menu mid-animation. A still toolbar with the rail
 * tucking away beneath it is both calmer and cheaper.
 *
 * The mega-menu, its scrim, and the overflow logic all live in `NavMegaMenu`.
 */
function Navbar() {
	const scrolled = useScrolledNav()

	return (
		<>
			{/* Fixed 80px white-chrome bar, desktop only. Solid at all times — the
			    canvas below is deliberately duller than the chrome, so garp.org's
			    transparent-at-rest look would read as a colour mismatch against
			    the white sidebar. The hairline frames the content panel; the
			    scroll signal survives as the shadow lift. */}
			<header
				className={cn(
					"fixed top-0 right-0 left-0 z-[1000] box-border hidden h-20 max-w-[100vw] items-center border-b border-border bg-toolbar text-toolbar-foreground transition-shadow duration-200 app:flex",
					scrolled && "shadow-xs",
				)}
			>
				{/* Inset to the sidebar avatar; width is the toolbar's own, not the rail's.
				    The slot is a plain div and only the logo is the link — an anchor
				    spanning the whole slot puts a clickable dead zone between the
				    wordmark and the first nav trigger. */}
				<div className="flex w-toolbar-logo shrink-0 items-center pl-shell-inset">
					<a href="https://www.garp.org/" className="flex items-center">
						<GarpLogoMark className="h-auto w-[125px]" />
					</a>
				</div>

				<NavMegaMenu />

				<div className="flex shrink-0 items-center gap-1 pr-shell-gutter">
					{/* The minimised alert parks here. It holds its slot for as long
					    as an alert exists so the card has a stable rect to fly to. */}
					<AlertBarTrigger placement="desktop" />
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
