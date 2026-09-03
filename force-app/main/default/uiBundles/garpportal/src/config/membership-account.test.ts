import { describe, expect, it } from "vitest"

import { stripeSetupCheckoutUrl } from "@/config/membership-account"

describe("stripeSetupCheckoutUrl", () => {
	it("matches the legacy mode=setup shape", () => {
		expect(stripeSetupCheckoutUrl("006gP00000ABCDE")).toBe(
			"/stripe_checkout?mode=setup&id=006gP00000ABCDE",
		)
	})

	it("interpolates a missing id literally — current behavior, callers must guard", () => {
		expect(stripeSetupCheckoutUrl(null)).toBe("/stripe_checkout?mode=setup&id=null")
		expect(stripeSetupCheckoutUrl(undefined)).toBe(
			"/stripe_checkout?mode=setup&id=undefined",
		)
	})
})
