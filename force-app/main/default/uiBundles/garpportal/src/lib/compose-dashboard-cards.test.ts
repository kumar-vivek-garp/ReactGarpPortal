import { describe, expect, it } from "vitest"

import type { CpdView } from "@/api/cpd"
import type { PortalCard } from "@/api/dashboard"
import type { MemberEvent } from "@/api/events"
import type { EnrolledProgram } from "@/api/programs"
import {
	composeDashboardCards,
	DASHBOARD_PROVIDER,
} from "./compose-dashboard-cards"

function serverCard(
	provider: string,
	rank: number,
	key = provider,
): PortalCard {
	return {
		key,
		page: "Dashboard",
		provider,
		rank,
		title: provider,
		body: null,
		ctaLabel: "Go",
		ctaUrl: "/",
		ctaIsExternal: false,
		imageUrl: null,
		eyebrow: null,
		badge: null,
		locked: false,
		dismissible: false,
		bullets: null,
		meta: {},
	}
}

function enrolled(programType: string, name: string): EnrolledProgram {
	return {
		programType,
		adminPartIName: "April 2026",
		adminPartIIName: null,
		programInformation: {
			programCode: programType,
			abbrevName: programType,
			formalName: name,
			informalName: name,
			policyURL: null,
			regLogoURL: null,
			myProgramsLogoURL: null,
			description: null,
			registrationPath: null,
		},
	}
}

function event(id: string, name: string): MemberEvent {
	return {
		eventId: id,
		eventType: "Event",
		eventName: name,
		eventStartDate: "2026-10-28",
		eventSlug: id,
		eventURL: `https://www.garp.org/event/${id}`,
		chapterId: null,
		canManageAttendance: false,
		addToCalTitle: null,
		addToCalDescription: null,
		addToCalStartDateTime: null,
		addToCalEndDateTime: null,
		addToCalTimeZone: null,
		addToCalLocation: null,
	}
}

describe("composeDashboardCards", () => {
	it("keeps exam and directory when the member has no enrollments or events", () => {
		const cards = composeDashboardCards({
			serverCards: [
				serverCard(DASHBOARD_PROVIDER.exam, 10),
				serverCard(DASHBOARD_PROVIDER.directory, 30),
			],
			enrolledPrograms: [],
			registeredEvents: [],
			showAll: false,
		})

		expect(cards.map((card) => card.provider)).toEqual([
			DASHBOARD_PROVIDER.exam,
			DASHBOARD_PROVIDER.directory,
		])
	})

	it("adds enrolled + events and hides the exam promo when enrolled", () => {
		const cards = composeDashboardCards({
			serverCards: [
				serverCard(DASHBOARD_PROVIDER.exam, 10),
				serverCard(DASHBOARD_PROVIDER.directory, 30),
			],
			enrolledPrograms: [enrolled("SCR", "Sustainability and Climate Risk (SCR®)")],
			registeredEvents: [event("symp", "GARP 2025 Financial Risk Symposium")],
			showAll: false,
		})

		expect(cards.map((card) => card.provider)).toEqual([
			DASHBOARD_PROVIDER.enrolled,
			DASHBOARD_PROVIDER.events,
			DASHBOARD_PROVIDER.directory,
		])
	})

	it("caps enrolled and event previews at two", () => {
		const cards = composeDashboardCards({
			serverCards: [],
			enrolledPrograms: [
				enrolled("SCR", "SCR"),
				enrolled("FRM", "FRM"),
				enrolled("RAI", "RAI"),
			],
			registeredEvents: [
				event("a", "A"),
				event("b", "B"),
				event("c", "C"),
			],
			showAll: false,
		})

		const enrolledCard = cards.find(
			(card) => card.provider === DASHBOARD_PROVIDER.enrolled,
		)
		const eventsCard = cards.find(
			(card) => card.provider === DASHBOARD_PROVIDER.events,
		)

		expect(enrolledCard?.meta.enrolledPrograms).toHaveLength(2)
		expect(eventsCard?.meta.upcomingEvents).toHaveLength(2)
	})

	it("showAll keeps exam, profile, and empty enrolled/events cards", () => {
		const cards = composeDashboardCards({
			serverCards: [
				serverCard(DASHBOARD_PROVIDER.exam, 10),
				serverCard(DASHBOARD_PROVIDER.directory, 30),
			],
			enrolledPrograms: [enrolled("SCR", "SCR")],
			registeredEvents: [],
			completeness: {
				percentComplete: 42,
				earnedWeight: 11,
				totalWeight: 26,
				isComplete: false,
				muted: true,
				missing: ["Phone number"],
				missingBySection: { Personal: 1 },
			},
			showAll: true,
		})

		expect(cards.map((card) => card.provider)).toEqual([
			DASHBOARD_PROVIDER.enrolled,
			DASHBOARD_PROVIDER.profile,
			DASHBOARD_PROVIDER.exam,
			DASHBOARD_PROVIDER.events,
			DASHBOARD_PROVIDER.directory,
		])
	})
})

function cpdView(overrides: Partial<CpdView> = {}): CpdView {
	return {
		statusMessage: "Success",
		statusCode: 200,
		cpdCycle: "2023/2025",
		frmTotalNeeded: null,
		frmCompleted: null,
		erpTotalNeeded: null,
		erpCompleted: null,
		scrTotalNeeded: null,
		scrCompleted: null,
		raiTotalNeeded: null,
		raiCompleted: null,
		creditsRemaining: null,
		...overrides,
	}
}

describe("CPD card", () => {
	it("is absent when the member has no CPD program", () => {
		const cards = composeDashboardCards({
			serverCards: [],
			enrolledPrograms: [],
			registeredEvents: [],
			cpd: null,
			showAll: false,
		})
		expect(
			cards.some((card) => card.provider === DASHBOARD_PROVIDER.cpd),
		).toBe(false)
	})

	/**
	 * The service sets 501 for "no completed certification" and overwrites it
	 * with 200 two lines later, so this arrives as a success with every number
	 * null. The legacy rendered a blank chart for it.
	 */
	it("is absent for a 200 response with every designation null", () => {
		const cards = composeDashboardCards({
			serverCards: [],
			enrolledPrograms: [],
			registeredEvents: [],
			cpd: cpdView(),
			showAll: false,
		})
		expect(
			cards.some((card) => card.provider === DASHBOARD_PROVIDER.cpd),
		).toBe(false)
	})

	it("renders bars and a Manage Credits CTA once a designation reports credits", () => {
		const cards = composeDashboardCards({
			serverCards: [],
			enrolledPrograms: [],
			registeredEvents: [],
			cpd: cpdView({
				frmTotalNeeded: 40,
				frmCompleted: 12,
				creditsRemaining: 28,
			}),
			showAll: false,
		})
		const card = cards.find(
			(entry) => entry.provider === DASHBOARD_PROVIDER.cpd,
		)
		expect(card?.title).toBe("2023/2025 CPD Credits")
		expect(card?.ctaLabel).toBe("Manage Credits")
		expect(card?.ctaUrl).toBe("/cpd")
		expect(card?.meta).toEqual({
			cpdRows: [{ designation: "FRM", approved: 12, required: 40 }],
			cpdRemaining: "28 credits remaining this cycle",
		})
	})

	it("uses the dashboard's own RAI requirement of 10, not the CPD page's 20", () => {
		const cards = composeDashboardCards({
			serverCards: [],
			enrolledPrograms: [],
			registeredEvents: [],
			cpd: cpdView({ raiTotalNeeded: 10, raiCompleted: 4 }),
			showAll: false,
		})
		const card = cards.find(
			(entry) => entry.provider === DASHBOARD_PROVIDER.cpd,
		)
		expect(card?.meta).toEqual({
			cpdRows: [{ designation: "RAI", approved: 4, required: 10 }],
			// creditsRemaining is null on this fixture, so no line is offered.
			cpdRemaining: null,
		})
	})

	it("sits between Enrolled Programs and My Events", () => {
		const cards = composeDashboardCards({
			serverCards: [],
			enrolledPrograms: [enrolled("FRM", "Financial Risk Manager")],
			registeredEvents: [],
			cpd: cpdView({ scrTotalNeeded: 20, scrCompleted: 5 }),
			showAll: true,
		})
		const ranked = [...cards].sort((a, b) => a.rank - b.rank)
		const providers = ranked.map((card) => card.provider)
		expect(providers.indexOf(DASHBOARD_PROVIDER.cpd)).toBeGreaterThan(
			providers.indexOf(DASHBOARD_PROVIDER.enrolled),
		)
		expect(providers.indexOf(DASHBOARD_PROVIDER.cpd)).toBeLessThan(
			providers.indexOf(DASHBOARD_PROVIDER.events),
		)
	})
})
