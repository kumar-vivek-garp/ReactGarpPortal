import { useMemo, useState } from "react"
import { animated } from "@react-spring/web"
import { useLocation } from "@tanstack/react-router"

import { SidebarNavLink } from "@/components/molecules/sidebar-nav-link"
import { SidebarProfileLink } from "@/components/molecules/sidebar-profile-link"
import { SidebarProfileSkeleton } from "@/components/molecules/sidebar-profile-skeleton"
import { useCurrentUser } from "@/hooks/use-current-user"
import { useHasCpdProgram } from "@/hooks/use-has-cpd-program"
import { useSlidingIndicator } from "@/hooks/use-sliding-indicator"
import { sideNavItems } from "@/config/navigation/side-nav-items"
import { activeRouteKey, isRouteActive } from "@/lib/route-active"

const PROFILE_ROUTE = "/my-account" as const

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
		<aside className="sticky top-20 hidden h-[calc(100vh-5rem)] w-shell-rail shrink-0 flex-col self-start overflow-y-auto bg-linear-to-b from-surface-gradient-start to-surface-gradient-end app:flex">
			<div ref={containerRef} className="relative flex flex-col gap-1 p-3">
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
					<SidebarProfileSkeleton inset />
				) : (
					<SidebarProfileLink
						name={displayName}
						garpId={user?.garpId?.trim() || "—"}
						avatarUrl={user?.photoUrl ?? undefined}
						inset
						registerRef={(node) => registerRef(PROFILE_ROUTE, node)}
						onSelect={() => claim(PROFILE_ROUTE)}
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
						/>
					))}
				</nav>
			</div>
		</aside>
	)
}

export { AppSidebar }
