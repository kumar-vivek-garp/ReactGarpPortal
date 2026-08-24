import { describe, expect, it } from "vitest"

import { buildActivitySearchParams } from "@/api/cpd/activities"

describe("buildActivitySearchParams", () => {
	it("sends only the facets that were set", () => {
		const params = buildActivitySearchParams({
			activityTypes: ["Webcast", "Conference"],
			pageCurrent: 2,
		})
		expect(params.get("activityTypes")).toBe("Webcast;Conference")
		expect(params.get("pageCurrent")).toBe("2")
		expect(params.has("providers")).toBe(false)
		expect(params.has("sortOrder")).toBe(false)
	})

	it("drops blank facet values rather than sending empty segments", () => {
		const params = buildActivitySearchParams({
			areasOfStudy: ["  ", "Credit Risk", ""],
		})
		expect(params.get("areasOfStudy")).toBe("Credit Risk")
	})

	/**
	 * The trap. Apex replaces the whole WHERE clause with `Id = :singleId` and
	 * skips ORDER BY, LIMIT and OFFSET — the facets are IGNORED, not combined.
	 * Sending them would imply an intersection the server never performs, and a
	 * stale `pageCurrent` would look like it had been honoured.
	 */
	it("sends the id alone, dropping every facet, sort and page", () => {
		const params = buildActivitySearchParams({
			activityId: "a1B000000000001",
			activityTypes: ["Webcast"],
			areasOfStudy: ["Credit Risk"],
			providers: ["GARP"],
			sortOrder: "Newest",
			pageSize: 20,
			pageCurrent: 4,
		})
		expect([...params.keys()]).toEqual(["activityId"])
		expect(params.get("activityId")).toBe("a1B000000000001")
	})

	it("ignores a whitespace-only id and falls back to the facets", () => {
		const params = buildActivitySearchParams({
			activityId: "   ",
			activityTypes: ["Webcast"],
		})
		expect(params.has("activityId")).toBe(false)
		expect(params.get("activityTypes")).toBe("Webcast")
	})

	it("sends nothing at all for an empty filter set", () => {
		expect([...buildActivitySearchParams({}).keys()]).toEqual([])
	})
})
