import type { LucideIcon } from "lucide-react"
import {
	BookOpen,
	Brain,
	CalendarDays,
	CircleHelp,
	Home,
	ScrollText,
	Users,
} from "lucide-react"

import type { SideNavLink } from "./types"

export type SideNavItem = SideNavLink & {
	icon: LucideIcon
}

/**
 * Side nav routes + Lucide icons (bundled SVG — no icon font / network fetch).
 */
export const SIDE_NAV_ITEMS: SideNavItem[] = [
	{ to: "/dashboard", label: "Dashboard", icon: Home },
	{ to: "/programs", label: "Programs", icon: BookOpen },
	{ to: "/study-materials", label: "Study Materials", icon: Brain },
	{ to: "/membership", label: "Membership Benefits", icon: Users },
	{ to: "/events", label: "Events", icon: CalendarDays },
	{ to: "/help-center", label: "Help Center", icon: CircleHelp },
]

/**
 * CPD is owed only by members who already hold a certification, so it is the
 * one conditional row — `hasCPDProgram` on `GET programs` is the same flag the
 * legacy side nav gated on.
 */
export const CPD_NAV_ITEM: SideNavItem = {
	to: "/cpd",
	label: "CPD Credits",
	icon: ScrollText,
}

/**
 * The rows to render. Kept here rather than in each consumer so the desktop
 * rail and the mobile sheet cannot disagree about order or membership.
 */
export function sideNavItems({
	includeCpd,
}: {
	includeCpd: boolean
}): SideNavItem[] {
	if (!includeCpd) return SIDE_NAV_ITEMS
	// Directly after Programs — CPD is what follows certification.
	const index = SIDE_NAV_ITEMS.findIndex((item) => item.to === "/programs")
	const at = index === -1 ? SIDE_NAV_ITEMS.length : index + 1
	return [
		...SIDE_NAV_ITEMS.slice(0, at),
		CPD_NAV_ITEM,
		...SIDE_NAV_ITEMS.slice(at),
	]
}
