import { useEffect } from "react"
import { Link } from "@tanstack/react-router"
import { animated, useSpring, useTransition } from "@react-spring/web"
import { ChevronDown, ChevronLeft, Menu, X } from "lucide-react"

import { MegaMenuPanel } from "@/components/molecules/mega-menu-panel"
import { SidebarProfileLink } from "@/components/molecules/sidebar-profile-link"
import { SidebarProfileSkeleton } from "@/components/molecules/sidebar-profile-skeleton"
import { SignOutButton } from "@/components/molecules/sign-out-button"
import { ThemeToggle } from "@/components/molecules/theme-toggle"
import { useCloseMobileNavOnNavigate } from "@/hooks/use-close-mobile-nav-on-navigate"
import { useCurrentUser } from "@/hooks/use-current-user"
import { useHasCpdProgram } from "@/hooks/use-has-cpd-program"
import { GARP_LOGO_COLOR, GARP_LOGO_KNOCKOUT } from "@/config/navigation/garp-logos"
import { sideNavItems } from "@/config/navigation/side-nav-items"
import { TOP_NAV_ITEMS } from "@/config/navigation/top-nav-items"
import { cn } from "@/lib/utils"
import { useNavigationStore } from "@/store/navigation-store"

const PANEL_SPRING = { mass: 0.85, tension: 300, friction: 28 }
const DRILL_SPRING = { mass: 0.8, tension: 340, friction: 28 }

function MobileNavBar() {
	const { data: user, isPending } = useCurrentUser()
	const showProfileSkeleton = isPending && !user
	const displayName = user?.name?.trim() || "GARP Member"
	const navItems = sideNavItems({ includeCpd: useHasCpdProgram() })
	const isOpen = useNavigationStore((state) => state.isMobileNavOpen)
	const selectedItem = useNavigationStore((state) => state.mobileSelectedNavItem)
	const openMobileNav = useNavigationStore((state) => state.openMobileNav)
	const closeMobileNav = useNavigationStore((state) => state.closeMobileNav)
	const openMobileNavItem = useNavigationStore((state) => state.openMobileNavItem)
	const backToMobileRoot = useNavigationStore((state) => state.backToMobileRoot)
	useCloseMobileNavOnNavigate()

	const panelTransitions = useTransition(isOpen, {
		from: { opacity: 0, transform: "translateY(-16px)" },
		enter: { opacity: 1, transform: "translateY(0px)" },
		leave: { opacity: 0, transform: "translateY(-12px)" },
		config: PANEL_SPRING,
	})

	const drillKey = selectedItem?.title ?? "root"
	const drillTransitions = useTransition(drillKey, {
		from: { opacity: 0, transform: "translateX(24px)" },
		enter: { opacity: 1, transform: "translateX(0px)" },
		leave: { opacity: 0, transform: "translateX(-16px)" },
		config: DRILL_SPRING,
		exitBeforeEnter: true,
	})

	const menuIconSpring = useSpring({
		rotate: isOpen ? 90 : 0,
		config: PANEL_SPRING,
	})

	useEffect(() => {
		if (!isOpen) return
		const previousOverflow = document.body.style.overflow
		const previousPosition = document.body.style.position
		const previousWidth = document.body.style.width
		const previousHeight = document.body.style.height
		document.body.style.overflow = "hidden"
		document.body.style.position = "fixed"
		document.body.style.width = "100%"
		document.body.style.height = "100%"
		return () => {
			document.body.style.overflow = previousOverflow
			document.body.style.position = previousPosition
			document.body.style.width = previousWidth
			document.body.style.height = previousHeight
		}
	}, [isOpen])

	useEffect(() => {
		if (!isOpen) return
		function onKeyDown(event: KeyboardEvent) {
			if (event.key === "Escape") {
				if (selectedItem) backToMobileRoot()
				else closeMobileNav()
			}
		}
		window.addEventListener("keydown", onKeyDown)
		return () => window.removeEventListener("keydown", onKeyDown)
	}, [isOpen, selectedItem, closeMobileNav, backToMobileRoot])

	return (
		<div className="fixed top-0 right-0 left-0 z-[1000] box-border w-full max-w-[100vw] bg-background pt-[env(safe-area-inset-top)] app:hidden">
			<header
				className={cn(
					"relative z-[1001] flex min-h-16 w-full items-center",
					isOpen ? "bg-background" : "bg-toolbar text-toolbar-foreground"
				)}
			>
				<div className="flex w-full max-w-full items-center justify-between">
					<img
						src={isOpen ? GARP_LOGO_COLOR : GARP_LOGO_KNOCKOUT}
						alt="GARP logo"
						className="box-border inline-block w-[200px] max-w-[60%] shrink-0 p-5"
					/>
					<div className="mr-3 flex shrink-0 items-center gap-0.5">
						<ThemeToggle variant={isOpen ? "sheet" : "toolbar"} />
						<button
							type="button"
							className={cn(
								"mr-3 flex size-11 items-center justify-center rounded-[10px] border-0 bg-transparent",
								isOpen ? "text-foreground hover:bg-muted" : "text-toolbar-foreground hover:bg-white/10"
							)}
							aria-label={isOpen ? "Close menu" : "Open menu"}
							aria-expanded={isOpen}
							onClick={() => (isOpen ? closeMobileNav() : openMobileNav())}
						>
							<animated.span
								className="inline-flex"
								style={{
									transform: menuIconSpring.rotate.to((rotate) => `rotate(${rotate}deg)`),
								}}
							>
								{isOpen ? <X className="size-6" strokeWidth={2.25} /> : <Menu className="size-6" strokeWidth={2.25} />}
							</animated.span>
						</button>
					</div>
				</div>
			</header>

			{panelTransitions((style, show) =>
				show ? (
					<animated.div
						className="fixed right-0 bottom-0 left-0 z-[1000] flex max-h-[calc(100dvh-4rem-env(safe-area-inset-top))] w-screen max-w-[100vw] flex-col overflow-x-hidden overflow-y-auto bg-background"
						style={{
							...style,
							top: "calc(4rem + env(safe-area-inset-top, 0px))",
							pointerEvents: isOpen ? "auto" : "none",
						}}
					>
						{drillTransitions((drillStyle, key) => {
							const drillItem =
								key === "root" ? null : (TOP_NAV_ITEMS.find((item) => item.title === key) ?? null)

							return (
								<animated.div key={key} className="min-h-full w-full" style={drillStyle}>
									{drillItem ? (
										<div className="px-4 pt-3 pb-8">
											<button
												type="button"
												className="mb-4 inline-flex items-center gap-1.5 rounded-[10px] px-2 py-2 text-body font-bold text-primary hover:bg-accent"
												onClick={backToMobileRoot}
											>
												<ChevronLeft className="size-5" strokeWidth={2.5} />
												Back
											</button>
											<MegaMenuPanel item={drillItem} variant="mobile" />
										</div>
									) : (
										<>
											<nav className="flex flex-col pt-2">
												<div className="px-2">
													{showProfileSkeleton ? (
														<SidebarProfileSkeleton />
													) : (
														<SidebarProfileLink
															name={displayName}
															garpId={user?.garpId?.trim() || "—"}
															avatarUrl={user?.photoUrl ?? undefined}
															uppercase={false}
														/>
													)}
												</div>
												{navItems.map(({ to, label, icon: Icon }) => (
													<Link
														key={to}
														to={to}
														className="flex items-center gap-4 border-b border-border px-6 py-3.5 text-base text-foreground last:border-b-0 active:bg-accent/60"
													>
														<Icon
															className="size-[22px] shrink-0 text-muted-foreground"
															aria-hidden
														/>
														{label}
													</Link>
												))}
											</nav>
											<div className="p-[18px]">
												<SignOutButton size="default" />
											</div>
											<p className="mt-1 px-[30px] pt-2 pb-1 text-xl leading-tight font-extrabold text-foreground">
												Browse &amp; Explore
											</p>
											<div className="mx-auto mt-3 mb-2 w-[96%] border-t-2 border-border" />
											<nav className="flex flex-col pb-10">
												{TOP_NAV_ITEMS.map((item) => (
													<button
														key={item.title}
														type="button"
														className="flex w-full items-center justify-between border-b border-border px-6 py-4 text-left text-base font-medium text-foreground active:bg-accent/60"
														onClick={() => openMobileNavItem(item)}
													>
														{item.title}
														<span className="inline-flex size-7 shrink-0 items-center justify-center rounded-full bg-primary text-primary-foreground">
															<ChevronDown className="size-4 -rotate-90" strokeWidth={2.5} />
														</span>
													</button>
												))}
											</nav>
										</>
									)}
								</animated.div>
							)
						})}
					</animated.div>
				) : null
			)}
		</div>
	)
}

export { MobileNavBar }
