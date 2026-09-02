import { describe, expect, it } from "vitest"

import type { EventView } from "@/api/registration/event-types"
import {
	consentKind,
	isPostalCodeRequired,
	isProvinceRequired,
	POSTAL_DIGITS_PATTERN,
	resolveEventScreen,
	resolveIsGdpr,
	rsvpAcceptLabel,
	rsvpGateCopy,
	showActivityCard,
	showAddressCard,
	showAttendanceSelect,
	showProfessionalFields,
	showQuestionCard,
	submitLabel,
} from "./event-registration-presentation"

function eventView(overrides: Partial<EventView> = {}): EventView {
	return {
		id: "a3R1",
		title: "CECL: The Road Ahead",
		subtitle: null,
		description: null,
		startDate: "2026-09-01",
		endDate: null,
		timeZone: "America/New_York",
		location: null,
		venue: null,
		status: null,
		deliveryMode: "Virtual",
		isHybrid: false,
		isPayFor: false,
		isInviteOnly: false,
		isMembersOnly: false,
		isOnDemand: false,
		isSponsored: false,
		sponsorName: null,
		sponsorPolicyUrl: null,
		isGdprEvent: false,
		hideAddressFields: false,
		maxCapacityMet: false,
		cancellationPolicy: null,
		paymentPolicy: null,
		vanityUrl: null,
		rsvpCopy: null,
		rsvpWaitlistCopy: null,
		rsvpActivityName: null,
		rsvpActivityDetails: null,
		rsvpActivityLocation: null,
		rsvpActivityStart: null,
		rsvpActivityEnd: null,
		rsvpActivityQuestion: null,
		rsvpActivityAskDiet: false,
		eventQuestionTitle: null,
		eventQuestionDetail: null,
		professionalDetailsRequired: false,
		professionalDetailsAskTitle: false,
		chapterName: null,
		requiresFrmCertified: false,
		requiresErpCertified: false,
		requiresScrHolder: false,
		requiresRaiHolder: false,
		...overrides,
	}
}

const ELIGIBLE = { isEligible: true, message: null, signInWouldHelp: false }

describe("resolveEventScreen", () => {
	it("orders the screens: notFound > alreadyRegistered > notEligible > gate > form", () => {
		expect(
			resolveEventScreen(
				{ event_x: null, alreadyRegistered: true, eligibility: ELIGIBLE },
				{ rsvpAccepted: false },
			),
		).toBe("notFound")

		// An existing registration outranks a refusal — nothing to fix.
		expect(
			resolveEventScreen(
				{
					event_x: eventView(),
					alreadyRegistered: true,
					eligibility: { ...ELIGIBLE, isEligible: false },
				},
				{ rsvpAccepted: false },
			),
		).toBe("alreadyRegistered")

		expect(
			resolveEventScreen(
				{
					event_x: eventView({ isInviteOnly: true }),
					alreadyRegistered: false,
					eligibility: { ...ELIGIBLE, isEligible: false },
				},
				{ rsvpAccepted: false },
			),
		).toBe("notEligible")

		expect(
			resolveEventScreen(
				{
					event_x: eventView({ isInviteOnly: true }),
					alreadyRegistered: false,
					eligibility: ELIGIBLE,
				},
				{ rsvpAccepted: false },
			),
		).toBe("rsvpGate")
	})

	it("reveals the form only once the invitation is accepted", () => {
		const load = {
			event_x: eventView({ isInviteOnly: true }),
			alreadyRegistered: false,
			eligibility: ELIGIBLE,
		}
		expect(resolveEventScreen(load, { rsvpAccepted: true })).toBe("form")
	})
})

describe("rsvp gate copy", () => {
	it("becomes a waitlist join when capacity is met", () => {
		expect(rsvpAcceptLabel(true)).toBe("Join the Waitlist")
		expect(rsvpAcceptLabel(false)).toBe("Accept")
		expect(
			rsvpGateCopy(
				eventView({ maxCapacityMet: true, rsvpWaitlistCopy: "Wait here" }),
			),
		).toBe("Wait here")
		expect(rsvpGateCopy(eventView({ rsvpCopy: "Come along" }))).toBe(
			"Come along",
		)
	})
})

describe("section visibility matrix", () => {
	it("gates professional fields only for chapter meetings", () => {
		expect(showProfessionalFields("event", eventView())).toBe(true)
		expect(showProfessionalFields("webcast", eventView())).toBe(true)
		expect(showProfessionalFields("chaptermeeting", eventView())).toBe(false)
		expect(
			showProfessionalFields(
				"chaptermeeting",
				eventView({ professionalDetailsRequired: true }),
			),
		).toBe(true)
	})

	it("asks for an address only on webcasts", () => {
		expect(showAddressCard("webcast")).toBe(true)
		expect(showAddressCard("event")).toBe(false)
		expect(showAddressCard("chaptermeeting")).toBe(false)
	})

	it("asks attendance only for hybrid events", () => {
		expect(showAttendanceSelect(eventView({ isHybrid: true }))).toBe(true)
		expect(showAttendanceSelect(eventView())).toBe(false)
	})

	it("shows activity and question cards only for the event kind", () => {
		const withExtras = eventView({
			rsvpActivityName: "Networking Dinner",
			eventQuestionTitle: "Anything for the panel?",
		})
		expect(showActivityCard("event", withExtras)).toBe(true)
		expect(showActivityCard("webcast", withExtras)).toBe(false)
		expect(showQuestionCard("event", withExtras)).toBe(true)
		expect(showQuestionCard("chaptermeeting", withExtras)).toBe(false)
	})

	it("shows the sponsor consent XOR the GARP one", () => {
		expect(consentKind(eventView({ isSponsored: true }))).toBe("sponsor")
		expect(consentKind(eventView())).toBe("garp")
	})
})

describe("field rules the deployed client ignored", () => {
	it("honors the country's required flags", () => {
		expect(isPostalCodeRequired({ postalCodeRequired: true })).toBe(true)
		expect(isPostalCodeRequired(null)).toBe(false)
		expect(isProvinceRequired({ provinceRequired: true })).toBe(true)
		expect(isProvinceRequired(undefined)).toBe(false)
	})

	it("accepts only digits for the webcast postal code", () => {
		expect(POSTAL_DIGITS_PATTERN.test("10001")).toBe(true)
		expect(POSTAL_DIGITS_PATTERN.test("EC1A 1BB")).toBe(false)
	})

	it("derives GDPR from the country OR the event", () => {
		expect(resolveIsGdpr({ compliance: true }, eventView())).toBe(true)
		expect(resolveIsGdpr(null, eventView({ isGdprEvent: true }))).toBe(true)
		expect(resolveIsGdpr(null, eventView())).toBe(false)
	})
})

describe("submitLabel", () => {
	it("says where the click leads", () => {
		expect(submitLabel(0)).toBe("Complete Registration")
		expect(submitLabel(150)).toBe("Continue to Payment")
	})
})
