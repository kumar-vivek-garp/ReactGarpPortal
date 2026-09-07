import { describe, expect, it } from "vitest"

import type { RegistrationSearch } from "@/config/registration"

import {
	AFFILIATE_REGISTRATION_ROUTE,
	isCheckoutCancelled,
	isPaymentReturn,
	isRegistrationResume,
	isMembershipProgramSlug,
	LEGACY_AFFILIATE_ROUTE,
	MEMBER_EVENT_REGISTRATION_ROUTES,
	MEMBER_REGISTRATION_ROUTE,
	MEMBERSHIP_MEMBER_REGISTRATION_ROUTE,
	PUBLIC_EVENT_REGISTRATION_ROUTES,
	publicRegistrationFallback,
	registrationLegProps,
} from "./registration-paths"

const BLANK: RegistrationSearch = {
	regCode: undefined,
	teamCode: undefined,
	stripe_return: undefined,
	oid: undefined,
	on: undefined,
	checkout_cancelled: undefined,
	resume: undefined,
	track_cta: undefined,
}

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

describe("isRegistrationResume", () => {
	it("fires on any staged id, never on absence", () => {
		expect(isRegistrationResume({ resume: "a0H" })).toBe(true)
		expect(isRegistrationResume({ resume: undefined })).toBe(false)
		expect(isRegistrationResume({ resume: "" })).toBe(false)
	})
})

describe("registrationLegProps", () => {
	it("is a fresh form when no leg param is present", () => {
		expect(registrationLegProps(BLANK)).toEqual({
			paymentReturn: null,
			checkoutCancelled: null,
		})
	})

	it("maps the success leg with the id to poll and the legacy order number", () => {
		expect(
			registrationLegProps({ ...BLANK, stripe_return: "1", oid: "801", on: "W1" }),
		).toEqual({
			paymentReturn: { statusId: "801", orderNumber: "W1" },
			checkoutCancelled: null,
		})
	})

	it("maps a plain cancelled checkout with the order to roll back", () => {
		expect(
			registrationLegProps({ ...BLANK, checkout_cancelled: "1", oid: "801" }),
		).toEqual({
			paymentReturn: null,
			checkoutCancelled: { orderId: "801" },
		})
	})

	it("lets resume WIN over checkout_cancelled — the staged cancel leg carries both", () => {
		// Nothing was created for a staged registration: restoring the form is
		// the better answer than a cancelled screen, and there is nothing to
		// roll back.
		expect(
			registrationLegProps({
				...BLANK,
				checkout_cancelled: "1",
				oid: "a0H",
				resume: "a0H",
			}),
		).toEqual({
			paymentReturn: null,
			checkoutCancelled: null,
			resumeStagedId: "a0H",
		})
	})

	it("lets a payment return win over everything", () => {
		expect(
			registrationLegProps({
				...BLANK,
				stripe_return: "1",
				oid: "801",
				checkout_cancelled: "1",
				resume: "a0H",
			}).paymentReturn,
		).toEqual({ statusId: "801", orderNumber: undefined })
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

	it("does not mistake the study-material purchase page for a registration form", () => {
		// It has no public twin; a guest lands on the sign-in wall instead.
		expect(publicRegistrationFallback("/study-materials/purchase/SCRH")).toBeNull()
		expect(publicRegistrationFallback("/study-materials/purchase/SCRH/")).toBeNull()
	})

	it("redirects the legacy affiliate address somewhere else", () => {
		// The old URL forwards to the live one — pointing at itself would loop.
		expect(LEGACY_AFFILIATE_ROUTE).not.toBe(AFFILIATE_REGISTRATION_ROUTE)
	})
})

describe("the membership twin", () => {
	it("keeps MEMBERSHIP_MEMBER_REGISTRATION_ROUTE in sync with the fallback's regex", () => {
		// A static route, so the constant IS the concrete path.
		expect(publicRegistrationFallback(MEMBERSHIP_MEMBER_REGISTRATION_ROUTE)).toEqual(
			{ kind: "program", programType: "membership" },
		)
	})

	it("names the membership programme by address slug or wire type", () => {
		expect(isMembershipProgramSlug("membership")).toBe(true)
		expect(isMembershipProgramSlug("mem")).toBe(true)
		expect(isMembershipProgramSlug("frm")).toBe(false)
	})
})
