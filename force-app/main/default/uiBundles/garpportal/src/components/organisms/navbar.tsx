import { useEffect } from "react"
import { animated, useSpring } from "@react-spring/web"
import { LogOut } from "lucide-react"

import { Button } from "@/components/atoms/button"
import { MobileNavBar } from "@/components/molecules/mobile-nav-sheet"
import { NavMegaMenuItem } from "@/components/molecules/nav-mega-menu-item"
import { GARP_LOGO_KNOCKOUT } from "@/lib/navigation/garp-logos"
import { TOP_NAV_ITEMS } from "@/lib/navigation/top-nav-items"
import { useNavigationStore } from "@/store/navigation-store"

function Navbar() {
	const openDesktopNavTitle = useNavigationStore((state) => state.openDesktopNavTitle)
	const closeDesktopNav = useNavigationStore((state) => state.closeDesktopNav)
	const scheduleCloseDesktopNav = useNavigationStore((state) => state.scheduleCloseDesktopNav)
	const isDesktopNavOpen = Boolean(openDesktopNavTitle)

	const overlaySpring = useSpring({
		opacity: isDesktopNavOpen ? 1 : 0,
		config: { mass: 0.9, tension: 320, friction: 26 },
	})

	useEffect(() => {
		if (!openDesktopNavTitle) return
		function onKeyDown(event: KeyboardEvent) {
			if (event.key === "Escape") closeDesktopNav()
		}
		window.addEventListener("keydown", onKeyDown)
		return () => window.removeEventListener("keydown", onKeyDown)
	}, [openDesktopNavTitle, closeDesktopNav])

	return (
		<>
			{/* Desktop toolbar — mirrors live app-desktop-nav-bar (fixed 80px black bar). */}
			<header className="fixed top-0 right-0 left-0 z-[1000] box-border hidden h-20 max-w-[100vw] items-center bg-toolbar text-toolbar-foreground app:flex">
				<a href="https://www.garp.org/" className="mr-[25px] ml-[38px] shrink-0">
					<img src={GARP_LOGO_KNOCKOUT} alt="GARP logo" className="w-[125px]" />
				</a>

				<nav className="flex min-w-0 flex-1 items-center" aria-label="Primary">
					{TOP_NAV_ITEMS.map((item) => (
						<NavMegaMenuItem key={item.title} item={item} />
					))}
				</nav>

				<div className="ml-auto flex shrink-0 items-center pr-4">
					<Button
						variant="default"
						size="sm"
						className="gap-2 whitespace-nowrap text-body max-[1000px]:px-3 max-[1000px]:text-caption"
					>
						<LogOut className="size-4" />
						Sign Out
					</Button>
				</div>
			</header>

			{/*
			 * Dim overlay — click closes immediately; mouseenter only schedules a close
			 * so crossing the gap into the panel (z-2000 above) can cancel it.
			 */}
			<animated.div
				className="fixed top-20 right-0 bottom-0 left-0 z-[999] hidden bg-black/50 app:block"
				style={{
					...overlaySpring,
					visibility: overlaySpring.opacity.to((opacity) => (opacity > 0.01 ? "visible" : "hidden")),
					pointerEvents: isDesktopNavOpen ? "auto" : "none",
				}}
				onClick={closeDesktopNav}
				onMouseEnter={scheduleCloseDesktopNav}
				aria-hidden="true"
			/>

			{/* Mobile toolbar — mirrors live app-mobile-nav-bar (< 960px). */}
			<MobileNavBar />

			{/* Spacer so page content clears the fixed toolbars. */}
			<div className="h-16 shrink-0 app:h-20" aria-hidden="true" />
		</>
	)
}

export { Navbar }
