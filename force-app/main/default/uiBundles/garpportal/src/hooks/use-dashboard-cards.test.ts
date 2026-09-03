import { waitFor } from "@testing-library/react"
import { delay, http, HttpResponse } from "msw"
import { describe, expect, it } from "vitest"

import type { Completeness, Identity } from "@/api/account/types"
import { cpdQueryKeys } from "@/api/cpd"
import type { CpdView } from "@/api/cpd"
import { dashboardQueryKeys } from "@/api/dashboard"
import type { AdInfo, DashboardComponent, DashboardView } from "@/api/dashboard"
import type { EventsView, MemberEvent } from "@/api/events"
import type { EnrolledProgram, ProgramsView } from "@/api/programs"
import { DASHBOARD_COMPONENT } from "@/config/dashboard"
import { useDashboardCards } from "@/hooks/use-dashboard-cards"
import {
	memberPortalEnvelope,
	memberPortalError,
} from "@/testing/factories/envelope"
import { server } from "@/testing/msw/server"
import { createTestQueryClient } from "@/testing/query-client"
import { renderHookWithProviders } from "@/testing/render"

const DASHBOARD_PATH = "/services/apexrest/memberportal/dashboard"
const PROGRAMS_PATH = "/services/apexrest/memberportal/programs"
const EVENTS_PATH = "/services/apexrest/memberportal/events"
const AD_PATH = "/services/apexrest/memberportal/ad"
const NOTIFICATIONS_PATH = "/services/apexrest/memberportal/examNotifications"

const identity: Identity = {
	contactId: "003XX0000012345",
	firstName: "Ada",
	lastName: "Member",
	fullName: "Ada Member",
	email: "ada@example.org",
	garpId: "1002003",
	membershipType: "Individual",
	membershipStatus: "Active",
	membershipExpiration: "2027-01-01",
	memberSince: "2020-01-01",
	autoRenew: false,
	isMember: true,
	isIndividualMember: true,
	isAffiliateMember: false,
	isMemberInGoodStanding: true,
	audience: "Individual",
	photoUrl: null,
}

const completeness: Completeness = {
	percentComplete: 40,
	earnedWeight: 4,
	totalWeight: 10,
	isComplete: false,
	muted: false,
	missing: ["Photo"],
	missingBySection: { About: 1 },
}

function dashboardView(components: DashboardComponent[]): DashboardView {
	return { identity, completeness, dashboardComponents: components, adType: null }
}

const frmProgram: EnrolledProgram = {
	programType: "FRM",
	adminPartIName: "May 2026",
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

function programsView(enrolled: EnrolledProgram[]): ProgramsView {
	return {
		statusMessage: null,
		statusCode: 200,
		enrolledPrograms: enrolled,
		completedPrograms: [],
		otherPrograms: [],
		hasCPDProgram: false,
		hasExamResults: false,
		microCourseConfig: null,
	}
}

const webcast: MemberEvent = {
	eventId: "EV-1",
	eventType: "Webcast",
	eventName: "Risk Convention",
	eventStartDate: "2026-10-01",
	eventSlug: "risk-convention",
	eventURL: null,
	chapterId: null,
	canManageAttendance: false,
	addToCalTitle: null,
	addToCalDescription: null,
	addToCalStartDateTime: null,
	addToCalEndDateTime: null,
	addToCalTimeZone: null,
	addToCalLocation: null,
}

function eventsView(registered: MemberEvent[]): EventsView {
	return {
		statusMessage: null,
		statusCode: 200,
		registeredEvents: registered,
		upcomingChapterMeetings: [],
		upcomingOtherEvents: [],
	}
}

const frmCpd: CpdView = {
	statusMessage: null,
	statusCode: 200,
	cpdCycle: "2025/2026",
	frmTotalNeeded: 40,
	frmCompleted: 10,
	erpTotalNeeded: null,
	erpCompleted: null,
	scrTotalNeeded: null,
	scrCompleted: null,
	raiTotalNeeded: null,
	raiCompleted: null,
	creditsRemaining: 30,
}

const quietAd: AdInfo = {
	statusMessage: null,
	statusCode: 200,
	// null adType is a success meaning "nothing to sell".
	adType: null,
	adminName: null,
	isRegistrationOpen: null,
	nextAdminRegistrationOpenDate: null,
}

function envelope<T>(data: T) {
	return HttpResponse.json(memberPortalEnvelope(data))
}

const quietSecondaries = [
	http.get(AD_PATH, () => envelope(quietAd)),
	http.get(NOTIFICATIONS_PATH, () =>
		envelope({ statusMessage: null, statusCode: 200, notifications: [] }),
	),
]

/** Dashboard manifest + CPD seeded into the cache; listings arrive over MSW. */
function seededClient(components: DashboardComponent[], cpd: CpdView | null) {
	const queryClient = createTestQueryClient()
	queryClient.setQueryData(dashboardQueryKeys.view, dashboardView(components))
	queryClient.setQueryData(cpdQueryKeys.view, cpd)
	return queryClient
}

function cardKeys(result: { cards: { key: string }[] }) {
	return result.cards.map((card) => card.key)
}

describe("useDashboardCards", () => {
	it("waits on the listings, then composes the manifest in server rank order", async () => {
		server.use(
			http.get(PROGRAMS_PATH, () => envelope(programsView([frmProgram]))),
			http.get(EVENTS_PATH, () => envelope(eventsView([webcast]))),
			...quietSecondaries,
		)
		const { result } = renderHookWithProviders(() => useDashboardCards(), {
			queryClient: seededClient(
				[
					{ name: DASHBOARD_COMPONENT.events, rankOrder: 3 },
					{ name: DASHBOARD_COMPONENT.enrolled, rankOrder: 1 },
					{ name: DASHBOARD_COMPONENT.directory, rankOrder: 2 },
					{ name: DASHBOARD_COMPONENT.profile, rankOrder: 4 },
					{ name: "A Card This Client Has Never Heard Of", rankOrder: 0 },
				],
				null,
			),
		})

		// The listing-backed cards are gated until their data arrives; the
		// self-contained ones render immediately.
		expect(result.current.isLoading).toBe(true)
		expect(cardKeys(result.current)).toEqual([
			"Dashboard_Member_Directory",
			"Dashboard_Profile_Completeness",
		])

		await waitFor(() => expect(result.current.isLoading).toBe(false))
		expect(cardKeys(result.current)).toEqual([
			"Dashboard_Enrolled_Programs",
			"Dashboard_Member_Directory",
			"Dashboard_Events",
			"Dashboard_Profile_Completeness",
		])

		const [enrolled, , events, profile] = result.current.cards
		expect(enrolled.meta?.enrolledPrograms).toEqual([
			{
				programType: "FRM",
				name: "Financial Risk Manager",
				adminPartIName: "May 2026",
				adminPartIIName: null,
			},
		])
		expect(events.meta?.upcomingEvents).toMatchObject([
			{ eventId: "EV-1", eventUrl: "https://www.garp.org/events/risk-convention" },
		])
		expect(profile.badge).toBe("40%")
	})

	it("stops gating on a failed listing and drops its card", async () => {
		server.use(
			// 500, not 4xx: the SDK transport retries once on 400/401/403.
			http.get(PROGRAMS_PATH, () =>
				HttpResponse.json(memberPortalError(500, "programs down"), {
					status: 500,
				}),
			),
			http.get(EVENTS_PATH, () => envelope(eventsView([webcast]))),
			...quietSecondaries,
		)
		const { result } = renderHookWithProviders(() => useDashboardCards(), {
			queryClient: seededClient(
				[
					{ name: DASHBOARD_COMPONENT.enrolled, rankOrder: 1 },
					{ name: DASHBOARD_COMPONENT.cpd, rankOrder: 2 },
					{ name: DASHBOARD_COMPONENT.events, rankOrder: 3 },
				],
				frmCpd,
			),
		})

		await waitFor(() => expect(result.current.isLoading).toBe(false))
		expect(result.current.isError).toBe(false)
		expect(cardKeys(result.current)).toEqual([
			"Dashboard_CPD",
			"Dashboard_Events",
		])
		expect(result.current.cards[0].meta?.cpdRows).toEqual([
			{ designation: "FRM", approved: 10, required: 40 },
		])
	})

	it("reports isError when the dashboard manifest itself fails", async () => {
		server.use(
			http.get(DASHBOARD_PATH, () =>
				HttpResponse.json(memberPortalError(500, "dashboard down"), {
					status: 500,
				}),
			),
			http.get(PROGRAMS_PATH, () => envelope(programsView([]))),
			http.get(EVENTS_PATH, () => envelope(eventsView([]))),
			...quietSecondaries,
		)
		const queryClient = createTestQueryClient()
		queryClient.setQueryData(cpdQueryKeys.view, null)
		const { result } = renderHookWithProviders(() => useDashboardCards(), {
			queryClient,
		})

		await waitFor(() => expect(result.current.isError).toBe(true))
		await waitFor(() => expect(result.current.isLoading).toBe(false))
		expect(result.current.cards).toEqual([])
	})

	it("never gates on the secondary ad and notifications queries", async () => {
		server.use(
			http.get(PROGRAMS_PATH, () => envelope(programsView([frmProgram]))),
			http.get(EVENTS_PATH, () => envelope(eventsView([]))),
			// Both secondaries hang for ever; the dashboard must not wait.
			http.get(AD_PATH, () => delay("infinite")),
			http.get(NOTIFICATIONS_PATH, () => delay("infinite")),
		)
		const { result } = renderHookWithProviders(() => useDashboardCards(), {
			queryClient: seededClient(
				[
					{ name: DASHBOARD_COMPONENT.advertisement, rankOrder: 1 },
					{ name: DASHBOARD_COMPONENT.examNotifications, rankOrder: 2 },
					{ name: DASHBOARD_COMPONENT.enrolled, rankOrder: 3 },
				],
				null,
			),
		})

		await waitFor(() => expect(result.current.isLoading).toBe(false))
		// Their cards are simply absent until the data lands.
		expect(cardKeys(result.current)).toEqual(["Dashboard_Enrolled_Programs"])
	})

	it("composes the ad and notifications cards once their data lands", async () => {
		server.use(
			http.get(PROGRAMS_PATH, () => envelope(programsView([]))),
			http.get(EVENTS_PATH, () => envelope(eventsView([]))),
			http.get(AD_PATH, () =>
				envelope({
					...quietAd,
					adType: "SCR",
					adminName: "May 2026",
					isRegistrationOpen: true,
				}),
			),
			http.get(NOTIFICATIONS_PATH, () =>
				envelope({
					statusMessage: null,
					statusCode: 200,
					notifications: [
						{
							notificationTitle: "Exam window",
							notificationDetails: "Scheduling opens soon.",
							notificationDate: "2026-09-01",
						},
					],
				}),
			),
		)
		const { result } = renderHookWithProviders(() => useDashboardCards(), {
			queryClient: seededClient(
				[
					{ name: DASHBOARD_COMPONENT.examNotifications, rankOrder: 1 },
					{ name: DASHBOARD_COMPONENT.advertisement, rankOrder: 2 },
				],
				null,
			),
		})

		await waitFor(() =>
			expect(cardKeys(result.current)).toEqual([
				"Dashboard_Exam_Notifications",
				"Dashboard_Advertisement",
			]),
		)
		const [notifications, ad] = result.current.cards
		expect(notifications.meta?.notifications).toHaveLength(1)
		expect(ad.title).toBe("Take the SCR exam")
		expect(ad.body).toBe("Registration is open for May 2026.")
		expect(ad.ctaUrl).toBe("/Login?start=registration/scr")
		expect(ad.ctaIsExternal).toBe(true)
	})
})
