import { describe, expect, it } from "vitest"

import {
	materialPurchaseSearchSchema,
	resolveStudyMaterialsView,
	studyMaterialsSearchSchema,
} from "./study-materials"

describe("studyMaterialsSearchSchema", () => {
	it("accepts any non-empty program key — the tab vocabulary is dynamic", () => {
		expect(studyMaterialsSearchSchema.parse({ tab: "frm" }).tab).toBe("frm")
		expect(studyMaterialsSearchSchema.parse({ tab: "energy-risk" }).tab).toBe(
			"energy-risk",
		)
		expect(studyMaterialsSearchSchema.parse({ tab: "all" }).tab).toBe("all")
	})

	it("pins an absent or empty tab to the full catalogue", () => {
		expect(studyMaterialsSearchSchema.parse({}).tab).toBe("all")
		expect(studyMaterialsSearchSchema.parse({ tab: "" }).tab).toBe("all")
	})

	it("degrades a non-string tab to the catalogue instead of throwing", () => {
		// The router JSON-parses search values, so an all-digit program key in
		// `?tab=` would arrive as a NUMBER and land here.
		expect(studyMaterialsSearchSchema.parse({ tab: 2024 }).tab).toBe("all")
	})

	it("keeps the view optional so a remembered choice can apply", () => {
		expect(studyMaterialsSearchSchema.parse({ view: "grid" }).view).toBe("grid")
		expect(studyMaterialsSearchSchema.parse({}).view).toBeUndefined()
		expect(studyMaterialsSearchSchema.parse({ view: "table" }).view).toBeUndefined()
	})
})

describe("studyMaterialsSearchSchema — the purchase return", () => {
	it("keeps ?purchased= as a string even when the router hands it over as a number", () => {
		expect(studyMaterialsSearchSchema.parse({ purchased: 1 }).purchased).toBe("1")
		expect(studyMaterialsSearchSchema.parse({ purchased: "1" }).purchased).toBe("1")
		expect(studyMaterialsSearchSchema.parse({}).purchased).toBeUndefined()
	})
})

describe("materialPurchaseSearchSchema", () => {
	it("keeps the provider's cancel flag through the router's JSON parse", () => {
		expect(materialPurchaseSearchSchema.parse({ checkout_cancelled: 1 }).checkout_cancelled).toBe("1")
		expect(materialPurchaseSearchSchema.parse({}).checkout_cancelled).toBeUndefined()
	})
})

describe("resolveStudyMaterialsView", () => {
	it("gives an explicit ?view= top precedence", () => {
		expect(resolveStudyMaterialsView("list", "grid")).toBe("list")
	})

	it("prefers the remembered choice over the default", () => {
		expect(resolveStudyMaterialsView(undefined, "list")).toBe("list")
	})

	it("defaults to grid — this page is a catalogue first", () => {
		expect(resolveStudyMaterialsView(undefined)).toBe("grid")
		expect(resolveStudyMaterialsView(undefined, null)).toBe("grid")
	})
})
