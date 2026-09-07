import { describe, expect, it } from "vitest"

import { toContactPreferences } from "@/api/contact-preferences/preferences"
import { accountView } from "@/testing/factories/account"

describe("toContactPreferences", () => {
	it("takes the display fields and both SMS consents off the account view", () => {
		const view = accountView({
			identity: { contactId: "003xx1" },
			personal: {
				email: " ada@example.com ",
				mobilePhone: "5551234567",
				mobilePhoneCode: "United States (+1)",
			},
			preferences: { smsPromotional: true, smsRegistration: null },
		})

		expect(toContactPreferences(view)).toEqual({
			contactId: "003xx1",
			email: "ada@example.com",
			mobilePhone: "5551234567",
			mobilePhoneCode: "United States (+1)",
			smsPromotional: true,
			smsRegistration: false,
		})
	})

	it("maps blanks to null and unset consents to false", () => {
		const view = accountView({
			personal: { email: " ", mobilePhone: null, mobilePhoneCode: null },
		})

		expect(toContactPreferences(view)).toMatchObject({
			email: null,
			mobilePhone: null,
			mobilePhoneCode: null,
			smsPromotional: false,
			smsRegistration: false,
		})
	})
})
