import { describe, expect, it } from "vitest"

import {
	AFFILIATE_REGISTRATION_ROUTE,
	isCheckoutCancelled,
	isPaymentReturn,
	LEGACY_AFFILIATE_ROUTE,
	MEMBER_EVENT_REGISTRATION_ROUTES,
	MEMBER_REGISTRATION_ROUTE,
	PUBLIC_EVENT_REGISTRATION_ROUTES,
	publicRegistrationFallback,
} from "./registration-paths"

// `publicRegistrationFallback`'s decision matrix (literal member paths, event
// variants, trailing slashes, negatives) is covered by
// `src/auth/registration-guard.test.ts`. This file covers what that one does
// not: the payment-return predicates, and that the exported route CONSTANTS
// stay in sync with the fallback's regexes.

describe("isPaymentReturn", () => {
	it("fires only on the provider's literal flag", () => {
		// `?stripe_return=1` reaches the schema as the number 1; the search
		// validator has already coerced it back to "1" by the time guards ask.
		expect(isPaymentReturn({ stripe_return: "1" })).toBe(true)
		expect(isPaymentReturn({ stripe_return: undefined })).toBe(false)
		expect(isPaymentReturn({ stripe_return: "0" })).toBe(false)
		expect(isPaymentReturn({ stripe_return: "" })).toBe(false)
	})
})

describe("isCheckoutCancelled", () => {
	it("fires only on the cancelled leg's literal flag", () => {
		expect(isCheckoutCancelled({ checkout_cancelled: "1" })).toBe(true)
		expect(isCheckoutCancelled({ checkout_cancelled: undefined })).toBe(false)
		expect(isCheckoutCancelled({ checkout_cancelled: "0" })).toBe(false)
	})
})

describe("route constants stay in sync with the fallback regexes", () => {
	it("recognises the member registration route pattern it exports", () => {
		// Built FROM the constant, so a route rename cannot silently strand the
		// regex on the old path.
		const concrete = MEMBER_REGISTRATION_ROUTE.replace("$programType", "frm")
		expect(publicRegistrationFallback(concrete)).toEqual({
			kind: "program",
			programType: "frm",
		})
	})

	it("recognises every member event route it exports", () => {
		for (const [variant, pattern] of Object.entries(
			MEMBER_EVENT_REGISTRATION_ROUTES,
		)) {
			const concrete = pattern.replace("$eventId", "a2h5d000")
			expect(publicRegistrationFallback(concrete)).toEqual({
				kind: "event",
				variant,
				eventId: "a2h5d000",
			})
		}
	})

	it("keeps each public event route static under /registration/<variant>", () => {
		// Static segments outrank `$programType`, which is what stops an event id
		// being folded into `regCode` on the exam form.
		for (const [variant, pattern] of Object.entries(
			PUBLIC_EVENT_REGISTRATION_ROUTES,
		)) {
			expect(pattern).toBe(`/registration/${variant}/$eventId`)
		}
	})

	it("pairs the same object families on both sides", () => {
		expect(Object.keys(MEMBER_EVENT_REGISTRATION_ROUTES).sort()).toEqual(
			Object.keys(PUBLIC_EVENT_REGISTRATION_ROUTES).sort(),
		)
	})

	it("redirects the legacy affiliate address somewhere else", () => {
		// The old URL forwards to the live one — pointing at itself would loop.
		expect(LEGACY_AFFILIATE_ROUTE).not.toBe(AFFILIATE_REGISTRATION_ROUTE)
	})
})
