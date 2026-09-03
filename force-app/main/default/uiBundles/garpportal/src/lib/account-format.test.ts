import { describe, expect, it } from "vitest"

import type { PortalAddress } from "@/api/account/types"
import {
	addressLines,
	formatDateTime,
	formatLongDate,
	formatMoney,
} from "./account-format"

// String expectations assume the suite's en-US runtime locale, which
// `order-presentation.test.ts` already relies on ("march" matches the label).

describe("formatLongDate", () => {
	it("formats an ISO date as a long LOCAL date", () => {
		// Parsed as local on purpose: `new Date("2026-09-24")` is UTC and can
		// land on the previous day west of Greenwich.
		expect(formatLongDate("2026-03-01")).toBe("March 1, 2026")
	})

	it("is null for nothing", () => {
		expect(formatLongDate(null)).toBeNull()
		expect(formatLongDate(undefined)).toBeNull()
		expect(formatLongDate("")).toBeNull()
	})

	it("is null for a malformed date", () => {
		expect(formatLongDate("2026-03")).toBeNull()
		expect(formatLongDate("soon")).toBeNull()
	})
})

describe("formatDateTime", () => {
	it("formats an ISO datetime with date and minutes", () => {
		const label = formatDateTime("2026-03-01T14:30:00")
		expect(label).toContain("March 1, 2026")
		expect(label).toContain("2:30")
		expect(label).toContain("PM")
	})

	it("is null for nothing or garbage", () => {
		expect(formatDateTime(null)).toBeNull()
		expect(formatDateTime(undefined)).toBeNull()
		expect(formatDateTime("not a datetime")).toBeNull()
	})
})

describe("formatMoney", () => {
	it("formats a recognised currency with its symbol", () => {
		expect(formatMoney(1234.5, "USD")).toBe("$1,234.50")
		expect(formatMoney(0, "USD")).toBe("$0.00")
	})

	it("is null with no amount — zero is an amount", () => {
		expect(formatMoney(null, "USD")).toBeNull()
		expect(formatMoney(undefined, "USD")).toBeNull()
	})

	it("falls back to a plain number without a currency code", () => {
		expect(formatMoney(1234.5, null)).toBe("1,234.50")
	})

	it("falls back rather than throwing on a malformed currency code", () => {
		// Four letters is not a well-formed ISO code — Intl throws, we recover.
		expect(formatMoney(1234.5, "garp")).toBe("1,234.50")
	})
})

describe("addressLines", () => {
	function address(overrides: Partial<PortalAddress> = {}): PortalAddress {
		return {
			street: "111 Town Square Pl",
			city: "Jersey City",
			state: "NJ",
			postalCode: "07310",
			country: "United States",
			isEmpty: false,
			...overrides,
		}
	}

	it("renders street, city line, and country", () => {
		expect(addressLines(address())).toEqual([
			"111 Town Square Pl",
			"Jersey City, NJ 07310",
			"United States",
		])
	})

	it("drops the comma with no state and the blank parts entirely", () => {
		expect(addressLines(address({ state: null }))[1]).toBe("Jersey City 07310")
		expect(addressLines(address({ city: null, state: null }))[1]).toBe("07310")
		expect(
			addressLines(address({ city: null, state: null, postalCode: null })),
		).toEqual(["111 Town Square Pl", "United States"])
	})

	it("skips whitespace-only and null values", () => {
		expect(addressLines(address({ street: "   " }))).toEqual([
			"Jersey City, NJ 07310",
			"United States",
		])
		expect(addressLines(address({ street: null, country: null }))).toEqual([
			"Jersey City, NJ 07310",
		])
	})

	it("is empty for a missing or explicitly empty address", () => {
		expect(addressLines(null)).toEqual([])
		expect(addressLines(undefined)).toEqual([])
		expect(addressLines(address({ isEmpty: true }))).toEqual([])
	})
})
