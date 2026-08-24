import type { LucideIcon } from "lucide-react"

export type AppRoute =
	| "/dashboard"
	| "/programs"
	| "/cpd"
	| "/study-materials"
	| "/membership"
	| "/events"
	| "/help-center"
	| "/my-account"

export type ExternalNavLink = {
	title: string
	url: string
	openInNewTab?: boolean
}

export type MegaMenuColumn = {
	header: string
	headerURL?: string
	links: ExternalNavLink[]
}

/**
 * Brand token a mega-menu is tinted with on the mobile Browse grid. Each name
 * has a matching `--color-<name>-foreground` in `styles/theme.css` — always use
 * the declared pair rather than assuming white or black reads on the swatch.
 */
export type NavAccentToken =
	| "garp-cyan"
	| "garp-saffron"
	| "rai-orange"
	| "deep-purple"
	| "bright-purple"
	| "dark-blue-gray"

export type MegaMenuHeading = {
	prefix: string
	highlight: string
	highlightToken: "garp-cyan" | "garp-saffron" | "rai-split"
	symbol: "®" | "™"
	suffix: string
}

export type TopNavItem = {
	title: string
	heading?: MegaMenuHeading
	/** Tile tint on the mobile Browse grid. */
	accentToken: NavAccentToken
	/** Tile glyph on the mobile Browse grid. */
	icon: LucideIcon
	column1: MegaMenuColumn
	column2: MegaMenuColumn
	column3?: MegaMenuColumn
}

export type SideNavLink = {
	to: AppRoute
	label: string
}

export type FooterNavSection = {
	key: string
	label: string
	links: ExternalNavLink[]
}

export type SocialLink =
	| { name: string; kind: "link"; url: string }
	| { name: string; kind: "qr"; qrImageUrl: string; qrAlt: string }
