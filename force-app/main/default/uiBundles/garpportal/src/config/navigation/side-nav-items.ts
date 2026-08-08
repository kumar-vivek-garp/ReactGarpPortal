import type { SideNavLink } from "./types"

/**
 * Icon names are Material Symbols Outlined ligatures, matching live Angular
 * `mat-icon` text on SideNavbarComponent:
 * home_outline → home, auto_stories_outline → auto_stories,
 * psychology_outline → psychology, group, calendar_month_outline → calendar_month,
 * help_outline → help (Outlined font already provides the outline style).
 */
export const SIDE_NAV_ITEMS: (SideNavLink & { icon: string })[] = [
	{ to: "/dashboard", label: "Dashboard", icon: "home" },
	{ to: "/programs", label: "Programs", icon: "auto_stories" },
	{ to: "/study-materials", label: "Study Materials", icon: "psychology" },
	{ to: "/membership", label: "Membership Benefits", icon: "group" },
	{ to: "/events", label: "Events", icon: "calendar_month" },
	{ to: "/help-center", label: "Help Center", icon: "help" },
]
