import type { Completeness } from "@/api/account/types"
import type { AlertBarView } from "@/api/alert-bar"
import type { CpdView } from "@/api/cpd"
import type { AdInfo, CardVisibilityResult, DashboardView } from "@/api/dashboard"
import type { EventsView, MemberEvent } from "@/api/events"
import type { ExamNotificationsView } from "@/api/notifications"
import type {
	EnrolledProgram,
	OtherProgram,
	ProgramsView,
} from "@/api/programs"
import { DASHBOARD_COMPONENT } from "@/config/dashboard"
import { identity } from "@/testing/factories/identity"

/**
 * Hand-written wire payloads for the mock org, covering the listing/dashboard
 * endpoints the typed factories in `src/testing/factories/` do not build.
 * Everything is typed with `import type` against the real `@/api/...` domain
 * types, so a contract drift breaks `tsc -b`, not the night's run.
 *
 * Dates are fixed, not computed — the components render them, they do not
 * filter on "today" (Apex owns upcoming-ness), so a pinned date stays green.
 */

const COMPLETENESS: Completeness = {
	percentComplete: 40,
	earnedWeight: 4,
	totalWeight: 10,
	isComplete: false,
	muted: false,
	missing: ["Photo", "Job function"],
	missingBySection: { About: 1, Professional: 1 },
}

/**
 * `GET dashboard` — the card manifest plus identity/completeness.
 *
 * The manifest deliberately lists several card KINDS: profile (the only
 * dismissible composed card), enrolled programs, exam notifications, events,
 * CPD, and the advertisement. `Member Directory` is deliberately absent — its
 * card mounts a live search widget with its own `directory` query, which is
 * another module's surface.
 */
export function dashboardData(): DashboardView {
	return {
		identity: identity(),
		completeness: COMPLETENESS,
		dashboardComponents: [
			{ name: DASHBOARD_COMPONENT.profile, rankOrder: 1 },
			{ name: DASHBOARD_COMPONENT.enrolled, rankOrder: 2 },
			{ name: DASHBOARD_COMPONENT.examNotifications, rankOrder: 3 },
			{ name: DASHBOARD_COMPONENT.events, rankOrder: 4 },
			{ name: DASHBOARD_COMPONENT.cpd, rankOrder: 5 },
			{ name: DASHBOARD_COMPONENT.advertisement, rankOrder: 6 },
		],
		adType: "SCR",
	}
}

/** `GET ad` — registration open, so the card carries a Register Now CTA. */
export function adData(): AdInfo {
	return {
		statusMessage: null,
		statusCode: 200,
		adType: "SCR",
		adminName: "October 2026 SCR Exam",
		isRegistrationOpen: true,
		nextAdminRegistrationOpenDate: null,
	}
}

/** `GET examNotifications` — two notices, exactly the card's preview limit. */
export function examNotificationsData(): ExamNotificationsView {
	return {
		statusMessage: null,
		statusCode: 200,
		notifications: [
			{
				notificationTitle: "Exam window update",
				notificationDetails:
					"The May 2027 FRM Part I exam window has been extended by two days.",
				notificationDate: "2026-08-20",
			},
			{
				notificationTitle: "Admission ticket available",
				notificationDetails:
					"Your admission ticket for the upcoming administration is ready to download.",
				notificationDate: "2026-08-28",
			},
		],
	}
}

/**
 * `GET alertBar` — one active alert. "Scheduling Incomplete" is the rung the
 * legacy raises most; urgent tone, deadline carried, in-app scheduling action.
 * Renders as: "FRM Part I" over "Schedule by 7 November 2026" + the copy below.
 */
export function alertBarData(): AlertBarView {
	return {
		statusMessage: null,
		statusCode: 200,
		examType: "FRM",
		examPart: "I",
		alertStatus: "Scheduling Incomplete",
		deadline: "2026-11-07",
		orderId: null,
		route: "Exam Scheduling",
	}
}

const FRM_ENROLLED: EnrolledProgram = {
	programType: "FRM",
	adminPartIName: "May 2027",
	adminPartIIName: null,
	programInformation: {
		programCode: "FRM",
		abbrevName: "FRM",
		formalName: null,
		informalName: "Financial Risk Manager",
		policyURL: null,
		regLogoURL: null,
		myProgramsLogoURL: null,
		description: null,
		registrationPath: null,
	},
}

const SCR_OTHER: OtherProgram = {
	programType: "SCR",
	isRegistrationOpen: true,
	nextRegistrationOpenDate: null,
	nextRegistrationOpenAdminName: null,
	isMicroCourse: false,
	programInformation: {
		programCode: "SCR",
		abbrevName: "SCR",
		formalName: null,
		informalName: "Sustainability and Climate Risk",
		policyURL: null,
		regLogoURL: null,
		myProgramsLogoURL: null,
		description: null,
		registrationPath: null,
	},
}

const RAI_OTHER: OtherProgram = {
	programType: "RAI",
	isRegistrationOpen: false,
	nextRegistrationOpenDate: "2026-12-01",
	nextRegistrationOpenAdminName: "May 2027",
	isMicroCourse: false,
	programInformation: {
		programCode: "RAI",
		abbrevName: "RAI",
		formalName: null,
		informalName: "Risk and AI",
		policyURL: null,
		regLogoURL: null,
		myProgramsLogoURL: null,
		description: null,
		registrationPath: null,
	},
}

/**
 * `GET programs` — one enrolled programme (FRM) plus others, with
 * `hasCPDProgram: true` so the sidebar's CPD gate opens. Exported for reuse
 * by the /programs specs.
 */
export function programsListData(): ProgramsView {
	return {
		statusMessage: null,
		statusCode: 200,
		enrolledPrograms: [FRM_ENROLLED],
		completedPrograms: [],
		otherPrograms: [SCR_OTHER, RAI_OTHER],
		hasCPDProgram: true,
		hasExamResults: false,
		microCourseConfig: null,
	}
}

const REGISTERED_EVENTS: MemberEvent[] = [
	{
		eventId: "EV-1",
		eventType: "Webcast",
		eventName: "Climate Risk Outlook 2026",
		eventStartDate: "2026-10-01",
		eventSlug: "climate-risk-outlook-2026",
		eventURL: null,
		chapterId: null,
		canManageAttendance: false,
		addToCalTitle: null,
		addToCalDescription: null,
		addToCalStartDateTime: null,
		addToCalEndDateTime: null,
		addToCalTimeZone: null,
		addToCalLocation: null,
	},
	{
		eventId: "EV-2",
		eventType: "Event",
		eventName: "GARP Annual Risk Convention",
		eventStartDate: "2026-11-12",
		eventSlug: "annual-risk-convention",
		eventURL: null,
		chapterId: null,
		canManageAttendance: false,
		addToCalTitle: null,
		addToCalDescription: null,
		addToCalStartDateTime: null,
		addToCalEndDateTime: null,
		addToCalTimeZone: null,
		addToCalLocation: null,
	},
]

/** `GET events` — two upcoming registered events; other buckets empty. */
export function eventsListData(): EventsView {
	return {
		statusMessage: null,
		statusCode: 200,
		registeredEvents: REGISTERED_EVENTS,
		upcomingChapterMeetings: [],
		upcomingOtherEvents: [],
	}
}

/**
 * `GET cpd` — the dashboard CPD summary. Must be stubbed on any dashboard
 * visit: the mock org's default `{}` envelope fails `fetchCpd`'s
 * `statusCode !== 200` check and toasts "Unable to load CPD credits" — the
 * exact stray-toast artifact the dashboard spec asserts against.
 */
export function cpdData(): CpdView {
	return {
		statusMessage: null,
		statusCode: 200,
		cpdCycle: "2025/2027",
		frmTotalNeeded: 40,
		frmCompleted: 8,
		erpTotalNeeded: null,
		erpCompleted: null,
		scrTotalNeeded: null,
		scrCompleted: null,
		raiTotalNeeded: null,
		raiCompleted: null,
		creditsRemaining: 32,
	}
}

/** `POST dismissCard` / `POST restoreCard` echoes, keyed the way Apex keys them. */
export function dismissResultData(key: string): CardVisibilityResult {
	return { dismissed: key, muted: true }
}

export function restoreResultData(key: string): CardVisibilityResult {
	return { restored: key, muted: false }
}

/**
 * The full happy-path action set for a member landing on /dashboard — every
 * memberportal action that page fires, so nothing falls through to the mock
 * org's permissive-but-wrong `{}` default.
 */
export function dashboardActionSet(): Record<string, unknown> {
	return {
		dashboard: dashboardData(),
		programs: programsListData(),
		events: eventsListData(),
		cpd: cpdData(),
		ad: adData(),
		examNotifications: examNotificationsData(),
		alertBar: alertBarData(),
	}
}
