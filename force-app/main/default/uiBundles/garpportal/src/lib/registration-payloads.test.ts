import { describe, expect, it } from "vitest"

import {
	addressInput,
	buildFeesRequest,
	emptyAddress,
	emptySelection,
	selectedMaterialCodes,
	selectionInput,
	toRegistrationAddress,
	toRegistrationPhoneCode,
	type FeesInput,
} from "./registration-payloads"

function feesInput(overrides: Partial<FeesInput> = {}): FeesInput {
	return {
		type: "frm",
		selection: emptySelection(),
		materials: [],
		paymentType: "",
		billingAddress: { ...emptyAddress(), country: "United States" },
		shippingAddress: emptyAddress(),
		billingAndShippingSame: true,
		autoRenew: false,
		membershipSelected: false,
		riskNetSelected: false,
		mobilePhoneCode: "",
		...overrides,
	}
}

describe("emptyAddress / addressInput", () => {
	it("starts every field as an empty string, never undefined", () => {
		// Apex deserialises typed inner classes — a missing key and an empty
		// string are different things on the wire.
		expect(Object.values(emptyAddress())).toEqual(Array(9).fill(""))
	})

	it("copies the address rather than aliasing the form state", () => {
		const address = { ...emptyAddress(), city: "Jersey City" }
		const input = addressInput(address)
		expect(input).toEqual(address)
		expect(input).not.toBe(address)
	})
})

describe("selectionInput", () => {
	it("resolves the empty selection to nulls across the board", () => {
		expect(selectionInput(emptySelection())).toEqual({
			partSelected: null,
			part1: null,
			part2: null,
		})
	})

	it("nulls a part with no sitting even when a site is set", () => {
		// Apex casts these straight to Ids: `{rateId: ""}` is `500 "Invalid id: "`.
		const selection = emptySelection()
		selection.part1 = { rateId: "", siteId: "a1e" }
		expect(selectionInput(selection).part1).toBeNull()
	})

	it("sends null, not an empty string, for an unchosen site", () => {
		const selection = emptySelection()
		selection.part1 = { rateId: "a91", siteId: "" }
		expect(selectionInput(selection).part1).toEqual({
			rateId: "a91",
			siteId: null,
		})
	})

	it("carries a complete choice for either part", () => {
		const selection = emptySelection()
		selection.partSelected = "FRM Exam Part II"
		selection.part2 = { rateId: "a92", siteId: "a1f" }
		expect(selectionInput(selection)).toEqual({
			partSelected: "FRM Exam Part II",
			part1: null,
			part2: { rateId: "a92", siteId: "a1f" },
		})
	})
})

describe("selectedMaterialCodes", () => {
	it("keeps only materials explicitly ticked", () => {
		// Included/comp items are added server-side; `selected` left undefined
		// must not count as chosen.
		const codes = selectedMaterialCodes([
			{ productCode: "FRM1H", selected: true },
			{ productCode: "FRM2H", selected: false },
			{ productCode: "FRMBP" },
		])
		expect(codes).toEqual(["FRM1H"])
	})

	it("is empty for no materials", () => {
		expect(selectedMaterialCodes([])).toEqual([])
	})
})

describe("buildFeesRequest", () => {
	it("nulls the optional identifiers it was not given", () => {
		const request = buildFeesRequest(feesInput())
		expect(request.courseCode).toBeNull()
		expect(request.regCode).toBeNull()
		expect(request.contactId).toBeNull()
		expect(request.paymentType).toBeNull()
		expect(request.mobilePhoneCodeDigits).toBeNull()
	})

	it("passes the identifiers it was given", () => {
		const request = buildFeesRequest(
			feesInput({
				courseCode: "FRR",
				regCode: "TEAM24",
				contactId: "003xx",
				paymentType: "Stripe",
			}),
		)
		expect(request).toMatchObject({
			type: "frm",
			courseCode: "FRR",
			regCode: "TEAM24",
			contactId: "003xx",
			paymentType: "Stripe",
		})
	})

	it("mirrors billing into shipping when they are the same", () => {
		const input = feesInput()
		const request = buildFeesRequest(input)
		expect(request.shippingAddress).toEqual(input.billingAddress)
		// A copy, so later form edits cannot mutate a request already staged.
		expect(request.shippingAddress).not.toBe(input.billingAddress)
	})

	it("sends the distinct shipping address when they differ", () => {
		const request = buildFeesRequest(
			feesInput({
				billingAndShippingSame: false,
				shippingAddress: { ...emptyAddress(), country: "Canada" },
			}),
		)
		expect(request.shippingAddress.country).toBe("Canada")
		expect(request.billingAndShippingSame).toBe(false)
	})

	it("carries the boolean upsells and auto-renew through", () => {
		const request = buildFeesRequest(
			feesInput({
				membershipSelected: true,
				riskNetSelected: true,
				autoRenew: true,
			}),
		)
		expect(request).toMatchObject({
			membershipSelected: true,
			riskNetSelected: true,
			autoRenew: true,
		})
	})

	it("reduces the composite phone code to its dial digits", () => {
		expect(
			buildFeesRequest(feesInput({ mobilePhoneCode: "China (+86)" }))
				.mobilePhoneCodeDigits,
		).toBe("86")
	})

	it("sends selection and materials through the shared builders", () => {
		const selection = emptySelection()
		selection.part1 = { rateId: "a91", siteId: "" }
		const request = buildFeesRequest(
			feesInput({
				selection,
				materials: [{ productCode: "FRM1H", selected: true }],
			}),
		)
		expect(request.selection.part1).toEqual({ rateId: "a91", siteId: null })
		expect(request.materials).toEqual(["FRM1H"])
	})
})

describe("toRegistrationAddress", () => {
	it("renames the portal fields to the registration ones", () => {
		expect(
			toRegistrationAddress({
				company: "GARP",
				address1: "111 Town Square",
				address2: "Floor 14",
				address3: "Desk 3",
				city: "Jersey City",
				state: "NJ",
				postalCode: "07310",
				country: "United States",
				phone: "5551234567",
			}),
		).toEqual({
			company: "GARP",
			street1: "111 Town Square",
			street2: "Floor 14",
			street3: "Desk 3",
			city: "Jersey City",
			province: "NJ",
			postalCode: "07310",
			country: "United States",
			phone: "5551234567",
		})
	})

	it("returns the empty address for a guest with no record", () => {
		expect(toRegistrationAddress(null)).toEqual(emptyAddress())
		expect(toRegistrationAddress(undefined)).toEqual(emptyAddress())
	})

	it("blanks the fields a partial record is missing", () => {
		const address = toRegistrationAddress({ city: "Jersey City" })
		expect(address.city).toBe("Jersey City")
		expect(address.street1).toBe("")
		expect(address.country).toBe("")

		const other = toRegistrationAddress({ address1: "111 Town Square" })
		expect(other.street1).toBe("111 Town Square")
		expect(other.city).toBe("")
	})
})

describe("toRegistrationPhoneCode", () => {
	const countries = [
		// name and countryCode differ on purpose: the output must carry
		// `countryCode` (what Apex echoes onto the address), while the tie-break
		// matches on `name` (what the member's record stores).
		{ name: "United States of America", countryCode: "United States", phoneCode: "1" },
		{ name: "Canada", countryCode: "Canada", phoneCode: "1" },
		{ name: "China", countryCode: "China", phoneCode: "86" },
		{ name: "Nowhere", countryCode: "Nowhere", phoneCode: null },
	]

	it("builds the composite string from the countryCode, not the name", () => {
		expect(
			toRegistrationPhoneCode("+1", "United States of America", countries),
		).toBe("United States (+1)")
	})

	it("breaks a shared dial code using the member's own country", () => {
		expect(toRegistrationPhoneCode("+1", "Canada", countries)).toBe("Canada (+1)")
	})

	it("falls back to the first match when the member's country does not dial it", () => {
		expect(toRegistrationPhoneCode("+1", "China", countries)).toBe(
			"United States (+1)",
		)
	})

	it("keeps only digits from however the code was stored", () => {
		expect(toRegistrationPhoneCode(" (+86) ", "China", countries)).toBe(
			"China (+86)",
		)
	})

	it("is empty with no digits, no match, or no code", () => {
		expect(toRegistrationPhoneCode("", "China", countries)).toBe("")
		expect(toRegistrationPhoneCode(null, "China", countries)).toBe("")
		expect(toRegistrationPhoneCode("+999", "Nowhere", countries)).toBe("")
	})
})
