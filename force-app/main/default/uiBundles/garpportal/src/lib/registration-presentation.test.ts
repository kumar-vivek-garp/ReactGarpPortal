import { describe, expect, it } from "vitest"

import type {
	ExamAdminView,
	FeeLine,
	StudyMaterialView,
} from "@/api/registration/exam-types"
import {
	isOstaRequired,
	isOutOfOrder,
	isPart1Active,
	isPart2Active,
	resolvePartSelection,
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
	emptyAddress,
	emptySelection,
	selectionInput,
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
