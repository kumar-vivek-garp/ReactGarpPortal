import { describe, expect, it } from "vitest"

import { cvYearOptions } from "@/config/work-experience"

// The year is a parameter by design, so no clock mocking is needed here.
describe("cvYearOptions", () => {
	it("lists newest first, back to 1970 inclusive", () => {
		expect(cvYearOptions(1972)).toEqual(["1972", "1971", "1970"])
	})

	it("spans the full range for a modern year", () => {
		const years = cvYearOptions(2026)

		expect(years).toHaveLength(2026 - 1970 + 1)
		expect(years[0]).toBe("2026")
		expect(years[years.length - 1]).toBe("1970")
	})

	it("returns just 1970 at the floor", () => {
		expect(cvYearOptions(1970)).toEqual(["1970"])
	})

	it("returns nothing for a year before the floor", () => {
		expect(cvYearOptions(1969)).toEqual([])
	})
})
