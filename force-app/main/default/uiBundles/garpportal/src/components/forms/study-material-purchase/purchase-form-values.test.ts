import { describe, expect, it } from "vitest"

import { materialQuote, materialShipTo } from "@/testing/factories/study-material-purchase"

import { toPurchaseFormValues, toShipTo } from "./purchase-form-values"

describe("toPurchaseFormValues", () => {
	it("seeds every field from the record, trimmed, with nulls as empty strings", () => {
		expect(
			toPurchaseFormValues(
				materialQuote({ shipTo: materialShipTo({ company: " GARP ", street2: null }) }),
			),
		).toEqual({
			company: "GARP",
			street: "111 Main Street",
			street2: "",
			city: "Jersey City",
			state: "NJ",
			postalCode: "07302",
			country: "United States",
			phone: "",
		})
	})

	it("starts blank when the record has no address", () => {
		const values = toPurchaseFormValues(materialQuote({ shipTo: null }))
		expect(Object.values(values).every((v) => v === "")).toBe(true)
	})

	it("blanks a country GARP will not post to, so the picker waits for a real choice", () => {
		expect(
			toPurchaseFormValues(
				materialQuote({ shipTo: materialShipTo({ country: "Atlantis" }) }),
			).country,
		).toBe("")
		expect(
			toPurchaseFormValues(
				materialQuote({ shipTo: materialShipTo({ country: "united states" }) }),
			).country,
		).toBe("united states")
	})

	it("keeps the record's country when there is no list to restrict by", () => {
		expect(
			toPurchaseFormValues(
				materialQuote({
					shipTo: materialShipTo({ country: "Atlantis" }),
					shippableCountries: [],
				}),
			).country,
		).toBe("Atlantis")
	})
})

describe("toShipTo", () => {
	it("trims and forwards every field, blank staying blank", () => {
		expect(
			toShipTo({
				company: "",
				street: " 1 Main ",
				street2: "",
				city: "Town",
				state: "",
				postalCode: " 123 ",
				country: "Canada",
				phone: "",
			}),
		).toEqual({
			company: "",
			street: "1 Main",
			street2: "",
			city: "Town",
			state: "",
			postalCode: "123",
			country: "Canada",
			phone: "",
		})
	})
})
