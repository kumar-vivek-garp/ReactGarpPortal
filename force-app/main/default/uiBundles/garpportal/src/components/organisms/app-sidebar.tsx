import { SidebarNavLink } from "@/components/molecules/sidebar-nav-link"
import { SidebarProfileLink } from "@/components/molecules/sidebar-profile-link"
import { SIDE_NAV_ITEMS } from "@/lib/navigation/side-nav-items"

// TODO: replace with the authenticated member's profile once session data is wired in.
const CURRENT_MEMBER = {
	name: "GARP Member",
	garpId: "—",
}

function AppSidebar() {
	return (
		<aside className="sticky top-20 hidden h-[calc(100vh-5rem)] w-[294px] shrink-0 flex-col self-start overflow-y-auto bg-linear-to-b from-surface-gradient-start to-surface-gradient-end app:flex">
			<SidebarProfileLink name={CURRENT_MEMBER.name} garpId={CURRENT_MEMBER.garpId} />
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
