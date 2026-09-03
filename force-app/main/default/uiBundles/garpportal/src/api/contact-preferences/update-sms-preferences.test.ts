import { describe, expect, it } from "vitest"

import { updateSmsPreferences } from "@/api/contact-preferences/update-sms-preferences"
import { sdkGraphqlHandler } from "@/testing/msw/handlers/sdk-graphql"
import { server } from "@/testing/msw/server"

const input = { contactId: " 003xx1 ", smsPromotional: true, smsRegistration: false }

describe("updateSmsPreferences", () => {
	it("refuses a blank contact id before it reaches the network", async () => {
		await expect(
			updateSmsPreferences({ ...input, contactId: "  " }),
		).rejects.toMatchObject({ messages: ["Contact Id is required."] })
	})

	it("writes both flags and reads the saved values back", async () => {
		const writes: Array<Record<string, unknown>> = []
		server.use(
			sdkGraphqlHandler({
				UpdateSmsPreferences: (variables) => {
					writes.push(variables)
					return {
						data: {
							uiapi: {
								ContactUpdate: {
									success: true,
									Record: {
										SMS_Promotional_Updates__c: { value: true },
										SMS_Registration_Updates__c: { value: false },
									},
								},
							},
						},
					}
				},
			}),
		)

		await expect(updateSmsPreferences(input)).resolves.toEqual({
			smsPromotional: true,
			smsRegistration: false,
		})
		expect(writes).toEqual([
			{ contactId: "003xx1", smsPromotional: true, smsRegistration: false },
		])
	})

	it("treats an unsuccessful update as a failure", async () => {
		server.use(
			sdkGraphqlHandler({
				UpdateSmsPreferences: () => ({
					data: { uiapi: { ContactUpdate: { success: false } } },
				}),
			}),
		)

		await expect(updateSmsPreferences(input)).rejects.toMatchObject({
			messages: ["Unable to update SMS preferences."],
		})
	})

	it("throws the GraphQL error messages", async () => {
		server.use(
			sdkGraphqlHandler({
				UpdateSmsPreferences: () => ({ errors: [{ message: "FLS on SMS field" }] }),
			}),
		)

		await expect(updateSmsPreferences(input)).rejects.toMatchObject({
			messages: ["FLS on SMS field"],
		})
	})
})
