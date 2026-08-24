import { Link, useLocation } from "@tanstack/react-router"
import type { LucideIcon } from "lucide-react"

import { isRouteActive } from "@/lib/route-active"
import { cn } from "@/lib/utils"
import type { AppRoute } from "@/config/navigation/types"

type SidebarNavLinkProps = {
	to: AppRoute
	label: string
	icon: LucideIcon
	/** Desktop sidebar uppercases; the mobile panel matches live title case. */
	uppercase?: boolean
	/** Registers the row so the active rail can measure it. */
	registerRef?: (node: HTMLAnchorElement | null) => void
	/** Starts the rail moving on press, before the route work begins. */
	onSelect?: () => void
}

/**
 * Inset rounded row. The active surface is painted by the row itself and only
 * cross-fades, so nothing large travels across the sidebar — the sole moving
 * element is the thin rail in the gutter, positioned by `AppSidebar`.
 */
function SidebarNavLink({
	to,
	label,
	icon: Icon,
	uppercase = true,
	registerRef,
	onSelect,
}: SidebarNavLinkProps) {
	const { pathname } = useLocation()
	const isActive = isRouteActive(pathname, to)

	return (
		<Link
			ref={registerRef}
			to={to}
			onPointerDown={onSelect}
			className={cn(
				"flex items-center gap-4 rounded-xl px-3 py-3 text-sm font-bold tracking-wide transition-colors",
				uppercase && "uppercase",
				isActive
					? "bg-accent text-accent-foreground"
					: "text-foreground hover:bg-background/60",
			)}
		>
			<span
				className={cn(
					"flex size-11 shrink-0 items-center justify-center rounded-full transition-colors",
					isActive
						? "bg-primary text-primary-foreground"
						: "bg-border text-muted-foreground",
				)}
			>
				<Icon className="size-[22px]" aria-hidden />
			</span>
			{label}
		</Link>
	)
}

export { SidebarNavLink }
