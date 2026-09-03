/**
 * Typed fixtures for the exam-registration contract (`exam-types.ts`).
 * Typed against the api types so a contract drift breaks compilation,
 * not just runtime.
 */

import type {
	AddressInput,
	CustomerInput,
	ExamRegisterRequest,
	ExamRegisterResult,
	ExamRegistrationLoad,
	FeesResult,
	VerifyCustomerResult,
} from "@/api/registration/exam-types"

export function registrationAddress(
	overrides: Partial<AddressInput> = {},
): AddressInput {
	return {
		company: "",
		street1: "1 Main St",
		street2: "",
		street3: "",
		city: "Hoboken",
		province: "NJ",
		postalCode: "07030",
		country: "United States",
		phone: "5551234",
		...overrides,
	}
}

export function examCustomer(
	overrides: Partial<CustomerInput> = {},
): CustomerInput {
	return {
		contactId: null,
		accountId: null,
		leadId: null,
		firstName: "Ada",
		lastName: "Lovelace",
		email: "ada@example.org",
		mobilePhoneCode: "United States (+1)",
		mobilePhone: "5551234",
		smsPromotionalUpdates: false,
		title: "",
		company: "",
		...overrides,
	}
}

export function examRegisterRequest(
	overrides: Partial<ExamRegisterRequest> = {},
): ExamRegisterRequest {
	return {
		type: "frm",
		courseCode: null,
		regCode: null,
		membershipSelected: false,
		riskNetSelected: false,
		sessionId: null,
		customer: examCustomer(),
		personal: null,
		selection: {
			partSelected: "FRM Exam Part I",
			part1: { rateId: "rate-1a", siteId: "site-a1" },
			part2: null,
		},
		materials: [],
		paymentType: null,
		billingAddress: registrationAddress(),
		shippingAddress: registrationAddress(),
		billingAndShippingSame: true,
		autoRenew: false,
		consent: {
			privacyPolicy: true,
			examPolicy: true,
			osta: false,
			releaseExamResults: false,
		},
		...overrides,
	}
}

export function verifyCustomerResult(
	overrides: Partial<VerifyCustomerResult> = {},
): VerifyCustomerResult {
	return {
		isExistingCustomer: false,
		mustSignIn: false,
		sessionId: "S-1",
		contactId: "003-verified",
		accountId: "001-verified",
		leadId: null,
		...overrides,
	}
}

export function examRegisterResult(
	overrides: Partial<ExamRegisterResult> = {},
): ExamRegisterResult {
	return {
		orderId: "801-order",
		orderNumber: "ORD-1001",
		registrationId: "EA-1",
		contractId: null,
		contactId: "003-verified",
		accountId: "001-verified",
		total: 750,
		hasBilling: true,
		...overrides,
	}
}

export function feesResult(total = 100): FeesResult {
	return {
		lines: [
			{
				productCode: "EXAM",
				name: "Exam Fee",
				amount: total,
				quantity: 1,
				isEnrollment: true,
			},
		],
		subTotal: total,
		total,
		currencyCode: "USD",
		hasBilling: total > 0,
	}
}

/**
 * A two-part programme shaped like FRM's load: Part I offers an early sitting
 * with two sites and a later one with a single site (so site auto-fill has
 * something to do), Part II a single sitting with two sites. Both
 * part-specific and part-agnostic study materials are present.
 */
export function examLoad(
	overrides: Partial<ExamRegistrationLoad> = {},
): ExamRegistrationLoad {
	return {
		program: { type: "frm", kind: "exam" },
		isAuthenticated: false,
		contact: null,
		eligibility: { isEligible: true },
		examSelection: {
			partsAvailable: [
				"FRM Exam Part I",
				"FRM Exam Part II",
				"FRM Exam Part I and FRM Exam Part II",
			],
			parts: [
				{
					key: "part1",
					title: "Part I",
					admins: [
						{
							id: "rate-1a",
							adminId: "adm-1a",
							name: "May 2027",
							amount: 600,
							examStartEpoch: 100,
							sites: [
								{ id: "site-a1", name: "Boston" },
								{ id: "site-a2", name: "Chicago" },
							],
						},
						{
							id: "rate-1b",
							adminId: "adm-1b",
							name: "November 2027",
							amount: 600,
							examStartEpoch: 200,
							sites: [{ id: "site-b1", name: "London" }],
						},
					],
				},
				{
					key: "part2",
					title: "Part II",
					admins: [
						{
							id: "rate-2a",
							adminId: "adm-2a",
							name: "May 2027",
							amount: 700,
							examStartEpoch: 100,
							sites: [
								{ id: "site-c1", name: "Paris" },
								{ id: "site-c2", name: "Rome" },
							],
						},
					],
				},
			],
		},
		studyMaterials: [
			{ productCode: "SM-P1", title: "Part I Books", relatedPart: "Part 1" },
			{ productCode: "SM-P2", title: "Part II Books", relatedPart: "Part 2" },
			{ productCode: "SM-GEN", title: "Practice Exams", relatedPart: null },
		],
		countries: [
			{
				id: "cc-us",
				name: "United States",
				countryCode: "United States",
				phoneCode: "1",
			},
		],
		stripe: { useStripe: true },
		...overrides,
	}
}
