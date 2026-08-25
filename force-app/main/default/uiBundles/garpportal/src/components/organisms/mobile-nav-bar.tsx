import { useEffect } from "react"
import { animated, useTransition } from "@react-spring/web"
import { ChevronLeft } from "lucide-react"

import { GarpLogoMark } from "@/components/atoms/garp-logo-mark"
import { AlertBarTrigger } from "@/components/molecules/alert-bar-trigger"
import { MegaMenuPanel } from "@/components/molecules/mega-menu-panel"
import { MobileMenuIcon } from "@/components/molecules/mobile-menu-icon"
import { MobileNavPanel } from "@/components/molecules/mobile-nav-panel"
import { ThemeToggle } from "@/components/molecules/theme-toggle"
import { useBodyScrollLock } from "@/hooks/use-body-scroll-lock"
import { useCloseMobileNavOnNavigate } from "@/hooks/use-close-mobile-nav-on-navigate"
import { TOP_NAV_ITEMS } from "@/config/navigation/top-nav-items"
import { NAV_PANEL_SPRING } from "@/lib/nav-spring"
import { cn } from "@/lib/utils"
import { useNavigationStore } from "@/store/navigation-store"

const ROOT_KEY = "root"
/** How far the outgoing view trails behind an incoming one, as a percentage. */
const PUSH_PARALLAX = 30
/** The view being pushed away dims rather than disappearing. */
const PUSH_DIM = 0.35

/**
 * Mobile toolbar (< 960px) and its full-screen menu.
 *
 * Drill-down is a real push: the incoming view slides in from the right while
 * the outgoing one parallaxes left and dims *at the same time*. Running them in
 * sequence — which is what `exitBeforeEnter` did here before — reads as two
 * unrelated fades rather than one navigation gesture.
 */
function MobileNavBar() {
	const isOpen = useNavigationStore((state) => state.isMobileNavOpen)
	const selectedItem = useNavigationStore((state) => state.mobileSelectedNavItem)
	const openMobileNav = useNavigationStore((state) => state.openMobileNav)
	const closeMobileNav = useNavigationStore((state) => state.closeMobileNav)
	const openMobileNavItem = useNavigationStore((state) => state.openMobileNavItem)
	const backToMobileRoot = useNavigationStore((state) => state.backToMobileRoot)

	useCloseMobileNavOnNavigate()
	useBodyScrollLock(isOpen)

	const panelTransitions = useTransition(isOpen, {
		from: { opacity: 0, y: -12 },
		enter: { opacity: 1, y: 0 },
		leave: { opacity: 0, y: -8 },
		config: NAV_PANEL_SPRING,
	})

	const drillKey = selectedItem?.title ?? ROOT_KEY
	const goingBack = drillKey === ROOT_KEY
	const drillTransitions = useTransition(drillKey, {
		from: { x: goingBack ? -PUSH_PARALLAX : 100, opacity: goingBack ? PUSH_DIM : 1 },
		enter: { x: 0, opacity: 1 },
		leave: { x: goingBack ? 100 : -PUSH_PARALLAX, opacity: goingBack ? 1 : PUSH_DIM },
		config: NAV_PANEL_SPRING,
	})

	useEffect(() => {
		if (!isOpen) return
		function onKeyDown(event: KeyboardEvent) {
			if (event.key !== "Escape") return
			if (selectedItem) backToMobileRoot()
			else closeMobileNav()
		}
		window.addEventListener("keydown", onKeyDown)
		return () => window.removeEventListener("keydown", onKeyDown)
	}, [isOpen, selectedItem, closeMobileNav, backToMobileRoot])

	return (
		<div className="fixed top-0 right-0 left-0 z-[1000] box-border w-full max-w-[100vw] bg-background pt-[env(safe-area-inset-top)] app:hidden">
			<header
				className={cn(
					"relative z-[1001] flex h-16 w-full items-center justify-between px-5",
					isOpen ? "bg-background text-foreground" : "bg-toolbar text-toolbar-foreground",
				)}
			>
				{/* Inherits the bar's own text colour, so it works black-on-white and
				    white-on-black without swapping assets. */}
				<GarpLogoMark className="h-8 w-auto shrink-0" />
				<div className="flex shrink-0 items-center gap-1">
					{/* Restoring from inside the open menu would drop the card
					    behind the full-screen panel, so it closes first. */}
					<AlertBarTrigger
						placement="mobile"
						variant={isOpen ? "sheet" : "toolbar"}
						onActivate={closeMobileNav}
					/>
					<ThemeToggle variant={isOpen ? "sheet" : "toolbar"} />
					<button
						type="button"
						className={cn(
							"flex size-11 cursor-pointer items-center justify-center rounded-xl border-0 bg-transparent",
							isOpen
								? "text-foreground hover:bg-muted"
								: "text-toolbar-foreground hover:bg-toolbar-foreground/10",
						)}
						aria-label={isOpen ? "Close menu" : "Open menu"}
						aria-expanded={isOpen}
						onClick={() => (isOpen ? closeMobileNav() : openMobileNav())}
					>
						<MobileMenuIcon open={isOpen} />
					</button>
				</div>
			</header>

			{panelTransitions((style, show) =>
				show ? (
					<animated.div
						className="fixed right-0 bottom-0 left-0 z-[1000] overflow-hidden bg-background"
						style={{
							opacity: style.opacity,
							transform: style.y.to((y) => `translateY(${y}px)`),
							top: "calc(4rem + env(safe-area-inset-top, 0px))",
							pointerEvents: isOpen ? "auto" : "none",
						}}
					>
						<div className="relative size-full">
							{drillTransitions((drillStyle, key) => {
								const item =
									key === ROOT_KEY
										? null
										: (TOP_NAV_ITEMS.find((entry) => entry.title === key) ?? null)

								return (
									<animated.div
										className="absolute inset-0 overflow-x-hidden overflow-y-auto bg-background"
										style={{
											opacity: drillStyle.opacity,
											transform: drillStyle.x.to((x) => `translateX(${x}%)`),
										}}
									>
										{item ? (
											<>
												<div className="sticky top-0 z-10 flex items-center gap-2 border-b border-border bg-background px-3 py-2.5">
													<button
														type="button"
														className="inline-flex cursor-pointer items-center gap-1 rounded-xl px-2 py-1.5 text-body font-bold text-primary hover:bg-accent hover:text-accent-foreground"
														onClick={backToMobileRoot}
													>
														<ChevronLeft className="size-5" strokeWidth={2.5} />
														Back
													</button>
													<span className="truncate text-base font-extrabold text-foreground">
														{item.title}
													</span>
												</div>
												<div className="px-5 pt-5 pb-[calc(2.5rem+env(safe-area-inset-bottom,0px))]">
													<MegaMenuPanel item={item} variant="mobile" />
												</div>
											</>
										) : (
											<MobileNavPanel onBrowse={openMobileNavItem} />
										)}
									</animated.div>
								)
							})}
						</div>
					</animated.div>
				) : null,
			)}
		</div>
	)
}

export { MobileNavBar }
