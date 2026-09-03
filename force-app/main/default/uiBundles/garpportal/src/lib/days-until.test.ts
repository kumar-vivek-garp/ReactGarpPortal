import { afterEach, describe, expect, it, vi } from "vitest"

import { daysUntil, parseIsoDate } from "./days-until"

afterEach(() => {
	vi.useRealTimers()
})

describe("parseIsoDate", () => {
	it("parses yyyy-MM-dd as a LOCAL calendar date", () => {
		// `new Date("2026-09-24")` would be UTC midnight, which is the previous
		// day west of Greenwich — the whole reason this parser exists.
		const date = parseIsoDate("2026-09-24")
		expect(date?.getFullYear()).toBe(2026)
		expect(date?.getMonth()).toBe(8)
		expect(date?.getDate()).toBe(24)
		expect(date?.getHours()).toBe(0)
	})

	it("takes only the date part of an ISO datetime", () => {
		const date = parseIsoDate("2026-09-24T22:30:00Z")
		expect(date?.getDate()).toBe(24)
		expect(date?.getHours()).toBe(0)
	})

	it("is null for nothing", () => {
		expect(parseIsoDate(null)).toBeNull()
		expect(parseIsoDate(undefined)).toBeNull()
		expect(parseIsoDate("")).toBeNull()
		expect(parseIsoDate("   ")).toBeNull()
	})

	it("is null for a value that is not a date", () => {
		expect(parseIsoDate("soon")).toBeNull()
		expect(parseIsoDate("2026-09")).toBeNull()
		// A zero month or day is Apex sending garbage, not a date.
		expect(parseIsoDate("2026-00-10")).toBeNull()
	})
})

describe("daysUntil", () => {
	it("counts whole calendar days regardless of the time of day", () => {
		// Late in the day on the 3rd, the 24th is still 21 days away.
		vi.setSystemTime(new Date(2026, 8, 3, 23, 45))
		expect(daysUntil("2026-09-24")).toBe(21)
	})

	it("is zero on the day itself", () => {
		vi.setSystemTime(new Date(2026, 8, 24, 9, 0))
		expect(daysUntil("2026-09-24")).toBe(0)
	})

	it("goes negative once the date has passed", () => {
		vi.setSystemTime(new Date(2026, 8, 3, 12, 0))
		expect(daysUntil("2026-09-01")).toBe(-2)
	})

	it("counts across a month boundary", () => {
		vi.setSystemTime(new Date(2026, 8, 30, 12, 0))
		expect(daysUntil("2026-10-02")).toBe(2)
	})

	it("is null when the date cannot be parsed", () => {
		expect(daysUntil(null)).toBeNull()
		expect(daysUntil("soon")).toBeNull()
	})
})
