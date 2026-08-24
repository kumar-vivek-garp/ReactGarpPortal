import { describe, expect, it } from "vitest"

import type { CpdView } from "@/api/cpd"
import type { AdInfo, DashboardComponent } from "@/api/dashboard"
import type { MemberEvent } from "@/api/events"
import type { EnrolledProgram } from "@/api/programs"
import { DASHBOARD_COMPONENT } from "@/config/dashboard"
import {
	composeDashboardCards,
	DASHBOARD_PROVIDER,
} from "./compose-dashboard-cards"

/** One manifest entry, as `GET dashboard` sends it. */
function component(name: string, rankOrder: number): DashboardComponent {
	return { name, rankOrder }
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

const noContent = {
	enrolledPrograms: [],
	registeredEvents: [],
	showAll: false,
}

describe("the server owns the manifest", () => {
	/**
	 * The regression this rewrite exists for. `DashboardView` declared
	 * `cards: PortalCard[]`, which no response has ever carried — the wire
	 * sends `dashboardComponents`. The manifest was therefore always empty and
	 * every card had to be invented client-side, which is why Member Directory,
	 * GBI, EPP and BenchPrep never appeared for anybody.
	 */
	it("renders Member Directory when the manifest asks for it", () => {
		const cards = composeDashboardCards({
			...noContent,
			components: [component(DASHBOARD_COMPONENT.directory, 30)],
		})
		expect(cards.map((card) => card.provider)).toEqual([
			DASHBOARD_PROVIDER.directory,
		])
	})

	it("renders nothing at all for an empty manifest", () => {
		const cards = composeDashboardCards({
			components: [],
			enrolledPrograms: [enrolled("SCR", "SCR")],
			registeredEvents: [event("a", "A")],
			cpd: cpdView({ frmTotalNeeded: 40, frmCompleted: 12 }),
			showAll: false,
		})
		expect(cards).toEqual([])
	})

	/** A card the server has learned about and this client has not stays inert. */
	it("ignores a component name it does not know", () => {
		const cards = composeDashboardCards({
			...noContent,
			components: [
				component("Some Future Card", 1),
				component(DASHBOARD_COMPONENT.directory, 30),
			],
		})
		expect(cards.map((card) => card.provider)).toEqual([
			DASHBOARD_PROVIDER.directory,
		])
	})

	/**
	 * Ordering is the server's, not ours. The previous client hard-coded CPD at
	 * rank 10 — the server puts it at 5 and reserves 10 for Advertisement.
	 */
	it("orders by the server's rankOrder", () => {
		const cards = composeDashboardCards({
			components: [
				component(DASHBOARD_COMPONENT.directory, 30),
				component(DASHBOARD_COMPONENT.cpd, 5),
				component(DASHBOARD_COMPONENT.enrolled, 1),
			],
			enrolledPrograms: [enrolled("FRM", "Financial Risk Manager")],
			registeredEvents: [],
			cpd: cpdView({ scrTotalNeeded: 20, scrCompleted: 5 }),
			showAll: false,
		})
		expect(cards.map((card) => card.provider)).toEqual([
			DASHBOARD_PROVIDER.enrolled,
			DASHBOARD_PROVIDER.cpd,
			DASHBOARD_PROVIDER.directory,
		])
	})

	/**
	 * The manifest decides eligibility; the data decides whether there is
	 * anything worth drawing. An Events entry with no registrations would
	 * otherwise render an empty card.
	 */
	it("drops a listed card whose content is empty", () => {
		const cards = composeDashboardCards({
			...noContent,
			components: [
				component(DASHBOARD_COMPONENT.enrolled, 1),
				component(DASHBOARD_COMPONENT.events, 20),
			],
		})
		expect(cards).toEqual([])
	})
})

describe("external portal cards", () => {
	it("links GBI, EPP and BenchPrep to their real paths, as full navigations", () => {
		const cards = composeDashboardCards({
			...noContent,
			components: [
				component(DASHBOARD_COMPONENT.gbi, 40),
				component(DASHBOARD_COMPONENT.epp, 50),
				component(DASHBOARD_COMPONENT.benchPrep, 60),
			],
		})

		expect(cards.map((card) => card.ctaUrl)).toEqual([
			"/gbiapp",
			"/garpEPPPortal",
			"/BenchPrepSSO",
		])
		expect(cards.every((card) => card.ctaIsExternal)).toBe(true)
	})
})

describe("previews", () => {
	it("caps enrolled and event previews at two", () => {
		const cards = composeDashboardCards({
			components: [
				component(DASHBOARD_COMPONENT.enrolled, 1),
				component(DASHBOARD_COMPONENT.events, 20),
			],
			enrolledPrograms: [
				enrolled("SCR", "SCR"),
				enrolled("FRM", "FRM"),
				enrolled("RAI", "RAI"),
			],
			registeredEvents: [event("a", "A"), event("b", "B"), event("c", "C")],
			showAll: false,
		})

		expect(
			cards.find((card) => card.provider === DASHBOARD_PROVIDER.enrolled)?.meta
				.enrolledPrograms,
		).toHaveLength(2)
		expect(
			cards.find((card) => card.provider === DASHBOARD_PROVIDER.events)?.meta
				.upcomingEvents,
		).toHaveLength(2)
	})
})

describe("the profile card", () => {
	it("needs both a manifest entry and a completeness payload", () => {
		const withoutCompleteness = composeDashboardCards({
			...noContent,
			components: [component(DASHBOARD_COMPONENT.profile, 8)],
		})
		expect(withoutCompleteness).toEqual([])

		const withCompleteness = composeDashboardCards({
			...noContent,
			components: [component(DASHBOARD_COMPONENT.profile, 8)],
			completeness: {
				percentComplete: 42,
				earnedWeight: 11,
				totalWeight: 26,
				isComplete: false,
				muted: false,
				missing: ["Phone number"],
				missingBySection: { Personal: 1 },
			},
		})
		expect(withCompleteness.map((card) => card.provider)).toEqual([
			DASHBOARD_PROVIDER.profile,
		])
		expect(withCompleteness[0].badge).toBe("42%")
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
	const listed = [component(DASHBOARD_COMPONENT.cpd, 5)]

	it("is absent when the member has no CPD program", () => {
		const cards = composeDashboardCards({
			...noContent,
			components: listed,
			cpd: null,
		})
		expect(cards).toEqual([])
	})

	/**
	 * The service sets 501 for "no completed certification" and overwrites it
	 * with 200 two lines later, so this arrives as a success with every number
	 * null. The legacy rendered a blank chart for it.
	 */
	it("is absent for a 200 response with every designation null", () => {
		const cards = composeDashboardCards({
			...noContent,
			components: listed,
			cpd: cpdView(),
		})
		expect(cards).toEqual([])
	})

	it("renders bars and a Manage Credits CTA once a designation reports credits", () => {
		const cards = composeDashboardCards({
			...noContent,
			components: listed,
			cpd: cpdView({
				frmTotalNeeded: 40,
				frmCompleted: 12,
				creditsRemaining: 28,
			}),
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
			...noContent,
			components: listed,
			cpd: cpdView({ raiTotalNeeded: 10, raiCompleted: 4 }),
		})
		expect(cards[0]?.meta).toEqual({
			cpdRows: [{ designation: "RAI", approved: 4, required: 10 }],
			// creditsRemaining is null on this fixture, so no line is offered.
			cpdRemaining: null,
		})
	})
})

describe("the Advertisement card", () => {
	const listed = [component(DASHBOARD_COMPONENT.advertisement, 10)]
	const ad = (over: Partial<AdInfo> = {}): AdInfo => ({
		statusMessage: "Success",
		statusCode: 200,
		adType: "SCR",
		adminName: "May 2026",
		isRegistrationOpen: true,
		nextAdminRegistrationOpenDate: null,
		...over,
	})

	/**
	 * `adType: null` is a SUCCESS meaning "nothing to sell" — the member sits
	 * everything already, or has a result still pending. The manifest can list
	 * the card anyway, because the dashboard decides that from a cheaper check
	 * than the ad service runs.
	 */
	it("is dropped when the server has nothing to advertise", () => {
		expect(
			composeDashboardCards({ ...noContent, components: listed, ad: ad({ adType: null }) }),
		).toEqual([])
		expect(
			composeDashboardCards({ ...noContent, components: listed, ad: null }),
		).toEqual([])
	})

	/**
	 * The dashboard advert uses `/Login?start=registration/…`. Four URL shapes
	 * reach the same flow and they carry different attribution, so this must
	 * not quietly become the `/sfdcApp#!/` one.
	 */
	it("sends Register Now to the Login registration path", () => {
		const [card] = composeDashboardCards({
			...noContent,
			components: listed,
			ad: ad(),
		})
		expect(card.ctaUrl).toBe("/Login?start=registration/scr")
		expect(card.ctaIsExternal).toBe(true)
		expect(card.title).toBe("Take the SCR exam")
	})

	/** Registration closed: still worth showing the window, but not a dead CTA. */
	it("offers no CTA while registration is closed", () => {
		const [card] = composeDashboardCards({
			...noContent,
			components: listed,
			ad: ad({ isRegistrationOpen: false, nextAdminRegistrationOpenDate: "2026-09-01" }),
		})
		expect(card.ctaUrl).toBeNull()
		expect(card.ctaLabel).toBeNull()
		expect(card.body).toContain("May 2026")
	})
})

describe("the Exam Notifications card", () => {
	const listed = [component(DASHBOARD_COMPONENT.examNotifications, 3)]
	const notice = (title: string) => ({
		notificationTitle: title,
		notificationDetails: "Details",
		notificationDate: "2026-05-01",
	})

	it("carries every notice through for the dialog", () => {
		const [card] = composeDashboardCards({
			...noContent,
			components: listed,
			examNotifications: [notice("A"), notice("B"), notice("C")],
		})
		expect(card.meta.notifications).toHaveLength(3)
		expect(card.title).toBe("New Notifications")
	})

	/**
	 * The manifest lists this only when the server saw notices, but the list is
	 * fetched separately — so an empty list means the two disagreed, and an
	 * empty card helps nobody.
	 */
	it("is dropped when the list comes back empty", () => {
		expect(
			composeDashboardCards({ ...noContent, components: listed, examNotifications: [] }),
		).toEqual([])
		expect(composeDashboardCards({ ...noContent, components: listed })).toEqual([])
	})
})
