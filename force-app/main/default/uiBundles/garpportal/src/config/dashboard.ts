/**
 * Static config for the dashboard card manifest.
 *
 * `GET /memberportal/dashboard` returns `dashboardComponents` — a list of
 * `{ name, rankOrder }` and nothing else. The server decides WHICH cards a
 * member sees and in WHAT ORDER; the client supplies each card's content from
 * the endpoint that owns it. These names are matched exactly.
 */
export const DASHBOARD_COMPONENT = {
	enrolled: "Enrolled Programs",
	examNotifications: "Exam Notifications",
	cpd: "CPD",
	profile: "Member Profile",
	advertisement: "Advertisement",
	events: "Events",
	directory: "Member Directory",
	gbi: "GBI Portal",
	epp: "EPP Portal",
	benchPrep: "BenchPrep Viewer",
} as const

/**
 * The three sibling Salesforce apps a member can be sent to.
 *
 * Root-relative and case-sensitive — these are Visualforce/site paths, not
 * routes in this app, so `<Link>` must never be used for them. GarpAppv1 ships
 * `/eppApp` and `/gbiApp` here, which are both wrong; the legacy portal uses
 * the values below and they are what actually resolve.
 */
export const DASHBOARD_PORTAL_LINKS = {
	gbi: "/gbiapp",
	epp: "/garpEPPPortal",
	benchPrep: "/BenchPrepSSO",
} as const

/** Copy for the three external-portal cards. */
export const DASHBOARD_PORTAL_CARDS = {
	gbi: {
		title: "GARP Benchmarking Initiative",
		body: "Open the GBI portal to submit and review benchmarking data.",
		ctaLabel: "Access GBI",
	},
	epp: {
		title: "Exam Prep Provider Portal",
		body: "Manage your EPP data and course offerings.",
		ctaLabel: "Access EPP",
	},
	benchPrep: {
		title: "BenchPrep Viewer",
		body: "Review BenchPrep learner activity.",
		ctaLabel: "Open BenchPrep",
	},
} as const

export const DASHBOARD_DIRECTORY_CARD = {
	title: "Member Directory",
	ctaLabel: "View Directory",
	ctaUrl: "/member-directory",
} as const

/**
 * Where the Advertisement card's Register Now goes.
 *
 * **This is not interchangeable with the other registration links.** Four URL
 * shapes reach the same flow — `/sfdcApp#!/registration/…`, the same with a
 * `track_cta` query, this one, and a `window.open` variant — and they carry
 * different attribution. The dashboard advertisement uses exactly this one, so
 * `programRegistrationHref()` (which builds the `/sfdcApp#!/` shape) is the
 * wrong helper here.
 *
 * `adType` is FRM / SCR / RAI; the path wants the lower-cased form.
 */
export function adRegistrationHref(adType: string | null | undefined): string | null {
	const slug = adType?.trim().toLowerCase()
	if (!slug) return null
	return `/Login?start=registration/${slug}`
}

export const DASHBOARD_AD_CARD = {
	/** The legacy ships no creative at all — this is a text cross-sell. */
	eyebrow: "Recommended for you",
	ctaLabel: "Register Now",
} as const

export const DASHBOARD_NOTIFICATIONS_CARD = {
	title: "New Notifications",
	ctaLabel: "See All",
	/** How many notices the card previews before the dialog is needed. */
	previewLimit: 2,
} as const

/**
 * Copy for hiding and un-hiding a card.
 *
 * Apex snoozes for 60 days rather than deleting, and the toast says so: a
 * member who reads "hidden" as "gone forever" is the reason the undo exists.
 */
export const DASHBOARD_CARD_VISIBILITY = {
	dismissedMessage: "Card hidden for 60 days.",
	undoLabel: "Undo",
} as const
