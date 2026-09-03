import { describe, expect, it } from "vitest"

import type { PersonalInput } from "@/api/registration/exam-types"
import {
	buildRegisterRequest,
	emptyAddress,
	emptySelection,
	type RegisterInput,
} from "./registration-payloads"

function registerInput(overrides: Partial<RegisterInput> = {}): RegisterInput {
	return {
		type: "frm",
		selection: emptySelection(),
		materials: [],
		paymentType: "Stripe",
		billingAddress: { ...emptyAddress(), country: "United States" },
		shippingAddress: emptyAddress(),
		billingAndShippingSame: true,
		autoRenew: false,
		membershipSelected: false,
		riskNetSelected: false,
		mobilePhoneCode: "United States (+1)",
		firstName: "Ada",
		lastName: "Lovelace",
		email: "ada@example.com",
		mobilePhone: "5551234567",
		smsPromotionalUpdates: false,
		personal: null,
		isComplianceCountry: false,
		attestPrivacyNotice: false,
		attestLimitationOfLiability: false,
		attestReleaseAndWaiver: false,
		examPolicy: true,
		candidateResponsibility: true,
		...overrides,
	}
}

function personalInput(overrides: Partial<PersonalInput> = {}): PersonalInput {
	return {
		gender: "Female",
		idType: "Passport",
		idLocation: "China",
		idNumber: "AB1234567",
		nameOnId: "Ada Lovelace",
		ostaConsent: false,
		fullNameInChinese: "",
		dateOfBirth: null,
		idExpireDate: null,
		phone: "",
		workStatus: "",
		companyName: "",
		schoolName: "",
		studentStatus: "",
		degreeName: "",
		businessEmail: "",
		professionalLevel: "",
		jobFunction: "",
		riskSpecialty: "",
		...overrides,
	}
}

describe("buildRegisterRequest — customer block", () => {
	it("nulls the record ids a guest does not have", () => {
		const request = buildRegisterRequest(registerInput())
		expect(request.sessionId).toBeNull()
		expect(request.customer.contactId).toBeNull()
		expect(request.customer.accountId).toBeNull()
		expect(request.customer.leadId).toBeNull()
	})

	it("carries a member's ids and session through", () => {
		const request = buildRegisterRequest(
			registerInput({
				sessionId: "sess",
				contactId: "003",
				accountId: "001",
				leadId: "00Q",
			}),
		)
		expect(request.sessionId).toBe("sess")
		expect(request.customer).toMatchObject({
			contactId: "003",
			accountId: "001",
			leadId: "00Q",
		})
	})

	it("names the candidate and their phone exactly as entered", () => {
		const request = buildRegisterRequest(registerInput())
		expect(request.customer).toMatchObject({
			firstName: "Ada",
			lastName: "Lovelace",
			email: "ada@example.com",
			mobilePhoneCode: "United States (+1)",
			mobilePhone: "5551234567",
			smsPromotionalUpdates: false,
		})
	})

	it("defaults title and company to empty strings, not undefined", () => {
		// Apex deserialises a typed class — the keys must be present.
		const request = buildRegisterRequest(registerInput())
		expect(request.customer.title).toBe("")
		expect(request.customer.company).toBe("")

		const withJob = buildRegisterRequest(
			registerInput({ title: "Analyst", company: "GARP" }),
		)
		expect(withJob.customer.title).toBe("Analyst")
		expect(withJob.customer.company).toBe("GARP")
	})
})

describe("buildRegisterRequest — order body", () => {
	it("reuses the fees builders for selection, materials and payment", () => {
		const selection = emptySelection()
		selection.part1 = { rateId: "a91", siteId: "" }
		const request = buildRegisterRequest(
			registerInput({
				selection,
				materials: [
					{ productCode: "FRM1H", selected: true },
					{ productCode: "FRM2H" },
				],
				paymentType: "",
			}),
		)
		expect(request.selection.part1).toEqual({ rateId: "a91", siteId: null })
		expect(request.materials).toEqual(["FRM1H"])
		expect(request.paymentType).toBeNull()
	})

	it("mirrors billing into shipping when they are the same", () => {
		expect(
			buildRegisterRequest(registerInput()).shippingAddress.country,
		).toBe("United States")
	})

	it("sends the distinct shipping address when they differ", () => {
		const request = buildRegisterRequest(
			registerInput({
				billingAndShippingSame: false,
				shippingAddress: { ...emptyAddress(), country: "Canada" },
			}),
		)
		expect(request.shippingAddress.country).toBe("Canada")
	})

	it("carries the flags and codes for the order", () => {
		const request = buildRegisterRequest(
			registerInput({
				courseCode: "FRR",
				regCode: "TEAM24",
				membershipSelected: true,
				riskNetSelected: true,
				autoRenew: true,
			}),
		)
		expect(request).toMatchObject({
			type: "frm",
			courseCode: "FRR",
			regCode: "TEAM24",
			membershipSelected: true,
			riskNetSelected: true,
			autoRenew: true,
		})
	})
})

describe("buildRegisterRequest — consent", () => {
	it("treats submitting as privacy consent outside a compliance country", () => {
		// The notice above the button says exactly this.
		const request = buildRegisterRequest(registerInput())
		expect(request.consent.privacyPolicy).toBe(true)
	})

	it("requires all three ticks in a compliance country", () => {
		const allTicked = {
			isComplianceCountry: true,
			attestPrivacyNotice: true,
			attestLimitationOfLiability: true,
			attestReleaseAndWaiver: true,
		}
		expect(
			buildRegisterRequest(registerInput(allTicked)).consent.privacyPolicy,
		).toBe(true)

		// Each tick is individually load-bearing.
		for (const missing of [
			"attestPrivacyNotice",
			"attestLimitationOfLiability",
			"attestReleaseAndWaiver",
		] as const) {
			expect(
				buildRegisterRequest(registerInput({ ...allTicked, [missing]: false }))
					.consent.privacyPolicy,
			).toBe(false)
		}
	})

	it("needs BOTH acknowledgements for examPolicy", () => {
		// Apex refuses the whole registration unless this is true.
		expect(buildRegisterRequest(registerInput()).consent.examPolicy).toBe(true)
		expect(
			buildRegisterRequest(registerInput({ examPolicy: false })).consent
				.examPolicy,
		).toBe(false)
		expect(
			buildRegisterRequest(registerInput({ candidateResponsibility: false }))
				.consent.examPolicy,
		).toBe(false)
	})

	it("derives osta from the identity block, absent means false", () => {
		expect(buildRegisterRequest(registerInput()).consent.osta).toBe(false)
		expect(
			buildRegisterRequest(
				registerInput({ personal: personalInput({ ostaConsent: false }) }),
			).consent.osta,
		).toBe(false)
		expect(
			buildRegisterRequest(
				registerInput({ personal: personalInput({ ostaConsent: true }) }),
			).consent.osta,
		).toBe(true)
	})

	it("defaults releaseExamResults to false when the form has no such box", () => {
		expect(
			buildRegisterRequest(registerInput()).consent.releaseExamResults,
		).toBe(false)
		expect(
			buildRegisterRequest(registerInput({ consentReleaseExamResults: true }))
				.consent.releaseExamResults,
		).toBe(true)
	})

	it("passes the identity block through untouched — or null", () => {
		// Apex writes the block whenever an ID number is present, so an invented
		// one would overwrite the member's stored identity.
		expect(buildRegisterRequest(registerInput()).personal).toBeNull()

		const personal = personalInput()
		expect(
			buildRegisterRequest(registerInput({ personal })).personal,
		).toBe(personal)
	})
})
