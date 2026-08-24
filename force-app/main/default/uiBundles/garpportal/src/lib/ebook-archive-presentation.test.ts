import { describe, expect, it } from "vitest"

import type { MyEBooksView } from "@/api/study-materials/types"
import {
	archiveTitleCount,
	groupEBooksByYear,
} from "./ebook-archive-presentation"

function view(eBooks: MyEBooksView["eBooks"]): MyEBooksView {
	return { statusMessage: "eBooks Returned", statusCode: 200, eBooks }
}

describe("groupEBooksByYear", () => {
	/**
	 * The payload is a map keyed by edition year, so it carries no order of its
	 * own — JS object key order is insertion-based and Apex builds the map in
	 * whatever sequence the keys came back. Sorting is what makes "newest first"
	 * true rather than accidental.
	 */
	it("orders years newest first regardless of key order", () => {
		const groups = groupEBooksByYear(
			view({
				"2023": [{ title: "FRM", eBookItems: [{ vendorId: 1 }] }],
				"2025": [{ title: "FRM", eBookItems: [{ vendorId: 2 }] }],
				"2024": [{ title: "FRM", eBookItems: [{ vendorId: 3 }] }],
			}),
		)
		expect(groups.map((group) => group.year)).toEqual([2025, 2024, 2023])
	})

	/** One purchase can resolve to several openable items (Part I and Part II). */
	it("renders one row per vendor item, not per key", () => {
		const groups = groupEBooksByYear(
			view({
				"2025": [
					{
						title: "FRM",
						eBookItems: [
							{ title: "Part I", vendorId: 11 },
							{ title: "Part II", vendorId: 12 },
						],
					},
				],
			}),
		)
		expect(groups[0].titles.map((t) => t.label)).toEqual([
			"FRM — Part I",
			"FRM — Part II",
		])
		expect(groups[0].titles.map((t) => t.vendorId)).toEqual(["11", "12"])
	})

	/**
	 * The two titles overlap unpredictably. Joining blindly gives
	 * "FRM — FRM Part I"; the more specific of the two is what the member wants.
	 */
	it("prefers the item title when it already carries the key title", () => {
		const groups = groupEBooksByYear(
			view({
				"2025": [
					{ title: "FRM", eBookItems: [{ title: "FRM Part I", vendorId: 1 }] },
				],
			}),
		)
		expect(groups[0].titles[0].label).toBe("FRM Part I")
	})

	/**
	 * Owned but unopenable — shown as a row rather than dropped, so the member
	 * can see what they paid for instead of it silently vanishing.
	 */
	it("keeps a key with no vendor items, marked unopenable", () => {
		const groups = groupEBooksByYear(
			view({ "2025": [{ title: "FRM", eBookItems: [] }] }),
		)
		expect(groups[0].titles).toHaveLength(1)
		expect(groups[0].titles[0].vendorId).toBeNull()
	})

	it("drops a year with nothing in it, and a non-numeric key", () => {
		const groups = groupEBooksByYear(
			view({
				"2025": [],
				"not-a-year": [{ title: "FRM", eBookItems: [{ vendorId: 1 }] }],
			}),
		)
		expect(groups).toEqual([])
	})

	it("survives an absent or empty payload", () => {
		expect(groupEBooksByYear(null)).toEqual([])
		expect(groupEBooksByYear(undefined)).toEqual([])
		expect(groupEBooksByYear(view({}))).toEqual([])
	})
})

describe("archiveTitleCount", () => {
	it("counts titles across every year", () => {
		const groups = groupEBooksByYear(
			view({
				"2025": [
					{ title: "FRM", eBookItems: [{ vendorId: 1 }, { vendorId: 2 }] },
				],
				"2024": [{ title: "SCR", eBookItems: [{ vendorId: 3 }] }],
			}),
		)
		expect(archiveTitleCount(groups)).toBe(3)
	})
})
