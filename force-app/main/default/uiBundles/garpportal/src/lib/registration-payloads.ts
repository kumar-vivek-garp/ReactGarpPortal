/**
 * Request builders for the registration endpoints.
 *
 * Kept out of the form so the exact shape Apex deserialises is readable in one
 * place — `GARP_ExamReg_Dto` uses typed inner classes, so a stray key is a
 * deserialisation failure rather than an ignored field.
 */

import type {
	AddressInput,
	FeesRequest,
	PartChoice,
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
