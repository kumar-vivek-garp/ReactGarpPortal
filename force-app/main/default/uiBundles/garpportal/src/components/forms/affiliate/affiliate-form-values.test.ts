import { describe, expect, it } from "vitest"

import { EMPTY_AFFILIATE_VALUES } from "@/components/forms/affiliate/affiliate-form-values"

describe("EMPTY_AFFILIATE_VALUES", () => {
	it("seeds every text field empty — the route is guest-only, nothing prefills", () => {
		expect(EMPTY_AFFILIATE_VALUES.email).toBe("")
		expect(EMPTY_AFFILIATE_VALUES.firstName).toBe("")
		expect(EMPTY_AFFILIATE_VALUES.lastName).toBe("")
		expect(EMPTY_AFFILIATE_VALUES.mobilePhoneCode).toBe("")
		expect(EMPTY_AFFILIATE_VALUES.mobilePhone).toBe("")
		expect(EMPTY_AFFILIATE_VALUES.country).toBe("")
	})

	it("starts every consent unticked — a carried-over tick is worth nothing", () => {
		expect(EMPTY_AFFILIATE_VALUES.smsPromotionalUpdates).toBe(false)
		expect(EMPTY_AFFILIATE_VALUES.attestPrivacyNotice).toBe(false)
		expect(EMPTY_AFFILIATE_VALUES.attestLimitationOfLiability).toBe(false)
		expect(EMPTY_AFFILIATE_VALUES.attestReleaseAndWaiver).toBe(false)
	})
})
