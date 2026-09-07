import { describe, expect, it } from "vitest"

import { toCountryOptions, toPhoneCodeOptions } from "@/api/personal-info/countries"
import {
	accountOptionsView,
	portalCountryOption,
} from "@/testing/factories/account-options"

describe("toCountryOptions", () => {
	it("keeps server order, trims, and drops blanks and duplicates", () => {
		const options = accountOptionsView({
			countries: [
				portalCountryOption({ name: " United States ", phoneCode: " 1 " }),
				portalCountryOption({ name: "Curacao", phoneCode: null }),
				portalCountryOption({ name: "United States" }),
				portalCountryOption({ name: " " }),
			],
		})

		expect(toCountryOptions(options)).toEqual([
			{ label: "United States", value: "United States", phoneCode: "1" },
			{ label: "Curacao", value: "Curacao", phoneCode: null },
		])
	})
})

describe("toPhoneCodeOptions", () => {
	it("offers the org's formatted strings verbatim, de-duplicated", () => {
		const options = accountOptionsView({
			mobilePhoneLocations: [
				"United States (+1)",
				" United Kingdom (+44) ",
				"United States (+1)",
				"",
			],
		})

		expect(toPhoneCodeOptions(options)).toEqual([
			{ label: "United States (+1)", value: "United States (+1)" },
			{ label: "United Kingdom (+44)", value: "United Kingdom (+44)" },
		])
	})
})
