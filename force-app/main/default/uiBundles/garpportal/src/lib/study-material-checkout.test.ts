import { describe, expect, it } from "vitest"

import {
	buildMaterialCheckoutUrls,
	isShippingAddressComplete,
	materialQuoteLines,
	resolvePayableId,
	shippingCountryDiffers,
} from "./study-material-checkout"

describe("buildMaterialCheckoutUrls", () => {
	const location = {
		origin: "https://portal.example",
		pathname: "/lwr/app/study-materials/purchase/SCRH",
	}

	it("sends success to the listing under the org base path, and cancel back here", () => {
		expect(buildMaterialCheckoutUrls(location, "/lwr/app")).toEqual({
			successUrl: "https://portal.example/lwr/app/study-materials?purchased=1",
			cancelUrl:
				"https://portal.example/lwr/app/study-materials/purchase/SCRH?checkout_cancelled=1",
		})
	})

	it("works with no base path at all — local Vite and the e2e build", () => {
		expect(
			buildMaterialCheckoutUrls(
				{ origin: "http://localhost:3000", pathname: "/study-materials/purchase/SCRH" },
				"",
			),
		).toEqual({
			successUrl: "http://localhost:3000/study-materials?purchased=1",
			cancelUrl: "http://localhost:3000/study-materials/purchase/SCRH?checkout_cancelled=1",
		})
	})

	it("normalises a trailing slash on the base path and never re-adds it to cancel", () => {
		const urls = buildMaterialCheckoutUrls(location, "/lwr/app///")
		expect(urls.successUrl).toBe("https://portal.example/lwr/app/study-materials?purchased=1")
		expect(urls.cancelUrl).not.toContain("/lwr/app/lwr/app")
	})

	it("carries exactly one flag on each leg — no oid, no on", () => {
		const urls = buildMaterialCheckoutUrls(location, "")
		expect(new URL(urls.successUrl).searchParams.toString()).toBe("purchased=1")
		expect(new URL(urls.cancelUrl).searchParams.toString()).toBe("checkout_cancelled=1")
	})
})

describe("resolvePayableId", () => {
	it("takes the order under the immediate flow and the staged row under the deferred one", () => {
		expect(resolvePayableId({ orderId: "006", stagedId: "a0H" })).toBe("006")
		expect(resolvePayableId({ orderId: null, stagedId: "a0H" })).toBe("a0H")
		expect(resolvePayableId({ orderId: "", stagedId: null })).toBeNull()
	})
})

describe("isShippingAddressComplete", () => {
	it("needs street, city and country — and only those", () => {
		expect(
			isShippingAddressComplete({ street: "1 Main", city: "Town", country: "Canada" }),
		).toBe(true)
		expect(isShippingAddressComplete({ street: "  ", city: "Town", country: "Canada" })).toBe(
			false,
		)
		expect(isShippingAddressComplete({ street: "1 Main", city: "", country: "Canada" })).toBe(
			false,
		)
		expect(isShippingAddressComplete({ street: "1 Main", city: "Town", country: null })).toBe(
			false,
		)
		expect(isShippingAddressComplete(null)).toBe(false)
	})
})

describe("materialQuoteLines", () => {
	it("omits shipping for something that is not posted", () => {
		expect(
			materialQuoteLines({ price: 75, shipping: null, total: 75, isShippable: false }).map(
				(l) => l.key,
			),
		).toEqual(["item", "total"])
	})

	it("carries an unknown shipping charge as null, and marks the total", () => {
		const lines = materialQuoteLines({ price: 100, shipping: null, total: 100, isShippable: true })
		expect(lines).toEqual([
			{ key: "item", label: "Item", amount: 100 },
			{ key: "shipping", label: "Shipping", amount: null },
			{ key: "total", label: "Total", amount: 100, emphasis: true },
		])
	})

	it("keeps a zero shipping charge as a real figure", () => {
		expect(
			materialQuoteLines({ price: 100, shipping: 0, total: 100, isShippable: true })[1]?.amount,
		).toBe(0)
	})
})

describe("shippingCountryDiffers", () => {
	it("is true only once the member has moved off the country the quote priced", () => {
		expect(shippingCountryDiffers("United States", "Canada")).toBe(true)
		expect(shippingCountryDiffers("United States", "united states")).toBe(false)
		expect(shippingCountryDiffers(null, "Canada")).toBe(false)
		expect(shippingCountryDiffers("United States", "")).toBe(false)
	})
})
