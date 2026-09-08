import { useMemo, useState } from "react"
import { animated } from "@react-spring/web"
import { useLocation } from "@tanstack/react-router"

import { SidebarCollapseToggle } from "@/components/molecules/sidebar-collapse-toggle"
import { SidebarNavLink } from "@/components/molecules/sidebar-nav-link"
import { SidebarProfileLink } from "@/components/molecules/sidebar-profile-link"
import { SidebarProfileSkeleton } from "@/components/molecules/sidebar-profile-skeleton"
import { useCurrentUser } from "@/hooks/use-current-user"
import { useHasCpdProgram } from "@/hooks/use-has-cpd-program"
import { useSidebarCollapse } from "@/hooks/use-sidebar-collapse"
import { useSlidingIndicator } from "@/hooks/use-sliding-indicator"
import { sideNavItems } from "@/config/navigation/side-nav-items"
import { activeRouteKey, isRouteActive } from "@/lib/route-active"

const PROFILE_ROUTE = "/my-account" as const

/** Referenced by the collapse toggle's `aria-controls`. */
const RAIL_ID = "app-sidebar-rail"

type PendingSelection = { key: string; from: string }

function AppSidebar({ forceSkeleton = false }: { forceSkeleton?: boolean }) {
	const { data: user, isPending } = useCurrentUser()
	const { pathname } = useLocation()
	const showSkeleton = forceSkeleton || (isPending && !user)
	const displayName = user?.name?.trim() || "GARP Member"

	/*
	 * Also shown while actually on /cpd, so a cold deep-link does not render a
	 * rail with no active row until `programs` lands. Covers /cpd/* too —
	 * `isRouteActive` matches on segment boundaries.
	 */
	const hasCpd = useHasCpdProgram()
	const showCpd = hasCpd || isRouteActive(pathname, "/cpd")

	const navItems = useMemo(
		() => sideNavItems({ includeCpd: showCpd }),
		[showCpd],
	)
	/** Rows the rail can land on, in visual order. */
	const railRoutes = useMemo(
		() => [PROFILE_ROUTE, ...navItems.map((item) => item.to)],
		[navItems],
	)

	/**
	 * Collapsing is a width-only change: every row's height and vertical offset
	 * is set by its 44px puck, and the collapsed width is derived so that puck
	 * keeps the same left edge. So the sliding rail below needs to know nothing
	 * about it — its measurements are identical in both states.
	 */
	const { isCollapsed, toggle, widthStyle, labelStyle } = useSidebarCollapse()

	/**
	 * Rendering a new route blocks the main thread for tens of milliseconds, which
	 * would starve the rail's frames mid-travel. So the target is claimed on
	 * pointer-down — the glide starts while the thread is still idle and is mostly
	 * done by the time routing work lands.
	 *
	 * `from` records where the press happened, so the claim expires by itself once
	 * the pathname moves on. No effect, no cleanup, and a browser Back cannot be
	 * overridden by a stale claim.
	 */
	const [pending, setPending] = useState<PendingSelection | null>(null)
	const activeRoute = activeRouteKey(pathname, railRoutes)
	const claimed = pending?.from === pathname ? pending.key : null
	const railValue = claimed ?? activeRoute

	const { containerRef, registerRef, indicatorStyle } =
		useSlidingIndicator<HTMLDivElement>({
			axis: "y",
			// Transform-only. The rail is a plain 3px bar with no radius, so scaling
			// costs no layout or paint per frame and cannot distort a corner.
			technique: "scale",
			// The profile row is absent while the user loads, so nothing to land on.
			value: showSkeleton && railValue === PROFILE_ROUTE ? null : railValue,
			// Changing this re-measures every row, which is exactly what has to
			// happen when the CPD row appears or disappears mid-session.
			itemsKey: railRoutes.join("|"),
		})

	const claim = (key: string) => setPending({ key, from: pathname })

	return (
		/*
		 * Two elements, because they need different overflow: this wrapper animates
		 * the width and hosts the toggle, which straddles the rail's right edge and
		 * so must be free to overhang; the aside inside it does the clipping. One
		 * element cannot do both — it would slice the toggle in half.
		 *
		 * `relative` establishes the positioned ancestor the toggle resolves
		 * against. It used to be `sticky top-20` doing that job, back when the
		 * document scrolled and the rail had to hold itself against it; the shell
		 * now frames the viewport and hands the overflow to the main column
		 * (`lib/app-scroll.ts`), so the rail simply fills its row and never moves.
		 *
		 * `z-40` is load-bearing, not spare headroom. The collapse toggle
		 * overhangs 16px into the main column, and that strip is exactly what a
		 * pinned page header covers: `PAGE_STICKY_HEADER` is opaque and bleeds
		 * `-mx-shell-gutter` over the container's gutter. The rail therefore has
		 * to outrank everything the main column can pin — page headers at `z-20`,
		 * the registration submit bar at `z-30` — or the pill loses its outer
		 * half to whichever of them renders later in the DOM. It stays below the
		 * toolbar (`z-[1000]`), which is what keeps the pill's top edge honest.
		 */
		<animated.div
			style={widthStyle}
			className="relative z-40 hidden h-full shrink-0 will-change-[width] app:block"
		>
			{/*
			 * `overflow-x-hidden` is load-bearing, not tidiness: `overflow-y-auto`
			 * alone makes CSS compute overflow-x to `auto`, and the content below is
			 * deliberately wider than the panel while collapsed.
			 */}
			<aside
				id={RAIL_ID}
				className="flex h-full w-full flex-col overflow-x-hidden overflow-y-auto border-r border-sidebar-border bg-sidebar"
			>
				{/*
				 * Held at the full expanded width so labels are clipped by the panel's
				 * travelling edge rather than reflowing, re-wrapping, or squeezing
				 * their glyphs while the width animates.
				 */}
				<div
					ref={containerRef}
					className="relative flex w-shell-rail flex-col gap-1 p-3"
				>
					{/*
					 * The only element that moves. A 3px bar in the gutter reads as a quiet
					 * marker rather than a travelling block, and at that width a dropped
					 * frame during navigation is essentially invisible.
					 */}
					<animated.span
						className="pointer-events-none absolute left-0 top-0 w-[3px] origin-top bg-primary will-change-transform"
						style={indicatorStyle}
						aria-hidden
					/>

					{showSkeleton ? (
						<SidebarProfileSkeleton inset labelStyle={labelStyle} />
					) : (
						<SidebarProfileLink
							name={displayName}
							garpId={user?.garpId?.trim() || "—"}
							avatarUrl={user?.photoUrl ?? undefined}
							inset
							registerRef={(node) => registerRef(PROFILE_ROUTE, node)}
							onSelect={() => claim(PROFILE_ROUTE)}
							collapsed={isCollapsed}
							labelStyle={labelStyle}
						/>
					)}

					<nav className="flex flex-col gap-1">
						{navItems.map(({ to, label, icon }) => (
							<SidebarNavLink
								key={to}
								to={to}
								label={label}
								icon={icon}
								registerRef={(node) => registerRef(to, node)}
								onSelect={() => claim(to)}
								collapsed={isCollapsed}
								labelStyle={labelStyle}
							/>
						))}
					</nav>
				</div>
			</aside>

			<SidebarCollapseToggle
				collapsed={isCollapsed}
				onToggle={toggle}
				controls={RAIL_ID}
			/>
		</animated.div>
	)
}

export { AppSidebar }
