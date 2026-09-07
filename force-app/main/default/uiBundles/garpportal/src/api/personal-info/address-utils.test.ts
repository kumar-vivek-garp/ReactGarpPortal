import { describe, expect, it } from "vitest"

import {
	copyAddress,
	emptyAddress,
	joinStreet,
	splitStreet,
	str,
	toAddressInput,
} from "@/api/personal-info/address-utils"

describe("splitStreet", () => {
	it("splits a multi-line street into three trimmed lines", () => {
		expect(splitStreet(" 1 Main St \r\nSuite 4\nFloor 2\nIgnored")).toEqual([
			"1 Main St",
			"Suite 4",
			"Floor 2",
		])
	})

	it("pads missing lines with empty strings", () => {
		expect(splitStreet("1 Main St")).toEqual(["1 Main St", "", ""])
		expect(splitStreet(null)).toEqual(["", "", ""])
		expect(splitStreet(undefined)).toEqual(["", "", ""])
	})
})

describe("joinStreet", () => {
	it("joins non-blank lines with newlines", () => {
		expect(joinStreet(" 1 Main St ", "", "Floor 2")).toBe("1 Main St\nFloor 2")
	})

	it("returns an empty string when every line is blank", () => {
		expect(joinStreet(" ", "", "  ")).toBe("")
	})

	it("round-trips with splitStreet", () => {
		const [a, b, c] = splitStreet("1 Main St\nSuite 4\nFloor 2")
		expect(joinStreet(a, b, c)).toBe("1 Main St\nSuite 4\nFloor 2")
	})
})

describe("toAddressInput", () => {
	it("trims every field, sends blanks as null, and never a joined street", () => {
		expect(
			toAddressInput({
				...emptyAddress(),
				company: " GARP ",
				address1: "1 Main St",
				address2: "  ",
				city: "Hoboken",
				country: "United States",
			}),
		).toEqual({
			company: "GARP",
			street1: "1 Main St",
			street2: null,
			street3: null,
			city: "Hoboken",
			state: null,
			postalCode: null,
			country: "United States",
			phone: null,
		})
	})
})

describe("copyAddress / str", () => {
	it("copies by value, not by reference", () => {
		const source = { ...emptyAddress(), city: "Hoboken" }
		const copy = copyAddress(source)
		expect(copy).toEqual(source)
		expect(copy).not.toBe(source)
	})

	it("str trims and maps nullish to empty", () => {
		expect(str(" x ")).toBe("x")
		expect(str(null)).toBe("")
		expect(str(undefined)).toBe("")
	})
})
