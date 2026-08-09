import { SidebarNavLink } from "@/components/molecules/sidebar-nav-link"
import { SidebarProfileLink } from "@/components/molecules/sidebar-profile-link"
import { SidebarProfileSkeleton } from "@/components/molecules/sidebar-profile-skeleton"
import { useCurrentUser } from "@/hooks/use-current-user"
import { SIDE_NAV_ITEMS } from "@/config/navigation/side-nav-items"

function AppSidebar({ forceSkeleton = false }: { forceSkeleton?: boolean }) {
	const { data: user, isPending } = useCurrentUser()
	const showSkeleton = forceSkeleton || (isPending && !user)
	const displayName = user?.name?.trim() || "GARP Member"

	return (
		<aside className="sticky top-20 hidden h-[calc(100vh-5rem)] w-[294px] shrink-0 flex-col self-start overflow-y-auto bg-linear-to-b from-surface-gradient-start to-surface-gradient-end app:flex">
			{showSkeleton ? (
				<SidebarProfileSkeleton />
			) : (
				<SidebarProfileLink
					name={displayName}
					garpId={user?.garpId?.trim() || "—"}
					avatarUrl={user?.photoUrl ?? undefined}
				/>
			)}
			<div className="border-t border-background" />
			<nav className="flex flex-col divide-y divide-background">
				{SIDE_NAV_ITEMS.map(({ to, label, icon }) => (
					<SidebarNavLink key={to} to={to} label={label} icon={icon} />
				))}
			</nav>
		</aside>
	)
}

export { AppSidebar }
