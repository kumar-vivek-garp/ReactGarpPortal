import { describe, expect, it } from "vitest"

import type {
	ExamAdminView,
	FeeLine,
	StudyMaterialView,
} from "@/api/registration/exam-types"
import {
	defaultPaymentType,
	idFormatError,
	isComplianceCountry,
	isExamKind,
	isOfflinePayment,
	isOstaRequired,
	isPaymentAllowed,
	isOutOfOrder,
	isPart1Active,
	isPart2Active,
	resolvePartSelection,
	showAddresses,
	showAutorenew,
	showCandidateAcknowledgements,
	showSubtotal,
	sortAdmins,
	sortFeeLines,
	splitStudyMaterials,
	submitLabel,
	phoneCodeDigits,
	visibleStudyMaterials,
} from "@/lib/registration-presentation"
import {
	buildFeesRequest,
	buildRegisterRequest,
	emptyAddress,
	emptySelection,
	selectionInput,
	toRegistrationAddress,
	toRegistrationPhoneCode,
} from "@/lib/registration-payloads"

const admin = (id: string, epoch: number): ExamAdminView => ({
	id,
	examStartEpoch: epoch,
	sites: [],
})

const adminWithSites = (id: string, siteIds: string[]): ExamAdminView => ({
	id,
	examStartEpoch: 100,
	sites: siteIds.map((siteId) => ({ id: siteId, name: siteId })),
})

const material = (
	productCode: string,
	overrides: Partial<StudyMaterialView> = {},
): StudyMaterialView => ({ productCode, ...overrides })

describe("part activity", () => {
	// The live FRM payload offers exactly these two options.
	it("activates part 1 only for the Part I option", () => {
		expect(isPart1Active("FRM Exam Part I")).toBe(true)
		expect(isPart2Active("FRM Exam Part I")).toBe(false)
	})

	it("activates BOTH parts for the combined option", () => {
		const both = "FRM Exam Part I and FRM Exam Part II"
		expect(isPart1Active(both)).toBe(true)
		expect(isPart2Active(both)).toBe(true)
	})

	// The whole point of the negative lookahead: "Part II" contains "Part I".
	it("does not activate part 1 for a Part II only option", () => {
		expect(isPart1Active("FRM Exam Part II")).toBe(false)
		expect(isPart2Active("FRM Exam Part II")).toBe(true)
	})
})

describe("resolvePartSelection", () => {
	const admins = [
		adminWithSites("early", ["s1", "s2"]),
		adminWithSites("late", ["s3"]),
	]

	it("defaults to the first sitting when none is chosen", () => {
		// A part with one sitting renders as a statement, not a control — without
		// this default the cart would never price.
		expect(resolvePartSelection(true, { rateId: "", siteId: "" }, admins)).toEqual(
			{ rateId: "early", siteId: "" },
		)
	})

	it("fills in the only centre a sitting has", () => {
		expect(
			resolvePartSelection(true, { rateId: "late", siteId: "" }, admins),
		).toEqual({ rateId: "late", siteId: "s3" })
	})

	it("drops a centre left over from a different sitting", () => {
		expect(
			resolvePartSelection(true, { rateId: "late", siteId: "s1" }, admins),
		).toEqual({ rateId: "late", siteId: "s3" })
	})

	it("resolves an inactive part to nothing", () => {
		expect(
			resolvePartSelection(false, { rateId: "early", siteId: "s1" }, admins),
		).toEqual({ rateId: "", siteId: "" })
	})
})

describe("isOutOfOrder", () => {
	it("refuses a Part II that starts before Part I", () => {
		expect(isOutOfOrder(true, true, admin("a", 200), admin("b", 100))).toBe(true)
	})

	// Both parts of one sitting share a window — this is the normal booking.
	it("allows both parts in the same window", () => {
		expect(isOutOfOrder(true, true, admin("a", 100), admin("b", 100))).toBe(false)
	})
})

describe("isOstaRequired", () => {
	it("fires when either chosen centre is in China", () => {
		const china = { id: "s1", name: "China", isOSTA: true }
		const us = { id: "s2", name: "United States", isOSTA: false }
		expect(isOstaRequired(us, china)).toBe(true)
		expect(isOstaRequired(us, null)).toBe(false)
	})
})

describe("study materials", () => {
	const materials = [
		material("FRM1H", { relatedPart: "Part 1" }),
		material("FRM2H", { relatedPart: "Part 2" }),
		material("ANY", { relatedPart: null }),
	]

	it("hides the other part's materials", () => {
		expect(
			visibleStudyMaterials(materials, true, false).map((m) => m.productCode),
		).toEqual(["FRM1H", "ANY"])
	})

	it("offers a selectable comp item rather than listing it as included", () => {
		// It is free but must be ADDED, because shipping is still chargeable.
		const result = splitStudyMaterials([
			material("FRMBP", { isComp: true }),
			material("HARDBOOK", { isComp: true, isCompSelectable: true }),
			material("FRM1H", { price: 300 }),
		])
		expect(result.included.map((m) => m.productCode)).toEqual(["FRMBP"])
		expect(result.offered.map((m) => m.productCode)).toEqual([
			"HARDBOOK",
			"FRM1H",
		])
	})
})

describe("cart", () => {
	it("drops tax lines and orders enrolment, paid, then included", () => {
		// Mirrors the live FRM cart.
		const lines: FeeLine[] = [
			{ productCode: "FRMBP", amount: 0, isComp: true },
			{ productCode: "FRM1S", amount: 800 },
			{ productCode: "VAT", amount: 90, isTax: true },
			{ productCode: "FRM1", amount: 400, isEnrollment: true },
			{ productCode: "FRM1H", amount: 300 },
		]
		expect(sortFeeLines(lines).map((l) => l.productCode)).toEqual([
			"FRM1",
			"FRM1S",
			"FRM1H",
			"FRMBP",
		])
	})

	it("hides a subtotal that would just repeat the total", () => {
		expect(showSubtotal([{ amount: 800 }])).toBe(false)
		expect(showSubtotal([{ amount: 800 }, { amount: 300 }])).toBe(true)
	})

	it("orders sittings by exam start without mutating the input", () => {
		const input = [admin("late", 300), admin("early", 100)]
		expect(sortAdmins(input).map((a) => a.id)).toEqual(["early", "late"])
		expect(input.map((a) => a.id)).toEqual(["late", "early"])
	})
})

describe("submitLabel", () => {
	it("reads Register when there is nothing to pay", () => {
		expect(submitLabel(false, "")).toBe("Register")
	})

	it("distinguishes an immediate charge from an invoiced order", () => {
		expect(submitLabel(true, "Stripe")).toBe("Pay and Register")
		expect(submitLabel(true, "Wire Transfer")).toBe("Submit Order")
	})
})

describe("payload", () => {
	it("sends null for an unchosen part, never empty ids", () => {
		// Apex casts these straight to Ids: `{rateId: ""}` fails the whole
		// request with 500 "Invalid id: ". Verified against the org.
		const selection = emptySelection()
		selection.partSelected = "FRM Exam Part I"
		selection.part1 = { rateId: "a91", siteId: "a1e" }

		expect(selectionInput(selection)).toEqual({
			partSelected: "FRM Exam Part I",
			part1: { rateId: "a91", siteId: "a1e" },
			part2: null,
		})
	})

	it("sends only ticked materials and the dial digits", () => {
		const request = buildFeesRequest({
			type: "frm",
			selection: emptySelection(),
			materials: [
				{ productCode: "FRM1H", selected: true },
				{ productCode: "FRM2H", selected: false },
			],
			paymentType: "",
			billingAddress: { ...emptyAddress(), country: "United States" },
			shippingAddress: emptyAddress(),
			billingAndShippingSame: true,
			autoRenew: false,
			membershipSelected: false,
			riskNetSelected: false,
			mobilePhoneCode: "United States (+1)",
		})

		expect(request.materials).toEqual(["FRM1H"])
		expect(request.mobilePhoneCodeDigits).toBe("1")
		// An empty payment type is null, not "".
		expect(request.paymentType).toBeNull()
		// Shipping mirrors billing when they are the same.
		expect(request.shippingAddress.country).toBe("United States")
	})

	it("keeps only dial digits from the composite phone code", () => {
		expect(phoneCodeDigits("China (+86)")).toBe("86")
		expect(phoneCodeDigits("")).toBeNull()
	})
})

describe("idFormatError", () => {
	// Apex validates NONE of this — if these rules are wrong, bad ID data is
	// simply saved onto the Contact.
	it("requires exactly 9 characters for a China passport", () => {
		expect(idFormatError("China", "Passport", "AB123456")).toBe(
			"Your ID must be 9 characters long.",
		)
		expect(idFormatError("China", "Passport", "AB1234567")).toBeNull()
	})

	it("rejects I and O in a China passport", () => {
		// Too easily confused with 1 and 0 on a printed document.
		const message =
			'Your ID must only contain numbers and letters, not including "I" or "O".'
		expect(idFormatError("China", "Passport", "ABI234567")).toBe(message)
		expect(idFormatError("China", "Passport", "ABO234567")).toBe(message)
		expect(idFormatError("China", "Passport", "ABH234567")).toBeNull()
	})

	it("requires 18 characters for a China non-passport ID", () => {
		expect(idFormatError("China", "Driver's License", "12345678901234567")).toBe(
			"Your ID should consist of 18 numbers or letters.",
		)
		expect(
			idFormatError("China", "Driver's License", "123456789012345678"),
		).toBeNull()
	})

	it("allows 5–10 for a non-China passport", () => {
		expect(idFormatError("Non-China", "Passport", "1234")).not.toBeNull()
		expect(idFormatError("Non-China", "Passport", "12345")).toBeNull()
		expect(idFormatError("Non-China", "Passport", "1234567890")).toBeNull()
		expect(idFormatError("Non-China", "Passport", "12345678901")).not.toBeNull()
	})

	it("allows 5–25 for any other non-China ID", () => {
		expect(idFormatError("Non-China", "Driver's License", "1234")).not.toBeNull()
		expect(
			idFormatError("Non-China", "Driver's License", "A".repeat(25)),
		).toBeNull()
		expect(
			idFormatError("Non-China", "Driver's License", "A".repeat(26)),
		).not.toBeNull()
	})

	it("says nothing about an empty value — that is the required check's job", () => {
		expect(idFormatError("China", "Passport", "")).toBeNull()
	})
})

describe("payment rules", () => {
	const usa = { creditCardAllowed: true, wireAllowed: true, achAllowed: true }
	const cardOnly = {
		creditCardAllowed: true,
		wireAllowed: false,
		achAllowed: false,
	}

	it("leaves wire and ACH open before a country is chosen", () => {
		expect(isPaymentAllowed("Wire Transfer", null, true)).toBe(true)
		expect(isPaymentAllowed("ACH", null, true)).toBe(true)
	})

	it("gates card on the org switch as well as the country", () => {
		expect(isPaymentAllowed("Stripe", usa, false)).toBe(false)
		expect(isPaymentAllowed("Stripe", usa, true)).toBe(true)
	})

	it("prefers card, then wire, then ACH", () => {
		expect(defaultPaymentType(usa, true, "")).toBe("Stripe")
		expect(defaultPaymentType(usa, false, "")).toBe("Wire Transfer")
	})

	it("keeps a still-valid choice when the country changes", () => {
		expect(defaultPaymentType(usa, true, "ACH")).toBe("ACH")
	})

	it("replaces a choice the new country forbids", () => {
		// Silently leaving it would fail at submit instead of at the choice.
		expect(defaultPaymentType(cardOnly, true, "ACH")).toBe("Stripe")
	})

	it("shows addresses only for the offline methods", () => {
		expect(showAddresses("Stripe")).toBe(false)
		expect(showAddresses("")).toBe(false)
		expect(showAddresses("Wire Transfer")).toBe(true)
		expect(showAddresses("ACH")).toBe(true)
	})

	it("knows which methods carry the processing fee", () => {
		expect(isOfflinePayment("Wire Transfer")).toBe(true)
		expect(isOfflinePayment("Stripe")).toBe(false)
	})
})

describe("showAutorenew", () => {
	it("needs a card order AND a membership in the cart", () => {
		expect(showAutorenew(false, "Stripe", true)).toBe(true)
		expect(showAutorenew(false, "Wire Transfer", true)).toBe(false)
		expect(showAutorenew(false, "Stripe", false)).toBe(false)
	})

	it("counts a course's membership upsell as a membership", () => {
		// GarpAppv1's `form.membership` branch: adding the MEMI upsell on a
		// card order asks about auto-renew exactly as a comp membership does.
		expect(showAutorenew(false, "Stripe", false, true)).toBe(true)
		expect(showAutorenew(false, "Wire Transfer", false, true)).toBe(false)
		expect(showAutorenew(false, "Stripe", false, false)).toBe(false)
	})

	it("does not ask someone who already has it on", () => {
		expect(showAutorenew(true, "Stripe", true)).toBe(false)
		expect(showAutorenew(true, "Stripe", false, true)).toBe(false)
	})
})

describe("isComplianceCountry", () => {
	const countries = [
		{ countryCode: "Germany", compliance: true },
		{ countryCode: "United States", compliance: false },
	]

	it("is true only for a country carrying the tag", () => {
		expect(isComplianceCountry(countries, "Germany")).toBe(true)
		expect(isComplianceCountry(countries, "United States")).toBe(false)
		expect(isComplianceCountry(countries, "")).toBe(false)
	})
})

describe("buildRegisterRequest", () => {
	const base = {
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
	}

	it("treats submitting as consent outside a compliance country", () => {
		// The notice above the button says exactly this, so the three unticked
		// boxes must not block a US registration.
		const request = buildRegisterRequest(base)
		expect(request.consent.privacyPolicy).toBe(true)
	})

	it("requires all three ticks in a compliance country", () => {
		const partial = buildRegisterRequest({
			...base,
			isComplianceCountry: true,
			attestPrivacyNotice: true,
			attestLimitationOfLiability: true,
		})
		expect(partial.consent.privacyPolicy).toBe(false)

		const complete = buildRegisterRequest({
			...base,
			isComplianceCountry: true,
			attestPrivacyNotice: true,
			attestLimitationOfLiability: true,
			attestReleaseAndWaiver: true,
		})
		expect(complete.consent.privacyPolicy).toBe(true)
	})

	it("needs BOTH acknowledgements for examPolicy", () => {
		// Apex refuses the whole registration unless this is true.
		expect(
			buildRegisterRequest({ ...base, candidateResponsibility: false }).consent
				.examPolicy,
		).toBe(false)
		expect(buildRegisterRequest(base).consent.examPolicy).toBe(true)
	})

	it("omits the identity block when no China centre is chosen", () => {
		// Apex writes the block whenever an ID number is present, so sending an
		// unwanted one would overwrite the member's stored identity.
		expect(buildRegisterRequest(base).personal).toBeNull()
		expect(buildRegisterRequest(base).consent.osta).toBe(false)
	})

	it("carries the identity consent through when the block is present", () => {
		const request = buildRegisterRequest({
			...base,
			personal: {
				gender: "Female",
				idType: "Passport",
				idLocation: "China",
				idNumber: "AB1234567",
				nameOnId: "Ada Lovelace",
				ostaConsent: true,
				fullNameInChinese: "阿达",
				dateOfBirth: "1990-01-01",
				idExpireDate: "2030-01-01",
				phone: "5551234567",
				workStatus: "Working",
				companyName: "GARP",
				schoolName: "Somewhere",
				studentStatus: "Not In School",
				degreeName: "BSc",
				businessEmail: "",
				professionalLevel: "",
				jobFunction: "",
				riskSpecialty: "",
			},
		})
		expect(request.personal?.idNumber).toBe("AB1234567")
		expect(request.consent.osta).toBe(true)
	})

	it("mirrors billing into shipping when they are the same", () => {
		const request = buildRegisterRequest(base)
		expect(request.shippingAddress.country).toBe("United States")
	})

	it("sends the distinct shipping address when they differ", () => {
		const request = buildRegisterRequest({
			...base,
			billingAndShippingSame: false,
			shippingAddress: { ...emptyAddress(), country: "Canada" },
		})
		expect(request.shippingAddress.country).toBe("Canada")
	})
})

describe("address + phone translation", () => {
	const countries = [
		{ name: "United States", countryCode: "United States", phoneCode: "1" },
		{ name: "Canada", countryCode: "Canada", phoneCode: "1" },
		{ name: "China", countryCode: "China", phoneCode: "86" },
	]

	it("renames the portal address fields to the registration ones", () => {
		expect(
			toRegistrationAddress({
				company: "GARP",
				address1: "111 Town Square",
				address2: "Floor 14",
				address3: "",
				city: "Jersey City",
				state: "NJ",
				postalCode: "07310",
				country: "United States",
				phone: "5551234567",
			}),
		).toEqual({
			company: "GARP",
			street1: "111 Town Square",
			street2: "Floor 14",
			street3: "",
			city: "Jersey City",
			province: "NJ",
			postalCode: "07310",
			country: "United States",
			phone: "5551234567",
		})
	})

	it("returns an empty address rather than throwing on nothing", () => {
		expect(toRegistrationAddress(null).country).toBe("")
	})

	it("builds the composite phone code Apex expects", () => {
		expect(
			toRegistrationPhoneCode("+86", "China", countries),
		).toBe("China (+86)")
	})

	it("breaks a shared dial code using the member's own country", () => {
		// The US and Canada both dial +1; picking the first match would put
		// the wrong country on the order.
		expect(toRegistrationPhoneCode("+1", "Canada", countries)).toBe(
			"Canada (+1)",
		)
		expect(toRegistrationPhoneCode("+1", "United States", countries)).toBe(
			"United States (+1)",
		)
	})

	it("is empty when there is no code to translate", () => {
		expect(toRegistrationPhoneCode("", "United States", countries)).toBe("")
		expect(toRegistrationPhoneCode("+999", "Nowhere", countries)).toBe("")
	})
})

describe("programme kind", () => {
	it("treats an absent kind as an exam", () => {
		// The conservative default: the exam path asks for more, rather than
		// skipping a card the server then demands at submit.
		expect(isExamKind(undefined)).toBe(true)
		expect(isExamKind(null)).toBe(true)
		expect(isExamKind("exam")).toBe(true)
	})

	it("knows a course and a membership are not exams", () => {
		expect(isExamKind("course")).toBe(false)
		expect(isExamKind("membership")).toBe(false)
	})
})

describe("showCandidateAcknowledgements", () => {
	it("asks an exam candidate, and nobody else", () => {
		// GARP_ExamReg_RegService requires consent.examPolicy for kind == 'exam'
		// only; a course has no exam policy to agree to.
		expect(showCandidateAcknowledgements("exam")).toBe(true)
		expect(showCandidateAcknowledgements("course")).toBe(false)
		expect(showCandidateAcknowledgements("membership")).toBe(false)
	})
})


