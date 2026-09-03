import { describe, expect, it } from "vitest"

import type { RegistrationCountry } from "@/api/registration/exam-types"
import {
	EMPTY_EXAM_FORM_VALUES,
	EMPTY_EXAM_OSTA_VALUES,
	toExamFormValues,
} from "@/components/forms/exam-registration/exam-form-values"
import { personalInfoEditData } from "@/testing/factories/personal-info"

const COUNTRIES: RegistrationCountry[] = [
	{ id: "cc-ca", name: "Canada", countryCode: "Canada", phoneCode: "1" },
	{
		id: "cc-us",
		name: "United States",
		countryCode: "United States",
		phoneCode: "1",
	},
	{ id: "cc-jp", name: "Japan", countryCode: "Japan", phoneCode: "81" },
]

describe("toExamFormValues — guest", () => {
	it("returns the empty set for a guest (nothing is ever prefilled)", () => {
		expect(toExamFormValues(null, COUNTRIES)).toEqual(EMPTY_EXAM_FORM_VALUES)
	})

	it("starts every consent unticked and the cart empty in the empty set", () => {
		expect(EMPTY_EXAM_FORM_VALUES.candidateResponsibility).toBe(false)
		expect(EMPTY_EXAM_FORM_VALUES.examPolicy).toBe(false)
		expect(EMPTY_EXAM_FORM_VALUES.attestPrivacyNotice).toBe(false)
		expect(EMPTY_EXAM_FORM_VALUES.attestLimitationOfLiability).toBe(false)
		expect(EMPTY_EXAM_FORM_VALUES.attestReleaseAndWaiver).toBe(false)
		expect(EMPTY_EXAM_FORM_VALUES.smsPromotionalUpdates).toBe(false)
		expect(EMPTY_EXAM_FORM_VALUES.membershipSelected).toBe(false)
		expect(EMPTY_EXAM_FORM_VALUES.osta.ostaConsent).toBe(false)
	})
})

describe("toExamFormValues — member seed", () => {
	it("prefills identity, translates the address shape, and derives Location", () => {
		const values = toExamFormValues(personalInfoEditData(), COUNTRIES)

		expect(values.firstName).toBe("Ada")
		expect(values.lastName).toBe("Lovelace")
		expect(values.email).toBe("ada@example.org")
		expect(values.mobilePhone).toBe("5551234")
		// `address1`/`state` become `street1`/`province` — different systems,
		// same nine facts.
		expect(values.billing).toEqual({
			company: "",
			street1: "1 Main St",
			street2: "",
			street3: "",
			city: "Hoboken",
			province: "NJ",
			postalCode: "07030",
			country: "United States",
			phone: "5551234",
		})
		// Location is the billing country — one fact, established once.
		expect(values.country).toBe("United States")
	})

	it("composes the phone code as country (+digits), tie-broken by the member's own country", () => {
		// "+1" alone is ambiguous between Canada and the United States; the
		// billing country decides, not whichever sorts first.
		expect(
			toExamFormValues(personalInfoEditData(), COUNTRIES).mobilePhoneCode,
		).toBe("United States (+1)")

		const canadian = personalInfoEditData({
			billing: { ...personalInfoEditData().billing, country: "Canada" },
		})
		expect(toExamFormValues(canadian, COUNTRIES).mobilePhoneCode).toBe(
			"Canada (+1)",
		)
	})

	it("drops a dial code no offered country carries rather than inventing one", () => {
		const values = toExamFormValues(
			personalInfoEditData({ mobilePhoneCode: "+44" }),
			COUNTRIES,
		)
		expect(values.mobilePhoneCode).toBe("")
	})

	it("mirrors billing into shipping when the member ships to the same place", () => {
		const values = toExamFormValues(
			personalInfoEditData({ sameAsBilling: true }),
			COUNTRIES,
		)
		expect(values.billingAndShippingSame).toBe(true)
		expect(values.shipping).toEqual(values.billing)
	})

	it("keeps a distinct mailing address as the shipping seed otherwise", () => {
		const values = toExamFormValues(
			personalInfoEditData({ sameAsBilling: false }),
			COUNTRIES,
		)
		expect(values.billingAndShippingSame).toBe(false)
		expect(values.shipping.street1).toBe("2 Ship St")
		expect(values.shipping.city).toBe("Boston")
		expect(values.shipping.province).toBe("MA")
	})

	it("never carries a consent or the OSTA block over from the record", () => {
		const values = toExamFormValues(personalInfoEditData(), COUNTRIES)
		expect(values.candidateResponsibility).toBe(false)
		expect(values.examPolicy).toBe(false)
		expect(values.attestPrivacyNotice).toBe(false)
		expect(values.smsPromotionalUpdates).toBe(false)
		expect(values.osta).toEqual(EMPTY_EXAM_OSTA_VALUES)
	})
})
