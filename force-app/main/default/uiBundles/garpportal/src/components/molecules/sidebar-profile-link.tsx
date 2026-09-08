import { animated } from "@react-spring/web"
import { Link, useLocation } from "@tanstack/react-router"
import { User } from "lucide-react"

import { Avatar, AvatarFallback, AvatarImage } from "@/components/atoms/avatar"
import {
	Tooltip,
	TooltipContent,
	TooltipTrigger,
} from "@/components/atoms/tooltip"
import { DEFAULT_MY_ACCOUNT_TAB } from "@/config/my-account"
import type { SidebarLabelStyle } from "@/hooks/use-sidebar-collapse"
import { isRouteActive } from "@/lib/route-active"
import { resolvePortalAssetUrl } from "@/lib/resolve-portal-asset-url"
import { cn } from "@/lib/utils"

type SidebarProfileLinkProps = {
	name: string
	garpId: string
	avatarUrl?: string
	/** Desktop sidebar uses uppercase; mobile Account list matches live title case. */
	uppercase?: boolean
	/**
	 * Supplied when a sliding indicator is measuring this row (desktop sidebar).
	 * Its presence also means the row must not paint its own active background.
	 * The mobile Account list has no indicator, so it keeps painting its own.
	 */
	registerRef?: (node: HTMLAnchorElement | null) => void
	/** Starts the active rail moving on press, before the route work begins. */
	onSelect?: () => void
	/**
	 * Desktop sidebar renders inset rounded rows; the mobile Account list keeps
	 * the full-bleed row it shares with the rest of that sheet.
	 */
	inset?: boolean
	/**
	 * Desktop rail only: name and GARP ID are behind the collapsed edge, so the
	 * avatar borrows a tooltip carrying both. Absent in the mobile panel.
	 */
	collapsed?: boolean
	/** Desktop rail only: animated label styles from `useSidebarCollapse`. */
	labelStyle?: SidebarLabelStyle
}

function SidebarProfileLink({
	name,
	garpId,
	avatarUrl,
	uppercase = true,
	registerRef,
	onSelect,
	inset = false,
	collapsed = false,
	labelStyle,
}: SidebarProfileLinkProps) {
	const { pathname } = useLocation()
	const isActive = isRouteActive(pathname, "/my-account")
	const resolvedAvatarUrl = resolvePortalAssetUrl(avatarUrl)

	const avatar = (
		<Avatar className="size-11 shrink-0 self-center overflow-hidden rounded-full">
			<AvatarImage
				src={resolvedAvatarUrl}
				alt={name}
				width={44}
				height={44}
				decoding="async"
				className="size-full object-cover"
			/>
			{/*
			 * Matches SidebarNavLink's puck exactly: bare while inactive, filled
			 * `bg-primary` when active — this row is one of the nav rows and must
			 * carry the same selected state as the ones under it. The glyph itself
			 * is the frameless `User` bust rather than `CircleUser`, so the only
			 * circle on screen is the shared active puck, not a second outline
			 * drawn inside it. A real avatar photo still fills the circle.
			 */}
			<AvatarFallback
				className={cn(
					"bg-transparent",
					isActive
						? "bg-primary text-primary-foreground"
						: "text-muted-foreground",
				)}
			>
				{/* Same 22px as SidebarNavLink's icons — a bare glyph reads larger
				    than a framed one, so matching their box keeps the column even. */}
				<User className="size-[22px]" aria-hidden />
			</AvatarFallback>
		</Avatar>
	)

	return (
		<Link
			ref={registerRef}
			to="/my-account"
			search={{ tab: DEFAULT_MY_ACCOUNT_TAB }}
			onPointerDown={onSelect}
			className={cn(
				"flex items-center gap-4 transition-colors",
				inset ? "rounded-xl px-3 py-4" : "px-6 py-5",
				isActive
					? "bg-accent text-accent-foreground"
					: "text-foreground hover:bg-background/60",
			)}
		>
			{/*
			 * items-center on the row prevents flex stretch turning size-11 into a
			 * rectangle. The tooltip anchors here rather than to the row: the row stays
			 * 294px wide while collapsed so its labels never reflow, which would put
			 * a row-anchored tooltip far off the rail's visible edge.
			 */}
			{collapsed ? (
				<Tooltip>
					<TooltipTrigger asChild>{avatar}</TooltipTrigger>
					<TooltipContent side="right">
						<span className="flex flex-col leading-tight">
							<span className="font-bold">{name}</span>
							<span className="opacity-70">(GARP ID {garpId})</span>
						</span>
					</TooltipContent>
				</Tooltip>
			) : (
				avatar
			)}
			{/*
			 * `flex-1 min-w-0` is what lets the two lines truncate: without it the
			 * column sizes to its text and a long name wraps onto a second line,
			 * making the row taller than every nav row under it (and taller than
			 * the skeleton it replaces). `title` gives the full name back on hover,
			 * since the collapsed tooltip is not available while expanded.
			 */}
			<animated.span
				className="flex min-w-0 flex-1 flex-col leading-tight"
				style={labelStyle}
			>
				<span
					title={name}
					className={cn(
						"truncate font-bold tracking-wide",
						uppercase && "uppercase",
					)}
				>
					{name}
				</span>
				<span
					className={cn(
						"truncate text-sm",
						isActive ? "text-accent-foreground/80" : "text-muted-foreground",
					)}
				>
					(GARP ID {garpId})
				</span>
			</animated.span>
		</Link>
	)
}

export { SidebarProfileLink }
