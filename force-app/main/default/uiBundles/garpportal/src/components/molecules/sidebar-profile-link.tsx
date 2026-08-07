import { Link, useLocation } from "@tanstack/react-router"

import { Avatar, AvatarFallback, AvatarImage } from "@/components/atoms/avatar"
import { MaterialSymbol } from "@/components/atoms/material-symbol"
import { cn } from "@/lib/utils"

type SidebarProfileLinkProps = {
	name: string
	garpId: string
	avatarUrl?: string
	/** Desktop sidebar uses uppercase; mobile Account list matches live title case. */
	uppercase?: boolean
}

function SidebarProfileLink({
	name,
	garpId,
	avatarUrl,
	uppercase = true,
}: SidebarProfileLinkProps) {
	const { pathname } = useLocation()
	const isActive = pathname === "/my-account" || pathname.startsWith("/my-account/")

	return (
		<Link
			to="/my-account"
			className={cn(
				"flex items-center gap-4 px-6 py-5",
				isActive ? "bg-accent text-accent-foreground" : "text-foreground hover:bg-background/50"
			)}
		>
			<Avatar className="size-11">
				<AvatarImage src={avatarUrl} alt={name} />
				<AvatarFallback
					className={cn(
						isActive ? "bg-primary text-primary-foreground" : "bg-border text-dark-blue-gray"
					)}
				>
					{/* Live SideNavbar noAvatar fallback uses mat-icon account_circle */}
					<MaterialSymbol name="account_circle" className="text-[28px]" />
				</AvatarFallback>
			</Avatar>
			<span className="flex flex-col leading-tight">
				<span className={cn("font-bold tracking-wide", uppercase && "uppercase")}>{name}</span>
				<span className={cn("text-sm", isActive ? "text-accent-foreground/80" : "text-muted-foreground")}>
					(GARP ID {garpId})
				</span>
			</span>
		</Link>
	)
}

export { SidebarProfileLink }
