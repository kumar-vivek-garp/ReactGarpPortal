/**
 * Request builders for the registration endpoints.
 *
 * Kept out of the form so the exact shape Apex deserialises is readable in one
 * place — `GARP_ExamReg_Dto` uses typed inner classes, so a stray key is a
 * deserialisation failure rather than an ignored field.
 */

import type {
	AddressInput,
	ExamRegisterRequest,
	FeesRequest,
	PartChoice,
	PersonalInput,
	SelectionInput,
	StudyMaterialView,
} from "@/api/registration/exam-types"
import { phoneCodeDigits } from "@/lib/registration-presentation"

export type RegistrationAddress = {
	company: string
	street1: string
	street2: string
	street3: string
	city: string
	province: string
	postalCode: string
	country: string
	phone: string
}

export function emptyAddress(): RegistrationAddress {
	return {
		company: "",
		street1: "",
		street2: "",
		street3: "",
		city: "",
		province: "",
		postalCode: "",
		country: "",
		phone: "",
	}
}

export function addressInput(address: RegistrationAddress): AddressInput {
	return { ...address }
}

/** The candidate's part / sitting / site choices. */
export type ExamSelectionState = {
	partSelected: string
	part1: { rateId: string; siteId: string }
	part2: { rateId: string; siteId: string }
}

export function emptySelection(): ExamSelectionState {
	return {
		partSelected: "",
		part1: { rateId: "", siteId: "" },
		part2: { rateId: "", siteId: "" },
	}
}

/**
 * An unchosen part is `null`, never `{rateId: "", siteId: ""}`.
 *
 * Not cosmetic: Apex casts these straight to Ids, so an empty string fails the
 * whole request with `500 "Invalid id: "` — which reads like a server fault
 * rather than "you have not picked Part II yet". Verified against the org.
 */
function partChoice(part: {
	rateId: string
	siteId: string
}): PartChoice | null {
	if (!part.rateId) return null
	return { rateId: part.rateId, siteId: part.siteId || null }
}

export function selectionInput(selection: ExamSelectionState): SelectionInput {
	return {
		partSelected: selection.partSelected || null,
		part1: partChoice(selection.part1),
		part2: partChoice(selection.part2),
	}
}

/** Product codes the candidate added. Included items are server-side. */
export function selectedMaterialCodes(
	materials: Array<StudyMaterialView & { selected?: boolean }>,
): string[] {
	return materials
		.filter((material) => material.selected === true)
		.map((material) => material.productCode)
}

export type FeesInput = {
	type: string
	courseCode?: string | null
	regCode?: string | null
	contactId?: string | null
	selection: ExamSelectionState
	materials: Array<StudyMaterialView & { selected?: boolean }>
	paymentType: string
	billingAddress: RegistrationAddress
	shippingAddress: RegistrationAddress
	billingAndShippingSame: boolean
	autoRenew: boolean
	membershipSelected: boolean
	riskNetSelected: boolean
	mobilePhoneCode: string
}

/**
 * Prices the current cart. Shipping resolves to the billing address whenever
 * "same as billing" applies, so the server never has to know which box the UI
 * happened to show.
 */
export function buildFeesRequest(input: FeesInput): FeesRequest {
	return {
		type: input.type,
		courseCode: input.courseCode ?? null,
		regCode: input.regCode ?? null,
		membershipSelected: input.membershipSelected === true,
		riskNetSelected: input.riskNetSelected === true,
		contactId: input.contactId ?? null,
		selection: selectionInput(input.selection),
		materials: selectedMaterialCodes(input.materials),
		paymentType: input.paymentType || null,
		billingAddress: addressInput(input.billingAddress),
		shippingAddress: addressInput(
			input.billingAndShippingSame
				? input.billingAddress
				: input.shippingAddress,
		),
		billingAndShippingSame: input.billingAndShippingSame === true,
		autoRenew: input.autoRenew === true,
		mobilePhoneCodeDigits: phoneCodeDigits(input.mobilePhoneCode),
	}
}

/* ===================== address translation ===================== */

/**
 * The member-portal address shape, which is NOT the registration one.
 *
 * `personal-info` says `address1..3` / `state`; the registration payload says
 * `street1..3` / `province`. Same nine facts, different names, so prefilling a
 * registration from a member's record has to translate rather than spread.
 */
export type PortalAddressFields = {
	company: string
	address1: string
	address2: string
	address3: string
	country: string
	city: string
	state: string
	postalCode: string
	phone: string
}

export function toRegistrationAddress(
	address: Partial<PortalAddressFields> | null | undefined,
): RegistrationAddress {
	if (!address) return emptyAddress()
	return {
		company: address.company ?? "",
		street1: address.address1 ?? "",
		street2: address.address2 ?? "",
		street3: address.address3 ?? "",
		city: address.city ?? "",
		province: address.state ?? "",
		postalCode: address.postalCode ?? "",
		country: address.country ?? "",
		phone: address.phone ?? "",
	}
}

/**
 * The composite dial code the registration payload wants.
 *
 * `personal-info` stores a bare `"+1"`, but Apex reads a country out of this
 * field as well as digits, so the registration form needs
 * `"United States (+1)"`. Matching on the dial code alone would pick whichever
 * country happens to sort first, so the member's own country breaks the tie.
 */
export function toRegistrationPhoneCode(
	bareCode: string | null | undefined,
	countryName: string | null | undefined,
	countries: Array<{ name: string; countryCode: string; phoneCode?: string | null }>,
): string {
	const digits = (bareCode ?? "").replace(/[^0-9]/g, "")
	if (!digits) return ""

	const matches = countries.filter(
		(country) => (country.phoneCode ?? "").replace(/[^0-9]/g, "") === digits,
	)
	if (matches.length === 0) return ""

	const preferred =
		matches.find((country) => country.name === countryName) ?? matches[0]
	return `${preferred.countryCode} (+${digits})`
}

/* ===================== register ===================== */

export type RegisterInput = FeesInput & {
	sessionId?: string | null
	contactId?: string | null
	accountId?: string | null
	leadId?: string | null
	firstName: string
	lastName: string
	email: string
	mobilePhone: string
	smsPromotionalUpdates: boolean
	title?: string
	company?: string
	/** Only sent when a chosen exam centre is an OSTA site. */
	personal: PersonalInput | null
	/** True when the billing country carries a GDPR/CASL tag. */
	isComplianceCountry: boolean
	attestPrivacyNotice: boolean
	attestLimitationOfLiability: boolean
	attestReleaseAndWaiver: boolean
	examPolicy: boolean
	candidateResponsibility: boolean
	consentReleaseExamResults?: boolean
}

/**
 * The body for BOTH `verifyAddress` and `register` — Apex takes the identical
 * shape for each, so building it twice would be two chances to diverge.
 *
 * Two collapses happen here, and both are the server's model rather than ours:
 *
 * - `privacyPolicy` is the three compliance ticks ANDed together, and is
 *   simply `true` for a country with no compliance tag — those candidates
 *   agree by submitting, which is what the notice above the button says.
 * - `examPolicy` is the exam-policy AND candidate-responsibility
 *   acknowledgements. Apex refuses the whole registration unless it is true.
 */
export function buildRegisterRequest(input: RegisterInput): ExamRegisterRequest {
	return {
		type: input.type,
		courseCode: input.courseCode ?? null,
		regCode: input.regCode ?? null,
		membershipSelected: input.membershipSelected === true,
		riskNetSelected: input.riskNetSelected === true,
		sessionId: input.sessionId ?? null,
		customer: {
			contactId: input.contactId ?? null,
			accountId: input.accountId ?? null,
			leadId: input.leadId ?? null,
			firstName: input.firstName,
			lastName: input.lastName,
			email: input.email,
			mobilePhoneCode: input.mobilePhoneCode,
			mobilePhone: input.mobilePhone,
			smsPromotionalUpdates: input.smsPromotionalUpdates === true,
			title: input.title ?? "",
			company: input.company ?? "",
		},
		personal: input.personal,
		selection: selectionInput(input.selection),
		materials: selectedMaterialCodes(input.materials),
		paymentType: input.paymentType || null,
		billingAddress: addressInput(input.billingAddress),
		shippingAddress: addressInput(
			input.billingAndShippingSame
				? input.billingAddress
				: input.shippingAddress,
		),
		billingAndShippingSame: input.billingAndShippingSame === true,
		autoRenew: input.autoRenew === true,
		consent: {
			privacyPolicy: input.isComplianceCountry
				? input.attestPrivacyNotice === true &&
					input.attestLimitationOfLiability === true &&
					input.attestReleaseAndWaiver === true
				: true,
			examPolicy:
				input.examPolicy === true && input.candidateResponsibility === true,
			osta: input.personal?.ostaConsent === true,
			releaseExamResults: input.consentReleaseExamResults === true,
		},
	}
}
