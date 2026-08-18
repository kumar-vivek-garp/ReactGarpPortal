import { Link, useLocation } from "@tanstack/react-router"
import { CircleUser } from "lucide-react"

import { Avatar, AvatarFallback, AvatarImage } from "@/components/atoms/avatar"
import { DEFAULT_MY_ACCOUNT_TAB } from "@/config/my-account"
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
}

function SidebarProfileLink({
	name,
	garpId,
	avatarUrl,
	uppercase = true,
	registerRef,
	onSelect,
	inset = false,
}: SidebarProfileLinkProps) {
	const { pathname } = useLocation()
	const isActive = isRouteActive(pathname, "/my-account")
	const resolvedAvatarUrl = resolvePortalAssetUrl(avatarUrl)

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
			{/* items-center on the row prevents flex stretch turning size-11 into an oval */}
			<Avatar className="size-11 shrink-0 self-center overflow-hidden rounded-full">
				<AvatarImage
					src={resolvedAvatarUrl}
					alt={name}
					width={44}
					height={44}
					decoding="async"
					className="size-full object-cover"
				/>
				<AvatarFallback
					className={cn(
						isActive
							? "bg-primary text-primary-foreground"
							: "bg-border text-muted-foreground",
					)}
				>
					<CircleUser className="size-7" aria-hidden />
				</AvatarFallback>
			</Avatar>
			<span className="flex min-w-0 flex-col leading-tight">
				<span className={cn("font-bold tracking-wide", uppercase && "uppercase")}>
					{name}
				</span>
				<span
					className={cn(
						"text-sm",
						isActive ? "text-accent-foreground/80" : "text-muted-foreground",
					)}
				>
					(GARP ID {garpId})
				</span>
			</span>
		</Link>
	)
}

export { SidebarProfileLink }
