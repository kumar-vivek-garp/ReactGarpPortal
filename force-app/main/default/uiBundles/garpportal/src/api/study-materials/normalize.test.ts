import { describe, expect, it } from "vitest"

import {
	apexMaterial,
	garpLearning,
	ownedWithReg,
	studyMaterialsPayload,
} from "@/testing/factories/study-materials"

import {
	normalizeStudyMaterial,
	normalizeStudyMaterialsPayload,
	stripHtml,
} from "./normalize"

describe("normalizeStudyMaterialsPayload", () => {
	it("keeps the legacy bucket order and skips empty buckets", () => {
		const programs = normalizeStudyMaterialsPayload(
			studyMaterialsPayload({
				frrStudyMaterials: [apexMaterial({ productCode: "CBRHB" })],
				scrStudyMaterials: [],
				frmStudyMaterials: [apexMaterial({ productCode: "FRM2H" })],
				raiStudyMaterials: null,
			}),
		)

		expect(programs.map((p) => p.key)).toEqual(["frm", "frr"])
		expect(programs.map((p) => p.label)).toEqual([
			"Financial Risk Manager",
			"Financial Risk and Regulation",
		])
		expect(programs[0]?.items[0]?.id).toBe("FRM2H")
	})

	it("returns nothing when studyMaterialsInfo is missing", () => {
		expect(normalizeStudyMaterialsPayload({})).toEqual([])
		expect(normalizeStudyMaterialsPayload(null)).toEqual([])
	})
})

describe("normalizeStudyMaterial — identity and copy", () => {
	it("prefers the product code, then the eBook key, then a composed id", () => {
		expect(normalizeStudyMaterial(apexMaterial({ productCode: "SCRH" }), "scr", 0).id).toBe("SCRH")
		expect(
			normalizeStudyMaterial(
				apexMaterial({ productCode: null, eBook: { key: "KEY-1" } }),
				"scr",
				0,
			).id,
		).toBe("KEY-1")
		expect(
			normalizeStudyMaterial(
				apexMaterial({ productCode: null, title: "Guide" }),
				"scr",
				3,
			).id,
		).toBe("scr-3-Guide")
	})

	it("strips HTML from the short description and blanks to null", () => {
		expect(stripHtml("<p>Four&nbsp;books <b>here</b></p>")).toBe("Four books here")
		expect(
			normalizeStudyMaterial(ownedWithReg(), "frm", 0).description,
		).toBe("Four digital books covering Part I.")
		expect(
			normalizeStudyMaterial(apexMaterial({ shortDescription: "  " }), "frm", 0)
				.description,
		).toBeNull()
	})

	it("slices datetimes down to the day", () => {
		const item = normalizeStudyMaterial(
			apexMaterial({
				registrationDate: "2026-02-11T10:00:00.000Z",
				orderedDate: "2026-03-05T00:00:00Z",
				comingSoonDate: "2026-12-01T00:00:00Z",
			}),
			"frm",
			0,
		)
		expect(item.registrationDate).toBe("2026-02-11")
		expect(item.orderedDate).toBe("2026-03-05")
		expect(item.comingSoonDate).toBe("2026-12-01")
	})

	it("treats the legacy literal \"null\" part as no part", () => {
		const part = (value: string | null) =>
			normalizeStudyMaterial(apexMaterial({ relatedPart: value }), "frm", 0)
				.relatedPart
		expect(part("Part 1")).toBe("Part 1")
		expect(part("null")).toBeNull()
		expect(part("NULL")).toBeNull()
		expect(part("")).toBeNull()
		expect(part(null)).toBeNull()
	})

	it("coerces absent flags to false and a non-numeric price to null", () => {
		const item = normalizeStudyMaterial(
			{ title: "Bare", isOwned: null, canPurchase: undefined, price: null },
			"frm",
			0,
		)
		expect(item.isOwned).toBe(false)
		expect(item.canPurchase).toBe(false)
		expect(item.isUnPaidOrder).toBe(false)
		expect(item.price).toBeNull()
		expect(item.title).toBe("Bare")
	})
})

describe("normalizeStudyMaterial — eBook set", () => {
	it("carries the vendor titles with stringified ids and the key's expiry", () => {
		const set = normalizeStudyMaterial(ownedWithReg(), "frm", 0).eBookSet
		expect(set?.expireDate).toBe("2030-12-31")
		expect(set?.titles).toEqual([
			{ id: "111", label: "Part I", vendorId: "111", provider: "Pearson" },
			{ id: "222", label: "Part II", vendorId: "222", provider: "Pearson" },
		])
	})

	it("falls back to the key's title, then a generic label, for an unnamed item", () => {
		const set = normalizeStudyMaterial(
			apexMaterial({
				eBook: { title: "FRM eBooks", eBookItems: [{ title: null, vendorId: null }] },
			}),
			"frm",
			0,
		).eBookSet
		expect(set?.titles).toEqual([
			{ id: "FRM eBooks-0", label: "FRM eBooks", vendorId: null, provider: null },
		])
		const bare = normalizeStudyMaterial(
			apexMaterial({ eBook: { eBookItems: [{}] } }),
			"frm",
			0,
		).eBookSet
		expect(bare?.titles[0]?.label).toBe("eBook")
	})

	it("is absent when the key resolved to no items", () => {
		expect(
			normalizeStudyMaterial(
				apexMaterial({ eBook: { key: "K", keyStatus: "Active", eBookItems: [] } }),
				"frm",
				0,
			).eBookSet,
		).toBeNull()
		expect(normalizeStudyMaterial(apexMaterial(), "frm", 0).eBookSet).toBeNull()
	})
})

describe("normalizeStudyMaterial — GARP Learning add-on", () => {
	it("maps the purchasable block, with and without a pending order", () => {
		expect(normalizeStudyMaterial(garpLearning("pending"), "frm", 0).addOn).toEqual({
			kind: "purchasable",
			heading: "Upgrade for Additional Content",
			description:
				"Looking for additional prep questions? Purchase a third full-length practice exam for the FRM Part I.",
			price: 75,
			productCode: "FRM1BPPE",
			pendingOrderId: "006ADDON0000000001",
		})
		expect(
			normalizeStudyMaterial(garpLearning("purchasable"), "frm", 0).addOn,
		).toMatchObject({ kind: "purchasable", pendingOrderId: null })
	})

	it("maps the owned block", () => {
		expect(normalizeStudyMaterial(garpLearning("owned"), "frm", 0).addOn).toEqual({
			kind: "owned",
			heading: "Add-On Content",
			description:
				"Access your third full-length practice exam for the FRM Part I.",
			purchasedDate: "2026-03-20",
		})
	})

	it("is absent unless Apex attached one", () => {
		expect(normalizeStudyMaterial(garpLearning(null), "frm", 0).addOn).toBeNull()
	})

	it("supplies the legacy headings when Apex sends none", () => {
		const purchasableAddOn = normalizeStudyMaterial(
			garpLearning("purchasable", {
				GARPLearningAddOnPuchaseHeading: null,
				GARPLearningAddOnPuchaseDescription: null,
			}),
			"frm",
			0,
		).addOn
		expect(purchasableAddOn).toMatchObject({
			heading: "Upgrade for Additional Content",
			description: "",
		})
	})
})
