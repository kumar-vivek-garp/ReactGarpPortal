import { describe, expect, it } from "vitest"

import type { EventView } from "@/api/registration/event-types"
import { toEventFormValues } from "@/components/forms/event-registration/event-form-values"
import {
	buildEventCheckoutUrls,
	buildEventRegisterRequest,
} from "./event-registration-payloads"

/**
 * The Apex DTO's complete field list. The single highest-value assertion in
 * this feature: the register body must NEVER carry a key outside this set,
 * because Apex deserialization throws on undeclared fields.
 */
const CONTRACT_WHITELIST = new Set([
	"variant",
	"eventId",
	"email",
	"firstName",
	"lastName",
	"company",
	"jobTitle",
	"workPhone",
	"attendanceMethod",
	"address1",
	"address2",
	"city",
	"province",
	"postalCode",
	"country",
	"agreeToGarpContent",
	"agreeToSponsorContact",
	"privacyPolicyAttestation",
	"isGdpr",
	"userQuestions",
	"attendingActivity",
	"activityQuestionResponse",
	"eventQuestionResponse",
	"dietaryRestriction",
	"dietaryRestrictionDetails",
])

function eventView(overrides: Partial<EventView> = {}): EventView {
	return {
		id: "a3R1",
		title: "Test",
		subtitle: null,
		description: null,
		startDate: null,
		endDate: null,
		timeZone: null,
		location: null,
		venue: null,
		status: null,
		deliveryMode: null,
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

function filledValues() {
	return {
		...toEventFormValues(null),
		email: " a@b.com ",
		firstName: " Ada ",
		lastName: "Lovelace",
		workPhone: "5551234",
		jobTitle: "Analyst",
		company: "Babbage & Co",
		attendanceMethod: "Virtual",
		address1: "1 Main St",
		city: "New York",
		province: "NY",
		postalCode: "10001",
		country: "US",
		attendingActivity: true,
		dietaryRestriction: true,
		dietaryRestrictionDetails: "Vegetarian",
		activityQuestionResponse: "None",
		eventQuestionResponse: "Looking forward",
		agreeToGarpContent: true,
		agreeToSponsorContact: true,
		privacyPolicyAttestation: true,
	}
}

describe("buildEventRegisterRequest", () => {
	it("never posts a key outside the Apex contract, for any variant", () => {
		const richEvent = eventView({
			isHybrid: true,
			isSponsored: true,
			rsvpActivityName: "Dinner",
			rsvpActivityAskDiet: true,
			rsvpActivityQuestion: "Guests?",
			eventQuestionTitle: "Q",
			professionalDetailsRequired: true,
		})
		for (const variant of ["event", "webcast", "chaptermeeting"] as const) {
			const request = buildEventRegisterRequest(filledValues(), {
				variant,
				eventId: "a3R1",
				event: richEvent,
				selectedCountry: { compliance: true } as never,
			})
			for (const key of Object.keys(request)) {
				expect(CONTRACT_WHITELIST.has(key), `${variant}:${key}`).toBe(true)
			}
		}
	})

	it("sends address fields for webcasts only", () => {
		const values = filledValues()
		const webcast = buildEventRegisterRequest(values, {
			variant: "webcast",
			eventId: "a3R1",
			event: eventView(),
			selectedCountry: null,
		})
		expect(webcast.country).toBe("US")
		expect(webcast.postalCode).toBe("10001")

		const chapter = buildEventRegisterRequest(values, {
			variant: "chaptermeeting",
			eventId: "a3R1",
			event: eventView(),
			selectedCountry: null,
		})
		expect("country" in chapter).toBe(false)
		expect("address1" in chapter).toBe(false)
	})

	it("sends activity/question fields only when their sections rendered", () => {
		const bare = buildEventRegisterRequest(filledValues(), {
			variant: "event",
			eventId: "a3R1",
			event: eventView(),
			selectedCountry: null,
		})
		expect("attendingActivity" in bare).toBe(false)
		expect("eventQuestionResponse" in bare).toBe(false)
		expect("attendanceMethod" in bare).toBe(false)
	})

	it("sends exactly one marketing consent, chosen by sponsorship", () => {
		const sponsored = buildEventRegisterRequest(filledValues(), {
			variant: "event",
			eventId: "a3R1",
			event: eventView({ isSponsored: true }),
			selectedCountry: null,
		})
		expect(sponsored.agreeToSponsorContact).toBe(true)
		expect("agreeToGarpContent" in sponsored).toBe(false)

		const plain = buildEventRegisterRequest(filledValues(), {
			variant: "event",
			eventId: "a3R1",
			event: eventView(),
			selectedCountry: null,
		})
		expect(plain.agreeToGarpContent).toBe(true)
		expect("agreeToSponsorContact" in plain).toBe(false)
	})

	it("trims identity, fixes userQuestions empty, derives isGdpr", () => {
		const request = buildEventRegisterRequest(filledValues(), {
			variant: "event",
			eventId: "a3R1",
			event: eventView({ isGdprEvent: true }),
			selectedCountry: null,
		})
		expect(request.email).toBe("a@b.com")
		expect(request.firstName).toBe("Ada")
		expect(request.userQuestions).toBe("")
		expect(request.isGdpr).toBe(true)
	})
})

describe("buildEventCheckoutUrls", () => {
	const AT = { origin: "https://my.garp.org", pathname: "/registration/event/a3R1" }

	it("returns the provider to the route that served the form", () => {
		const { successUrl, cancelUrl } = buildEventCheckoutUrls(AT, {
			orderId: "801x",
			orderNumber: "12345",
		})
		expect(successUrl).toBe(
			"https://my.garp.org/registration/event/a3R1?stripe_return=1&oid=801x&on=12345",
		)
		// The cancel leg is NOT bare — the rollback depends on this oid.
		expect(cancelUrl).toBe(
			"https://my.garp.org/registration/event/a3R1?checkout_cancelled=1&oid=801x",
		)
	})

	it("omits the order number when the server returned none", () => {
		const { successUrl } = buildEventCheckoutUrls(AT, {
			orderId: "801x",
			orderNumber: null,
		})
		expect(successUrl).not.toContain("on=")
	})
})

describe("toEventFormValues", () => {
	it("prefills a member's identity and leaves consents unticked", () => {
		const seeded = toEventFormValues({
			id: "003",
			firstName: "Ada",
			lastName: "Lovelace",
			email: "ada@b.com",
			title: "Analyst",
			company: "Babbage",
			isMember: true,
			isInGoodStanding: true,
		})
		expect(seeded.firstName).toBe("Ada")
		expect(seeded.company).toBe("Babbage")
		expect(seeded.privacyPolicyAttestation).toBe(false)
		expect(seeded.agreeToGarpContent).toBe(false)
	})

	it("seeds the empty set for a guest", () => {
		const seeded = toEventFormValues(null)
		expect(seeded.email).toBe("")
		expect(seeded.firstName).toBe("")
	})
})
