import { describe, expect, it } from "vitest"

import {
	isEnglishName,
	looseSearchString,
	registrationSearchSchema,
} from "./registration"

describe("looseSearchString", () => {
	// The router JSON-parses every search value, so `?oid=8013` arrives as the
	// NUMBER 8013. A bare z.string() rejects it and `.catch(undefined)` then
	// drops it silently — which is how a payment return once rendered as a blank
	// registration form for an order that was already charged.
	it("keeps a string as-is", () => {
		expect(looseSearchString().parse("TEAM24")).toBe("TEAM24")
		expect(looseSearchString().parse("W-1234")).toBe("W-1234")
	})

	it("coerces a number back to its string form", () => {
		expect(looseSearchString().parse(8013)).toBe("8013")
		expect(looseSearchString().parse(0)).toBe("0")
		expect(looseSearchString().parse(1.5)).toBe("1.5")
	})

	it("leaves absence as undefined", () => {
		expect(looseSearchString().parse(undefined)).toBeUndefined()
	})

	it("degrades any other type to undefined instead of throwing", () => {
		for (const junk of [true, null, {}, ["8013"]]) {
			expect(looseSearchString().parse(junk)).toBeUndefined()
		}
	})
})

describe("isEnglishName", () => {
	it("accepts plain and compound English names", () => {
		for (const name of [
			"Ada",
			"ADA",
			"Ada Lovelace",
			"Mary-Jane",
			"O'Brien",
			"van der Berg-O'Neil",
		]) {
			expect(isEnglishName(name)).toBe(true)
		}
	})

	it("rejects doubled hyphens, whitespace, and apostrophes", () => {
		expect(isEnglishName("Ada--Lovelace")).toBe(false)
		expect(isEnglishName("Ada  Lovelace")).toBe(false)
		expect(isEnglishName("O''Brien")).toBe(false)
	})

	it("rejects any character outside letters, hyphen, space, apostrophe", () => {
		for (const name of [
			"Ada2",
			"Renée", // accented letters are outside a-z — legacy parity
			"李明",
			"Ada.",
			"Ada_Lovelace",
			"Ada,Lovelace",
		]) {
			expect(isEnglishName(name)).toBe(false)
		}
	})

	it("is a reject-pattern: an empty string has nothing to reject", () => {
		// Emptiness is the min-length rule's job, not this one's.
		expect(isEnglishName("")).toBe(true)
	})

	it("allows any single whitespace character — ported verbatim from legacy", () => {
		// The legacy directive's `\s` class covers tab/newline, so one of either
		// passes; only DOUBLED whitespace is refused. Tested as actual behavior.
		expect(isEnglishName("Ada\tLovelace")).toBe(true)
		expect(isEnglishName("Ada\t\tLovelace")).toBe(false)
	})
})

describe("registrationSearchSchema", () => {
	it("keeps every param as a string, even when all digits", () => {
		const parsed = registrationSearchSchema.parse({
			regCode: 2024,
			teamCode: 88,
			stripe_return: 1,
			oid: 8013,
			on: 12345,
		})
		expect(parsed).toEqual({
			regCode: "2024",
			teamCode: "88",
			stripe_return: "1",
			oid: "8013",
			on: "12345",
		})
	})

	it("passes ordinary string params through", () => {
		expect(
			registrationSearchSchema.parse({ regCode: "TEAM24", on: "W1" }),
		).toMatchObject({ regCode: "TEAM24", on: "W1" })
	})

	it("leaves absent params absent", () => {
		expect(registrationSearchSchema.parse({})).toEqual({
			regCode: undefined,
			teamCode: undefined,
			stripe_return: undefined,
			oid: undefined,
			on: undefined,
		})
	})

	it("drops garbage values instead of throwing", () => {
		// A malformed marketing link must not take the whole route down.
		const parsed = registrationSearchSchema.parse({
			regCode: {},
			oid: null,
			stripe_return: [1],
		})
		expect(parsed.regCode).toBeUndefined()
		expect(parsed.oid).toBeUndefined()
		expect(parsed.stripe_return).toBeUndefined()
	})

	it("strips unknown params", () => {
		const parsed = registrationSearchSchema.parse({ utm_source: "email" })
		expect("utm_source" in parsed).toBe(false)
	})
})
