import { describe, expect, it } from "vitest"

import { AppError } from "@/api/client"
import { updateSmsPreferences } from "@/api/contact-preferences/update-sms-preferences"
import { completeness } from "@/testing/factories/account"
import { myAccountOrg } from "@/testing/msw/handlers/account"
import { server } from "@/testing/msw/server"

describe("updateSmsPreferences", () => {
	it("posts both consents through the profile action and echoes them back", async () => {
		const org = myAccountOrg()
		server.use(...org.handlers)

		await expect(
			updateSmsPreferences({ smsPromotional: true, smsRegistration: false }),
		).resolves.toEqual({ smsPromotional: true, smsRegistration: false })

		expect(org.profileSpy.bodies).toEqual([
			{ SMS_Promotional_Updates__c: true, SMS_Registration_Updates__c: false },
		])
	})

	it("throws when the org rejects a consent field", async () => {
		server.use(
			...myAccountOrg({
				profileRespond: () => ({
					applied: [],
					rejected: ["SMS_Promotional_Updates__c"],
					completeness: completeness(),
				}),
			}).handlers,
		)

		const failure = updateSmsPreferences({
			smsPromotional: true,
			smsRegistration: true,
		})
		await expect(failure).rejects.toBeInstanceOf(AppError)
		await expect(failure).rejects.toMatchObject({
			messages: ["These fields could not be saved: SMS_Promotional_Updates__c."],
		})
	})
})
