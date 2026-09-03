/**
 * Typed fixtures for the event-registration contract (`event-types.ts`).
 * Typed against the api types so a contract drift breaks compilation,
 * not just runtime.
 */

import type {
	EventContact,
	EventCountry,
	EventEligibility,
	EventRates,
	EventRegisterResult,
	EventRegistrationLoad,
	EventView,
} from "@/api/registration/event-types"

export function eventView(overrides: Partial<EventView> = {}): EventView {
	return {
		id: "evt-1",
		title: "Risk Summit 2026",
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

export function eventEligibility(
	overrides: Partial<EventEligibility> = {},
): EventEligibility {
	return {
		isEligible: true,
		message: null,
		signInWouldHelp: false,
		...overrides,
	}
}

export function eventContact(
	overrides: Partial<EventContact> = {},
): EventContact {
	return {
		id: "003-contact",
		firstName: "Ada",
		lastName: "Lovelace",
		email: "ada@example.test",
		title: "Analyst",
		company: "Analytical Engines",
		isMember: true,
		isInGoodStanding: true,
		...overrides,
	}
}

export function eventRates(overrides: Partial<EventRates> = {}): EventRates {
	return {
		rateId: "rate-1",
		memberAmount: 0,
		nonMemberAmount: 0,
		memberProductCode: null,
		nonMemberProductCode: null,
		rateType: null,
		endDate: null,
		amountDue: 0,
		productCode: null,
		...overrides,
	}
}

export function eventLoad(
	overrides: Partial<EventRegistrationLoad> = {},
): EventRegistrationLoad {
	return {
		variant: "event",
		isAuthenticated: false,
		event_x: eventView(),
		eligibility: eventEligibility(),
		contact: null,
		rates: null,
		membershipOffer: null,
		alreadyRegistered: false,
		existingRegistrationId: null,
		stripe: { useStripe: true },
		...overrides,
	}
}

export function eventCountry(
	overrides: Partial<EventCountry> = {},
): EventCountry {
	return {
		id: "cty-us",
		name: "United States",
		countryCode: "US",
		phoneCode: "+1",
		compliance: false,
		postalCodeRequired: false,
		provinceRequired: false,
		...overrides,
	}
}

export function eventRegisterResult(
	overrides: Partial<EventRegisterResult> = {},
): EventRegisterResult {
	return {
		registrationId: "reg-1",
		registrationNumber: "ER-1001",
		contactId: null,
		leadId: null,
		isFree: true,
		message: null,
		orderId: null,
		orderNumber: null,
		amountDue: 0,
		...overrides,
	}
}
