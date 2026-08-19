import { afterEach, describe, expect, it, vi } from "vitest"

import type { CatalogueItem, StudyMaterial } from "@/api/study-materials/types"
import { resolveStudyMaterialsView } from "@/config/study-materials"
import {
	accessExpiryLine,
	buildCatalogueItemPresentation,
	buildOwnedItemPresentation,
	studyCodeLabel,
} from "./study-materials-presentation"

function owned(overrides: Partial<StudyMaterial> = {}): StudyMaterial {
	return {
		id: "scr-0",
		programKey: "scr",
		name: "2026 SCR Book",
		type: "eBook",
		accessUrl: "https://example.com/read",
		status: "Taken",
		expirationDate: "2027-08-11",
		isAvailable: true,
		unavailableReason: null,
		lastAccessed: null,
		invoiceNumber: null,
		...overrides,
	}
}

function catalogue(overrides: Partial<CatalogueItem> = {}): CatalogueItem {
	return {
		id: "frm-1",
		programKey: "frm",
		title: "2026 FRM Study Guide",
		paragraphs: ["Primary topics and required readings."],
		imageUrl: null,
		downloadUrl: "https://example.com/guide.pdf",
		purchaseUrl: null,
		costNote: null,
		materialType: "Guide",
		isDownload: true,
		sortOrder: 1,
		...overrides,
	}
}

afterEach(() => {
	vi.useRealTimers()
})

describe("studyCodeLabel", () => {
	it("uppercases the program key", () => {
		expect(studyCodeLabel("scr")).toBe("SCR")
		expect(studyCodeLabel(" frm ")).toBe("FRM")
	})
})

describe("accessExpiryLine", () => {
	it("counts down inside the 30-day window", () => {
		vi.useFakeTimers()
		vi.setSystemTime(new Date(2026, 7, 18))
		expect(accessExpiryLine("2026-08-27")).toEqual({
			icon: "expiringSoon",
			text: "Access ends in 9 days",
		})
	})

	it("uses today / tomorrow at the boundary", () => {
		vi.useFakeTimers()
		vi.setSystemTime(new Date(2026, 7, 18))
		expect(accessExpiryLine("2026-08-18")?.text).toBe("Access ends today")
		expect(accessExpiryLine("2026-08-19")?.text).toBe("Access ends tomorrow")
	})

	it("reports an expiry that has already passed", () => {
		vi.useFakeTimers()
		vi.setSystemTime(new Date(2026, 7, 18))
		const line = accessExpiryLine("2026-01-05")
		expect(line?.icon).toBe("expiringSoon")
		expect(line?.text).toContain("Access ended")
	})

	it("uses a plain date beyond the window", () => {
		vi.useFakeTimers()
		vi.setSystemTime(new Date(2026, 7, 18))
		const line = accessExpiryLine("2027-08-11")
		expect(line?.icon).toBe("accessUntil")
		expect(line?.text).toContain("Access until")
	})

	it("returns null with no date", () => {
		expect(accessExpiryLine(null)).toBeNull()
		expect(accessExpiryLine("")).toBeNull()
	})
})

describe("buildOwnedItemPresentation", () => {
	it("carries program identity, status and an open action", () => {
		vi.useFakeTimers()
		vi.setSystemTime(new Date(2026, 7, 18))
		const result = buildOwnedItemPresentation(owned())
		expect(result.variant).toBe("owned")
		expect(result.codeLabel).toBe("SCR")
		expect(result.typeLabel).toBe("eBook")
		// Apex `keyStatus` wins the label when present.
		expect(result.statusLabel).toBe("Taken")
		expect(result.statusTone).toBe("info")
		expect(result.primaryAction).toEqual({
			label: "Open material",
			url: "https://example.com/read",
			isExternal: true,
			newWindow: true,
		})
		expect(result.secondaryAction).toBeNull()
	})

	it("falls back to Available when Apex sends no status", () => {
		const result = buildOwnedItemPresentation(owned({ status: null }))
		expect(result.statusLabel).toBe("Available")
		expect(result.statusTone).toBe("success")
	})

	it("warns and offers help when the material is unavailable", () => {
		const result = buildOwnedItemPresentation(
			owned({ isAvailable: false, unavailableReason: "Coming soon" }),
		)
		expect(result.statusLabel).toBe("Unavailable")
		expect(result.statusTone).toBe("warning")
		expect(result.metaLines).toContainEqual({
			icon: "unavailable",
			text: "Coming soon",
		})
		expect(result.primaryAction).toBeNull()
		expect(result.secondaryAction?.label).toBe("Ask about access")
	})

	it("offers help rather than a dead link when there is no access url", () => {
		const result = buildOwnedItemPresentation(owned({ accessUrl: "   " }))
		expect(result.primaryAction).toBeNull()
		expect(result.secondaryAction?.url).toContain("mailto:")
	})

	it("tolerates a missing name", () => {
		expect(buildOwnedItemPresentation(owned({ name: null })).title).toBe(
			"Study material",
		)
	})
})

describe("buildCatalogueItemPresentation", () => {
	it("prefers a download over a purchase", () => {
		const result = buildCatalogueItemPresentation(
			catalogue({ purchaseUrl: "https://example.com/buy" }),
		)
		expect(result.primaryAction?.label).toBe("Download now")
	})

	it("offers purchase when the item is not a download", () => {
		const result = buildCatalogueItemPresentation(
			catalogue({
				isDownload: false,
				downloadUrl: null,
				purchaseUrl: "https://example.com/buy",
				costNote: "$300",
			}),
		)
		expect(result.primaryAction?.label).toBe("Purchase")
		expect(result.metaLines).toContainEqual({ icon: "price", text: "$300" })
	})

	it("has no action when neither url is present", () => {
		const result = buildCatalogueItemPresentation(
			catalogue({ isDownload: false, downloadUrl: null, purchaseUrl: null }),
		)
		expect(result.primaryAction).toBeNull()
	})

	it("never carries a status — catalogue entries are not owned", () => {
		const result = buildCatalogueItemPresentation(catalogue())
		expect(result.statusLabel).toBeNull()
		expect(result.statusTone).toBeNull()
	})

	it("drops blank paragraphs", () => {
		const result = buildCatalogueItemPresentation(
			catalogue({ paragraphs: ["Real copy", "   ", ""] }),
		)
		expect(result.paragraphs).toEqual(["Real copy"])
	})
})

describe("resolveStudyMaterialsView", () => {
	it("honours an explicit view above everything else", () => {
		expect(resolveStudyMaterialsView("list")).toBe("list")
		expect(resolveStudyMaterialsView("list", "grid")).toBe("list")
	})

	it("prefers a remembered choice over the grid default", () => {
		expect(resolveStudyMaterialsView(undefined, "list")).toBe("list")
	})

	it("defaults to grid — this page is primarily a catalogue", () => {
		expect(resolveStudyMaterialsView(undefined)).toBe("grid")
		expect(resolveStudyMaterialsView(undefined, null)).toBe("grid")
	})
})
