import { describe, expect, it } from "vitest"

import { adRegistrationHref } from "@/config/dashboard"

describe("adRegistrationHref", () => {
	it("builds the Login start URL from a lower-cased ad type", () => {
		expect(adRegistrationHref("FRM")).toBe("/Login?start=registration/frm")
	})

	it("trims surrounding whitespace before slugging", () => {
		expect(adRegistrationHref(" SCR ")).toBe("/Login?start=registration/scr")
	})

	it("returns null when there is no usable ad type", () => {
		expect(adRegistrationHref(null)).toBeNull()
		expect(adRegistrationHref(undefined)).toBeNull()
		expect(adRegistrationHref("")).toBeNull()
		expect(adRegistrationHref("   ")).toBeNull()
	})
})
