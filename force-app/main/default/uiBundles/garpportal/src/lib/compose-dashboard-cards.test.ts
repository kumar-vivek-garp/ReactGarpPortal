import { describe, expect, it } from "vitest"

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
