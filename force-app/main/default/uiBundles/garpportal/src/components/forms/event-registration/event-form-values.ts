import type { PersonalInfoEditData } from "@/api/personal-info/types"
import type { EventContact } from "@/api/registration/event-types"

/**
 * Everything react-hook-form owns for an event registration — a superset of
 * the three variants; sections that are not rendered leave their fields at
 * the seed values, and the payload builder omits them from the wire.
 */
export type EventFormValues = {
	email: string
	firstName: string
	lastName: string
	workPhone: string
	jobTitle: string
	company: string
	attendanceMethod: string
	address1: string
	address2: string
	city: string
	province: string
	postalCode: string
	country: string
	attendingActivity: boolean
	dietaryRestriction: boolean
	dietaryRestrictionDetails: string
	activityQuestionResponse: string
	eventQuestionResponse: string
	agreeToGarpContent: boolean
	agreeToSponsorContact: boolean
	privacyPolicyAttestation: boolean
}

/**
 * Seeds the form, per field: the event load's own contact first, then the
 * member's profile (the exam form's source — it also answers on local dev,
 * where the gateway's admin session makes the event load return no contact),
 * then empty for a guest. Consents always start unticked: a tick recorded
 * against a policy the person did not read this time is worthless.
 */
export function toEventFormValues(
	contact: EventContact | null,
	profile: PersonalInfoEditData | null = null,
): EventFormValues {
	return {
		email: contact?.email ?? profile?.email ?? "",
		firstName: contact?.firstName ?? profile?.firstName ?? "",
		lastName: contact?.lastName ?? profile?.lastName ?? "",
		workPhone: "",
		jobTitle: contact?.title ?? "",
		company: contact?.company ?? "",
		attendanceMethod: "",
		address1: "",
		address2: "",
		city: "",
		province: "",
		postalCode: "",
		country: "",
		attendingActivity: false,
		dietaryRestriction: false,
		dietaryRestrictionDetails: "",
		activityQuestionResponse: "",
		eventQuestionResponse: "",
		agreeToGarpContent: false,
		agreeToSponsorContact: false,
		privacyPolicyAttestation: false,
	}
}
