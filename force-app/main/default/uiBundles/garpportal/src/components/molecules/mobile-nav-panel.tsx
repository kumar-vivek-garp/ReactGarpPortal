import { MobileBrowseGrid } from "@/components/molecules/mobile-browse-grid"
import { SidebarNavLink } from "@/components/molecules/sidebar-nav-link"
import { SidebarProfileLink } from "@/components/molecules/sidebar-profile-link"
import { SidebarProfileSkeleton } from "@/components/molecules/sidebar-profile-skeleton"
import { SignOutButton } from "@/components/molecules/sign-out-button"
import { useCurrentUser } from "@/hooks/use-current-user"
import { useHasCpdProgram } from "@/hooks/use-has-cpd-program"
import { sideNavItems } from "@/config/navigation/side-nav-items"
import type { TopNavItem } from "@/config/navigation/types"

/**
 * Root view of the mobile menu: who you are, where you can go in the app, and
 * then the wider garp.org sections.
 *
 * The account rows are the *same* `SidebarProfileLink` / `SidebarNavLink`
 * components the desktop rail uses, not restyled copies. That is deliberate:
 * the avatar and the icon pucks then share one 44px column and one row height
 * by construction, so the profile row can never drift into looking like a
 * different kind of control from Dashboard or Programs.
 */
function MobileNavPanel({ onBrowse }: { onBrowse: (item: TopNavItem) => void }) {
	const { data: user, isPending } = useCurrentUser()
	const showSkeleton = isPending && !user
	const navItems = sideNavItems({ includeCpd: useHasCpdProgram() })

	return (
		<div className="flex flex-col gap-1 px-3 pt-2 pb-[calc(2.5rem+env(safe-area-inset-bottom,0px))]">
			{showSkeleton ? (
				<SidebarProfileSkeleton inset />
			) : (
				<SidebarProfileLink
					inset
					uppercase={false}
					name={user?.name?.trim() || "GARP Member"}
					garpId={user?.garpId?.trim() || "—"}
					avatarUrl={user?.photoUrl ?? undefined}
				/>
			)}

			<nav className="flex flex-col gap-1" aria-label="Account">
				{navItems.map(({ to, label, icon }) => (
					<SidebarNavLink key={to} to={to} label={label} icon={icon} uppercase={false} />
				))}
			</nav>

			<div className="px-3 pt-4">
				<SignOutButton size="default" className="w-full" />
			</div>

			<div className="px-3 pt-8">
				<h2 className="pb-3 text-lg leading-tight font-extrabold text-foreground">
					Browse &amp; Explore
				</h2>
				<MobileBrowseGrid onSelect={onBrowse} />
			</div>
		</div>
	)
}

export { MobileNavPanel }
