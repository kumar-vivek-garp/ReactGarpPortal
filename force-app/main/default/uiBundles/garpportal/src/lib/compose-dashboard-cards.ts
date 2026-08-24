import type { Completeness } from "@/api/account/types"
import type { AdInfo } from "@/api/dashboard"
import type { ProgramExamNotification } from "@/api/notifications"
import type {
	DashboardComponent,
	DashboardEnrolledPreview,
	DashboardEventPreview,
	PortalCard,
} from "@/api/dashboard"
import type { CpdView } from "@/api/cpd"
import type { MemberEvent } from "@/api/events"
import type { EnrolledProgram } from "@/api/programs"
import {
	adRegistrationHref,
	DASHBOARD_AD_CARD,
	DASHBOARD_COMPONENT,
	DASHBOARD_DIRECTORY_CARD,
	DASHBOARD_NOTIFICATIONS_CARD,
	DASHBOARD_PORTAL_CARDS,
	DASHBOARD_PORTAL_LINKS,
} from "@/config/dashboard"
import {
	cpdCardTitle,
	cpdRemainingLabel,
	dashboardCreditRows,
} from "@/lib/cpd-presentation"
import { stripProgramFormalName } from "@/lib/program-formal-name"

/** TEMP — flip to true to preview every card regardless of mute / enroll. */
export const FORCE_SHOW_ALL_DASHBOARD_CARDS = false

export const DASHBOARD_PROVIDER = {
	profile: "ProfileCompleteness",
	exam: "ExamRegistration",
	directory: "MemberDirectory",
	enrolled: "EnrolledPrograms",
	events: "Events",
	cpd: "CPDCredits",
	portal: "ExternalPortal",
	advertisement: "Advertisement",
	notifications: "ExamNotifications",
} as const

const PREVIEW_LIMIT = 2

type ComposeDashboardCardsInput = {
	/** The server's `{ name, rankOrder }` manifest. */
	components: DashboardComponent[]
	enrolledPrograms: EnrolledProgram[]
	registeredEvents: MemberEvent[]
	/** `null` when the member has no CPD program. */
	cpd?: CpdView | null
	completeness?: Completeness | null
	/** `GET ad` — null while loading, or when the member is mid-programme. */
	ad?: AdInfo | null
	examNotifications?: ProgramExamNotification[]
	/** Defaults to `FORCE_SHOW_ALL_DASHBOARD_CARDS`. Tests pass false. */
	showAll?: boolean
}

function isHttpUrl(url: string): boolean {
	try {
		const parsed = new URL(url)
		return parsed.protocol === "http:" || parsed.protocol === "https:"
	} catch {
		return false
	}
}

/** Drop catalogue bases with no vanity slug (`/event/`). */
function eventPreviewUrl(event: MemberEvent): string | null {
	const raw = event.eventURL?.trim()
	if (raw && isHttpUrl(raw)) {
		const path = new URL(raw).pathname.replace(/\/+$/, "")
		if (path.split("/").filter(Boolean).length >= 2) return raw
	}
	const slug = event.eventSlug?.trim()
	return slug ? `https://www.garp.org/events/${slug}` : null
}

function programPreviewName(program: EnrolledProgram): string {
	const info = program.programInformation
	return (
		stripProgramFormalName(info?.formalName) ||
		info?.informalName?.trim() ||
		info?.abbrevName?.trim() ||
		program.programType
	)
}

function enrolledPreviews(
	programs: EnrolledProgram[],
): DashboardEnrolledPreview[] {
	return programs.slice(0, PREVIEW_LIMIT).map((program) => ({
		programType: program.programType,
		name: programPreviewName(program),
		adminPartIName: program.adminPartIName,
		adminPartIIName: program.adminPartIIName,
	}))
}

function eventPreviews(events: MemberEvent[]): DashboardEventPreview[] {
	return events.slice(0, PREVIEW_LIMIT).map((event) => ({
		eventId: event.eventId,
		eventType: event.eventType?.trim() || "Event",
		eventName: event.eventName?.trim() || "Event",
		eventStartDate: event.eventStartDate,
		eventUrl: eventPreviewUrl(event),
	}))
}

function composedCard(input: {
	key: string
	provider: string
	rank: number
	title: string
	ctaLabel: string
	ctaUrl: string
	meta: Record<string, unknown>
}): PortalCard {
	return {
		key: input.key,
		page: "Dashboard",
		provider: input.provider,
		rank: input.rank,
		title: input.title,
		body: null,
		ctaLabel: input.ctaLabel,
		ctaUrl: input.ctaUrl,
		ctaIsExternal: false,
		imageUrl: null,
		eyebrow: null,
		badge: null,
		locked: false,
		dismissible: false,
		bullets: null,
		meta: input.meta,
	}
}

/** The profile card. Content is client-side; the server only says whether to show it. */
function profileCard(
	completeness: Completeness | null | undefined,
	rank: number,
): PortalCard | null {
	if (!completeness) return null
	return {
		key: "Dashboard_Profile_Completeness",
		page: "Dashboard",
		provider: DASHBOARD_PROVIDER.profile,
		rank,
		title: "Your Profile Is Missing Information",
		body: "Click below to help us better recommend you learning, networking, and programming.",
		ctaLabel: "Update My Profile",
		ctaUrl: "/my-account",
		ctaIsExternal: false,
		imageUrl: null,
		eyebrow: null,
		badge: `${completeness.percentComplete}%`,
		locked: false,
		dismissible: true,
		bullets: null,
		meta: {
			percentComplete: completeness.percentComplete,
			missing: completeness.missing,
			missingBySection: completeness.missingBySection,
		},
	}
}

/** One of the three sibling Salesforce apps. Always a full page navigation. */
function portalCard(
	key: keyof typeof DASHBOARD_PORTAL_CARDS,
	rank: number,
): PortalCard {
	const copy = DASHBOARD_PORTAL_CARDS[key]
	return {
		...composedCard({
			key: `Dashboard_${key}`,
			provider: DASHBOARD_PROVIDER.portal,
			rank,
			title: copy.title,
			ctaLabel: copy.ctaLabel,
			ctaUrl: DASHBOARD_PORTAL_LINKS[key],
			meta: {},
		}),
		body: copy.body,
		ctaIsExternal: true,
	}
}

/**
 * Turns the server's card manifest into renderable cards.
 *
 * **The server owns which cards appear and in what order.** `dashboardComponents`
 * is a list of `{ name, rankOrder }`; this maps each known name onto a card and
 * sorts by the server's rank. A name the switch does not know renders nothing,
 * which is the legacy's behaviour and means a new server-side card is inert
 * rather than broken until the client learns it.
 *
 * Cards whose content lives elsewhere are dropped when that content is absent —
 * a manifest entry for Events with no registrations would otherwise draw an
 * empty card. The manifest decides eligibility; the data decides whether there
 * is anything worth showing.
 *
 * Not yet handled, and deliberately inert rather than half-drawn:
 * `Advertisement` (needs `GET ad` for the administration name and whether
 * registration is open) and `Exam Notifications` (needs the notifications list
 * and its dialog).
 */
export function composeDashboardCards({
	components,
	enrolledPrograms,
	registeredEvents,
	cpd,
	completeness,
	ad,
	examNotifications,
	showAll = FORCE_SHOW_ALL_DASHBOARD_CARDS,
}: ComposeDashboardCardsInput): PortalCard[] {
	const enrolled = enrolledPreviews(
		Array.isArray(enrolledPrograms) ? enrolledPrograms : [],
	)
	const upcoming = eventPreviews(
		Array.isArray(registeredEvents) ? registeredEvents : [],
	)
	const cpdRows = dashboardCreditRows(cpd)
	const notices = Array.isArray(examNotifications) ? examNotifications : []
	const manifest = Array.isArray(components) ? components : []

	const cards = manifest.flatMap<PortalCard>((component) => {
		const rank = component.rankOrder ?? 0
		switch (component.name) {
			case DASHBOARD_COMPONENT.enrolled:
				if (!showAll && enrolled.length === 0) return []
				return composedCard({
					key: "Dashboard_Enrolled_Programs",
					provider: DASHBOARD_PROVIDER.enrolled,
					rank,
					title: "Enrolled Programs",
					ctaLabel: "See all enrolled programs",
					ctaUrl: "/programs?tab=in-progress",
					meta: { enrolledPrograms: enrolled },
				})

			case DASHBOARD_COMPONENT.cpd:
				/*
				 * Gated on there being a bar to draw, which covers both empty
				 * cases: no CPE contract, and a contract with nothing certified
				 * yet (200 with every number null). The legacy drew a blank chart
				 * for both.
				 */
				if (cpdRows.length === 0) return []
				return composedCard({
					key: "Dashboard_CPD",
					provider: DASHBOARD_PROVIDER.cpd,
					rank,
					title: cpdCardTitle(cpd),
					ctaLabel: "Manage Credits",
					ctaUrl: "/cpd",
					meta: { cpdRows, cpdRemaining: cpdRemainingLabel(cpd) },
				})

			case DASHBOARD_COMPONENT.events:
				if (!showAll && upcoming.length === 0) return []
				return composedCard({
					key: "Dashboard_Events",
					provider: DASHBOARD_PROVIDER.events,
					rank,
					title: "My Events",
					ctaLabel: "See all my events",
					ctaUrl: "/events?tab=attending",
					meta: { upcomingEvents: upcoming },
				})

			case DASHBOARD_COMPONENT.profile: {
				const card = profileCard(completeness, rank)
				return card ? card : []
			}

			case DASHBOARD_COMPONENT.directory:
				return {
					...composedCard({
						key: "Dashboard_Member_Directory",
						provider: DASHBOARD_PROVIDER.directory,
						rank,
						title: DASHBOARD_DIRECTORY_CARD.title,
						ctaLabel: DASHBOARD_DIRECTORY_CARD.ctaLabel,
						ctaUrl: DASHBOARD_DIRECTORY_CARD.ctaUrl,
						meta: { searchEnabled: true },
					}),
				}

			case DASHBOARD_COMPONENT.gbi:
				return portalCard("gbi", rank)
			case DASHBOARD_COMPONENT.epp:
				return portalCard("epp", rank)
			case DASHBOARD_COMPONENT.benchPrep:
				return portalCard("benchPrep", rank)

			case DASHBOARD_COMPONENT.advertisement: {
				/*
				 * `adType` null is a success meaning "nothing to sell" — the
				 * member sits everything already, or has a result pending. The
				 * manifest can still list the card, because the dashboard payload
				 * decides that from a cheaper check than the ad service runs.
				 */
				const adType = ad?.adType?.trim()
				if (!adType) return []
				const href = adRegistrationHref(adType)
				const open = ad?.isRegistrationOpen === true
				return {
					...composedCard({
						key: "Dashboard_Advertisement",
						provider: DASHBOARD_PROVIDER.advertisement,
						rank,
						title: `Take the ${adType} exam`,
						ctaLabel: DASHBOARD_AD_CARD.ctaLabel,
						// Only offered while registration is actually open; the card
						// still shows the window when it is not.
						ctaUrl: open && href ? href : "",
						meta: {
							examType: adType,
							administrationName: ad?.adminName ?? undefined,
							isRegistrationOpen: open,
							registrationEnd: ad?.nextAdminRegistrationOpenDate ?? null,
						},
					}),
					eyebrow: DASHBOARD_AD_CARD.eyebrow,
					body: ad?.adminName?.trim()
						? open
							? `Registration is open for ${ad.adminName}.`
							: `The next administration is ${ad.adminName}.`
						: null,
					ctaLabel: open ? DASHBOARD_AD_CARD.ctaLabel : null,
					ctaUrl: open && href ? href : null,
					ctaIsExternal: true,
				}
			}

			case DASHBOARD_COMPONENT.examNotifications:
				// The manifest only lists this when the notice list was non-empty
				// server-side, but it is fetched separately — so an empty list here
				// means the two disagreed, and an empty card helps nobody.
				if (notices.length === 0) return []
				return composedCard({
					key: "Dashboard_Exam_Notifications",
					provider: DASHBOARD_PROVIDER.notifications,
					rank,
					title: DASHBOARD_NOTIFICATIONS_CARD.title,
					ctaLabel: DASHBOARD_NOTIFICATIONS_CARD.ctaLabel,
					ctaUrl: "",
					meta: { notifications: notices },
				})

			default:
				// A card the server has learned about and this client has not.
				return []
		}
	})

	return cards.slice().sort((left, right) => left.rank - right.rank)
}
