import { afterEach, describe, expect, it } from "vitest"

import {
	invoicePdfUrl,
	setOrdersCheckoutSessionCookie,
	stripeOrdersCheckoutUrl,
} from "@/config/order-history"

describe("invoicePdfUrl", () => {
	it("builds the Visualforce PDF URL from a trimmed Opportunity Id", () => {
		expect(invoicePdfUrl(" 006gP00000ABCDE ")).toBe(
			"/apex/InvoicePrintAsPDF?id=006gP00000ABCDE",
		)
	})

	it("URL-encodes the id", () => {
		expect(invoicePdfUrl("a b&c")).toBe("/apex/InvoicePrintAsPDF?id=a%20b%26c")
	})
})

describe("stripeOrdersCheckoutUrl", () => {
	it("matches the legacy regType=orders shape", () => {
		expect(stripeOrdersCheckoutUrl(" 006gP00000ABCDE ")).toBe(
			"/stripe_checkout?regType=orders&id=006gP00000ABCDE",
		)
	})
})

describe("setOrdersCheckoutSessionCookie", () => {
	afterEach(() => {
		// jsdom keeps cookies across tests — expire ours immediately.
		document.cookie = "garp-checkout-session-token=; path=/; max-age=0"
	})

	it("writes the orders:{id} session cookie", () => {
		setOrdersCheckoutSessionCookie(" 006gP00000ABCDE ")

		expect(document.cookie).toContain(
			"garp-checkout-session-token=orders%3A006gP00000ABCDE",
		)
	})

	it("writes nothing for a blank order id", () => {
		setOrdersCheckoutSessionCookie("   ")

		expect(document.cookie).not.toContain("garp-checkout-session-token")
	})
})
