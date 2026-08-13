import type { Completeness } from "@/api/account/types"
import type {
	DashboardEnrolledPreview,
	DashboardEventPreview,
	PortalCard,
} from "@/api/dashboard"
import type { MemberEvent } from "@/api/events"
import type { EnrolledProgram } from "@/api/programs"
import { stripProgramFormalName } from "@/lib/program-formal-name"

/** TEMP — flip to true to preview every card regardless of mute / enroll. */
export const FORCE_SHOW_ALL_DASHBOARD_CARDS = false

export const DASHBOARD_PROVIDER = {
	profile: "ProfileCompleteness",
	exam: "ExamRegistration",
	directory: "MemberDirectory",
	enrolled: "EnrolledPrograms",
	events: "Events",
} as const

/** Same ranks as legacy `GARP_BC_MemberPortal.getDashboardInfo`. */
const ENROLLED_RANK = 1
const EVENTS_RANK = 20
const PREVIEW_LIMIT = 2

type ComposeDashboardCardsInput = {
	serverCards: PortalCard[]
	enrolledPrograms: EnrolledProgram[]
	registeredEvents: MemberEvent[]
	completeness?: Completeness | null
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

/**
 * Legacy dashboard visibility, applied on top of `GET /memberportal/dashboard`.
 *
 * Enrolled Programs and My Events are not in that payload — the old remoting
 * page loaded them as follow-up component calls. We use the already-shipped
 * programs/events REST views and the same show/hide rules:
 * - Enrolled card when `enrolledPrograms` is non-empty (max 2)
 * - Events card when `registeredEvents` is non-empty (max 2)
 * - Hide Advertisement / ExamRegistration when the member is enrolled
 *   (legacy `computeAdType` returns null on any open exam attempt)
 */
function profileCard(completeness: Completeness): PortalCard {
	return {
		key: "Dashboard_Profile_Completeness",
		page: "Dashboard",
		provider: DASHBOARD_PROVIDER.profile,
		rank: 8,
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

export function composeDashboardCards({
	serverCards,
	enrolledPrograms,
	registeredEvents,
	completeness,
	showAll = FORCE_SHOW_ALL_DASHBOARD_CARDS,
}: ComposeDashboardCardsInput): PortalCard[] {
	const enrolled = enrolledPreviews(
		Array.isArray(enrolledPrograms) ? enrolledPrograms : [],
	)
	const upcoming = eventPreviews(
		Array.isArray(registeredEvents) ? registeredEvents : [],
	)
	const hideExamPromo = !showAll && enrolled.length > 0

	const cards = (Array.isArray(serverCards) ? serverCards : []).filter((card) => {
		if (hideExamPromo && card.provider === DASHBOARD_PROVIDER.exam) {
			return false
		}
		return true
	})

	if (
		showAll &&
		completeness &&
		!cards.some((card) => card.provider === DASHBOARD_PROVIDER.profile)
	) {
		cards.push(profileCard(completeness))
	}

	if (showAll || enrolled.length > 0) {
		cards.push(
			composedCard({
				key: "Dashboard_Enrolled_Programs",
				provider: DASHBOARD_PROVIDER.enrolled,
				rank: ENROLLED_RANK,
				title: "Enrolled Programs",
				ctaLabel: "See All",
				ctaUrl: "/programs?tab=in-progress",
				meta: { enrolledPrograms: enrolled },
			}),
		)
	}

	if (showAll || upcoming.length > 0) {
		cards.push(
			composedCard({
				key: "Dashboard_Events",
				provider: DASHBOARD_PROVIDER.events,
				rank: EVENTS_RANK,
				title: "My Events",
				ctaLabel: "See All",
				ctaUrl: "/events?tab=attending",
				meta: { upcomingEvents: upcoming },
			}),
		)
	}

	return cards.slice().sort((left, right) => left.rank - right.rank)
}
