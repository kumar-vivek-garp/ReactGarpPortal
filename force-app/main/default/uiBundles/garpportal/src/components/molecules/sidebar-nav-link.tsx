import { Link, useLocation } from "@tanstack/react-router"
import type { LucideIcon } from "lucide-react"

import { cn } from "@/lib/utils"
import type { AppRoute } from "@/config/navigation/types"

type SidebarNavLinkProps = {
	to: AppRoute
	label: string
	icon: LucideIcon
}

function SidebarNavLink({ to, label, icon: Icon }: SidebarNavLinkProps) {
	const { pathname } = useLocation()
	const isActive = pathname === to || pathname.startsWith(`${to}/`)

	return (
		<Link
			to={to}
			className={cn(
				"flex items-center gap-4 px-6 py-4 text-sm font-bold tracking-wide uppercase",
				isActive ? "bg-accent text-accent-foreground" : "text-foreground hover:bg-background/50"
			)}
		>
			<span
				className={cn(
					"flex size-11 shrink-0 items-center justify-center rounded-full",
					isActive ? "bg-primary text-primary-foreground" : "bg-border text-dark-blue-gray"
				)}
			>
				<Icon className="size-[22px]" aria-hidden />
			</span>
			{label}
		</Link>
	)
}

export { SidebarNavLink }
