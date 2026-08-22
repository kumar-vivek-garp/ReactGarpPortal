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
