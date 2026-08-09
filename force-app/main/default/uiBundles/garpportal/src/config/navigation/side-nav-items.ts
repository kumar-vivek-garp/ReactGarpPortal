import type { LucideIcon } from "lucide-react"
import {
	BookOpen,
	Brain,
	CalendarDays,
	CircleHelp,
	Home,
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
