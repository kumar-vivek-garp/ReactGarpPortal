import { describe, expect, it } from "vitest"

import { savePersonalInfo } from "@/api/personal-info/save-personal-info"
import type { PersonalInfoSaveInput } from "@/api/personal-info/types"
import { portalAddressFields } from "@/testing/factories/personal-info"
import { sdkGraphqlHandler } from "@/testing/msw/handlers/sdk-graphql"
import { server } from "@/testing/msw/server"

function saveInput(
	overrides: Partial<PersonalInfoSaveInput> = {},
): PersonalInfoSaveInput {
	return {
		contactId: "003xx1",
		accountId: "001xx1",
		firstName: "Ada",
		lastName: "Lovelace",
		email: "ada@example.com",
		mobilePhoneCode: "+1",
		mobilePhone: "5550199",
		billing: portalAddressFields({ address2: "Suite 4" }),
		mailing: portalAddressFields({
			address1: "9 Other Rd",
			address2: "",
			city: "Jersey City",
		}),
		sameAsBilling: false,
		...overrides,
	}
}

function captureSave() {
	const calls: Array<Record<string, unknown>> = []
	const handler = sdkGraphqlHandler({
		SavePersonalInfo: (variables) => {
			calls.push(variables)
			return {
				data: {
					uiapi: {
						AccountUpdate: { success: true },
						ContactUpdate: { success: true },
					},
				},
			}
		},
	})
	return { calls, handler }
}

describe("savePersonalInfo", () => {
	it("refuses blank ids before the network", async () => {
		await expect(savePersonalInfo(saveInput({ contactId: " " }))).rejects.toMatchObject({
			messages: ["Contact Id is required."],
		})
		await expect(savePersonalInfo(saveInput({ accountId: " " }))).rejects.toMatchObject({
			messages: ["Account Id is required to update billing address."],
		})
	})

	it("joins street lines and nulls blank optionals", async () => {
		const org = captureSave()
		server.use(org.handler)

		await savePersonalInfo(saveInput())

		expect(org.calls).toHaveLength(1)
		expect(org.calls[0]).toMatchObject({
			accountId: "001xx1",
			contactId: "003xx1",
			billingStreet: "1 Main St\nSuite 4",
			mailingStreet: "9 Other Rd",
			mailingCity: "Jersey City",
			homePhone: "5551234",
			// company is "" in the factory — sent as null, not "".
			billingCompany: null,
		})
	})

	it("writes the billing address into the mailing fields when same-as-billing", async () => {
		const org = captureSave()
		server.use(org.handler)

		await savePersonalInfo(saveInput({ sameAsBilling: true }))

		expect(org.calls[0]).toMatchObject({
			mailingStreet: "1 Main St\nSuite 4",
			mailingCity: "Hoboken",
			mailingPostalCode: "07030",
		})
	})

	it("throws the GraphQL error messages", async () => {
		server.use(
			sdkGraphqlHandler({
				SavePersonalInfo: () => ({
					errors: [{ message: "Email invalid" }, { message: "Phone invalid" }],
				}),
			}),
		)

		await expect(savePersonalInfo(saveInput())).rejects.toMatchObject({
			messages: ["Email invalid", "Phone invalid"],
		})
	})
})
