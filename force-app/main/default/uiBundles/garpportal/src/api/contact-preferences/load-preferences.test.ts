import { describe, expect, it } from "vitest"

import { loadContactPreferences } from "@/api/contact-preferences/load-preferences"
import { sdkGraphqlHandler } from "@/testing/msw/handlers/sdk-graphql"
import { server } from "@/testing/msw/server"

describe("loadContactPreferences", () => {
	it("refuses a blank contact id before it reaches the network", async () => {
		await expect(loadContactPreferences("   ")).rejects.toMatchObject({
			messages: ["Contact Id is required."],
		})
	})

	it("maps the Contact node, coercing SMS flags to strict booleans", async () => {
		server.use(
			sdkGraphqlHandler({
				ContactPreferences: (variables) => {
					expect(variables).toMatchObject({ contactId: "003xx1", first: 1 })
					return {
						data: {
							uiapi: {
								query: {
									Contact: {
										edges: [
											{
												node: {
													Id: "003xx1",
													Email: { value: " ada@example.com " },
													MobilePhone: { value: "  " },
													SMS_Promotional_Updates__c: { value: true },
													SMS_Registration_Updates__c: { value: null },
												},
											},
										],
									},
								},
							},
						},
					}
				},
			}),
		)

		await expect(loadContactPreferences(" 003xx1 ")).resolves.toEqual({
			contactId: "003xx1",
			email: "ada@example.com",
			mobilePhone: null,
			mobilePhoneCode: null,
			smsPromotional: true,
			smsRegistration: false,
		})
	})

	it("throws when no Contact row comes back", async () => {
		server.use(
			sdkGraphqlHandler({
				ContactPreferences: () => ({
					data: { uiapi: { query: { Contact: { edges: [] } } } },
				}),
			}),
		)

		await expect(loadContactPreferences("003xx1")).rejects.toMatchObject({
			messages: ["Contact was not found."],
		})
	})
})
