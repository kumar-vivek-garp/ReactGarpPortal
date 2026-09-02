/**
 * Wire types for event / webcast / chapter-meeting registration.
 *
 * The contract is Apex `GARP_ExamReg_EventDto`, served by `GARP_ExamReg_API`
 * under the `event/` prefix of the same `examreg` module the exam forms use.
 * Field names mirror the Apex exactly — a near-miss key is silently dropped on
 * reads and **throws** on writes (see `EventRegisterRequest`).
 */

/**
 * Which object family the registration targets — `Event__c`,
 * `Webcast__c` or `Chapter_Meeting__c`. Rides in the QUERY STRING
 * (`?eventType=`), never the body, and is omitted for `"event"`.
 */
export type EventVariant = "event" | "webcast" | "chaptermeeting"

/** Named `event_x` on the wire because `event` is a reserved word in Apex. */
export type EventView = {
	id: string
	title: string | null
	subtitle: string | null
	description: string | null
	startDate: string | null
	endDate: string | null
	timeZone: string | null
	location: string | null
	venue: string | null
	status: string | null
	deliveryMode: string | null
	isHybrid: boolean
	isPayFor: boolean
	isInviteOnly: boolean
	isMembersOnly: boolean
	isOnDemand: boolean
	isSponsored: boolean
	sponsorName: string | null
	sponsorPolicyUrl: string | null
	isGdprEvent: boolean
	hideAddressFields: boolean
	maxCapacityMet: boolean
	cancellationPolicy: string | null
	paymentPolicy: string | null
	vanityUrl: string | null
	// event only
	rsvpCopy: string | null
	rsvpWaitlistCopy: string | null
	rsvpActivityName: string | null
	rsvpActivityDetails: string | null
	rsvpActivityLocation: string | null
	rsvpActivityStart: string | null
	rsvpActivityEnd: string | null
	rsvpActivityQuestion: string | null
	rsvpActivityAskDiet: boolean
	eventQuestionTitle: string | null
	eventQuestionDetail: string | null
	// chapter meeting only
	professionalDetailsRequired: boolean
	professionalDetailsAskTitle: boolean
	chapterName: string | null
	// webcast only — enforced SERVER-side; surfaced to us via `eligibility`
	requiresFrmCertified: boolean
	requiresErpCertified: boolean
	requiresScrHolder: boolean
	requiresRaiHolder: boolean
}

export type EventEligibility = {
	isEligible: boolean
	message: string | null
	/** The only bar is being a guest — offer Sign In, not an error. */
	signInWouldHelp: boolean
}

export type EventContact = {
	id: string | null
	firstName: string | null
	lastName: string | null
	email: string | null
	title: string | null
	company: string | null
	isMember: boolean
	isInGoodStanding: boolean
}

export type EventRates = {
	rateId: string | null
	memberAmount: number | null
	nonMemberAmount: number | null
	memberProductCode: string | null
	nonMemberProductCode: string | null
	rateType: string | null
	endDate: string | null
	/** What THIS caller pays — member status already applied server-side. */
	amountDue: number
	productCode: string | null
}

/** `GET event/info` — everything the panel and form need, in one load. */
export type EventRegistrationLoad = {
	variant: EventVariant
	isAuthenticated: boolean
	event_x: EventView | null
	eligibility: EventEligibility
	contact: EventContact | null
	rates: EventRates | null
	membershipOffer: { productCode: string | null; amount: number | null } | null
	alreadyRegistered: boolean
	existingRegistrationId: string | null
	stripe: { useStripe: boolean }
}

export type EventCountry = {
	id: string
	name: string
	countryCode: string | null
	phoneCode: string | null
	compliance: boolean
	postalCodeRequired: boolean
	provinceRequired: boolean
}

/** `GET event/options` — only `countries` is consumed (webcast address card). */
export type EventOptions = {
	countries: EventCountry[]
	professionalLevels: string[]
	jobFunctions: string[]
	riskSpecialties: string[]
}

/**
 * `POST event/register` body — a CLOSED set.
 *
 * Apex deserializes into `GARP_ExamReg_EventDto.RegisterRequest`, which
 * **throws on any field it does not declare**. Never add a key here without
 * the backend adding it first, and never build this with a spread of form
 * state — `lib/event-registration-payloads.ts` constructs it key by key and a
 * test pins the whitelist.
 */
export type EventRegisterRequest = {
	variant: EventVariant
	eventId: string
	email: string
	firstName: string
	lastName: string
	company?: string
	jobTitle?: string
	workPhone?: string
	attendanceMethod?: string
	address1?: string
	address2?: string
	city?: string
	province?: string
	postalCode?: string
	country?: string
	agreeToGarpContent?: boolean
	agreeToSponsorContact?: boolean
	privacyPolicyAttestation?: boolean
	isGdpr?: boolean
	userQuestions?: string
	attendingActivity?: boolean
	activityQuestionResponse?: string
	eventQuestionResponse?: string
	dietaryRestriction?: boolean
	dietaryRestrictionDetails?: string
}

export type EventRegisterResult = {
	registrationId: string | null
	registrationNumber: string | null
	contactId: string | null
	leadId: string | null
	isFree: boolean
	message: string | null
	/** Paid registrations only: the staged order to take to checkout. */
	orderId: string | null
	orderNumber: string | null
	amountDue: number
}
