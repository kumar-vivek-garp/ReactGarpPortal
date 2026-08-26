import { animated } from "@react-spring/web"
import { Link, useLocation } from "@tanstack/react-router"
import type { LucideIcon } from "lucide-react"

import {
	Tooltip,
	TooltipContent,
	TooltipTrigger,
} from "@/components/atoms/tooltip"
import type { SidebarLabelStyle } from "@/hooks/use-sidebar-collapse"
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
	/**
	 * Desktop rail only: the label is hidden behind the collapsed edge, so the
	 * row borrows a tooltip to say what it is. Absent in the mobile panel.
	 */
	collapsed?: boolean
	/** Desktop rail only: animated label styles from `useSidebarCollapse`. */
	labelStyle?: SidebarLabelStyle
}

/**
 * Inset rounded row. The active surface is painted by the row itself and only
 * cross-fades, so nothing large travels across the sidebar — the sole moving
 * element is the thin rail in the gutter, positioned by `AppSidebar`.
 *
 * Collapsing never moves this row: its 44px puck sits at `--spacing-shell-inset`
 * in both states, and the collapsed rail is sized so that inset still fits. Only
 * the label fades, and it fades via opacity rather than `display` so the row
 * keeps its accessible name while collapsed.
 */
function SidebarNavLink({
	to,
	label,
	icon: Icon,
	uppercase = true,
	registerRef,
	onSelect,
	collapsed = false,
	labelStyle,
}: SidebarNavLinkProps) {
	const { pathname } = useLocation()
	const isActive = isRouteActive(pathname, to)

	/*
	 * Inactive icons are bare — no fill, no ring. A row of filled circles
	 * outweighs the one active puck, and a primary-coloured ring on every item
	 * would spend the brand colour on rows that are not selected. The 44px
	 * container itself stays: the collapse geometry, the tooltip anchor, and
	 * the active fill all hang off it.
	 */
	const puck = (
		<span
			className={cn(
				"flex size-11 shrink-0 items-center justify-center rounded-full transition-colors",
				isActive
					? "bg-primary text-primary-foreground"
					: "text-muted-foreground",
			)}
		>
			<Icon className="size-[22px]" aria-hidden />
		</span>
	)

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
			{/*
			 * The tooltip anchors to the puck, not the row. The row keeps its full
			 * 294px even while collapsed — that is what stops the label reflowing
			 * mid-animation — so anchoring to it would place the tooltip off the
			 * right edge of a width it no longer visibly has. The puck is also the
			 * only part still on screen, so it is what the pointer is actually over.
			 */}
			{collapsed ? (
				<Tooltip>
					<TooltipTrigger asChild>{puck}</TooltipTrigger>
					<TooltipContent side="right">{label}</TooltipContent>
				</Tooltip>
			) : (
				puck
			)}
			<animated.span className="min-w-0" style={labelStyle}>
				{label}
			</animated.span>
		</Link>
	)
}

export { SidebarNavLink }
