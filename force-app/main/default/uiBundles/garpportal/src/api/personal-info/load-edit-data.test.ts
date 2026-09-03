import { describe, expect, it } from "vitest"

import { loadPersonalInfoEditData } from "@/api/personal-info/load-edit-data"
import { personalInfoEditQueryOptions } from "@/api/personal-info/query-options"
import { sdkGraphqlHandler } from "@/testing/msw/handlers/sdk-graphql"
import { server } from "@/testing/msw/server"

const serveContact = (node: unknown) =>
	sdkGraphqlHandler({
		PersonalInfoEditContact: () => ({
			data: { uiapi: { query: { Contact: { edges: [{ node }] } } } },
		}),
	})

const matchedAddress = {
	Billing_Address_Company__c: { value: "GARP" },
	BillingStreet: { value: "1 Main St\nSuite 4" },
	BillingCity: { value: "Hoboken" },
	BillingState: { value: "NJ" },
	BillingPostalCode: { value: "07030" },
	BillingCountry: { value: "United States" },
	Phone: { value: "5550100" },
}

describe("loadPersonalInfoEditData", () => {
	it("refuses a blank contact id before it reaches the network", async () => {
		await expect(loadPersonalInfoEditData("  ")).rejects.toMatchObject({
			messages: ["Contact Id is required."],
		})
	})

	it("hydrates the form, splitting streets and detecting same-as-billing", async () => {
		server.use(
			serveContact({
				Id: "003xx1",
				FirstName: { value: "Ada" },
				LastName: { value: "Lovelace" },
				Email: { value: "ada@example.com" },
				MobilePhone: { value: "5550199" },
				Mobile_Phone_Code__c: { value: "+1" },
				Photo_URL__c: { value: " /photo.png " },
				Mailing_Address_Company__c: { value: "GARP" },
				MailingStreet: { value: "1 Main St\nSuite 4" },
				MailingCity: { value: "Hoboken" },
				MailingState: { value: "NJ" },
				MailingPostalCode: { value: "07030" },
				MailingCountry: { value: "United States" },
				HomePhone: { value: "5550100" },
				AccountId: { value: "001xx1" },
				Account: { Id: "001xx1", ...matchedAddress },
			}),
		)

		const data = await loadPersonalInfoEditData(" 003xx1 ")
		expect(data).toMatchObject({
			contactId: "003xx1",
			accountId: "001xx1",
			photoUrl: "/photo.png",
			firstName: "Ada",
			mobilePhoneCode: "+1",
			sameAsBilling: true,
		})
		expect(data.billing).toMatchObject({
			address1: "1 Main St",
			address2: "Suite 4",
			address3: "",
			country: "United States",
		})
		expect(data.mailing).toEqual(data.billing)
	})

	it("returns an empty billing block when the Contact has no Account", async () => {
		server.use(
			serveContact({
				Id: "003xx1",
				FirstName: { value: "Ada" },
				MailingCity: { value: "Hoboken" },
				Account: null,
			}),
		)

		const data = await loadPersonalInfoEditData("003xx1")
		expect(data.accountId).toBeNull()
		expect(data.billing.address1).toBe("")
		expect(data.sameAsBilling).toBe(false)
	})

	it("throws the GraphQL error messages", async () => {
		server.use(
			sdkGraphqlHandler({
				PersonalInfoEditContact: () => ({ errors: [{ message: "FLS on Contact" }] }),
			}),
		)

		await expect(loadPersonalInfoEditData("003xx1")).rejects.toMatchObject({
			messages: ["FLS on Contact"],
		})
	})

	it("throws when no Contact row comes back", async () => {
		server.use(serveContact(null))
		await expect(loadPersonalInfoEditData("003xx1")).rejects.toMatchObject({
			messages: ["Unable to load personal information."],
		})
	})
})

describe("personalInfoEditQueryOptions", () => {
	it("keys per contact and disables itself for a blank id", () => {
		expect(personalInfoEditQueryOptions("003xx1").queryKey).toEqual([
			"personal-info",
			"edit",
			"003xx1",
		])
		expect(personalInfoEditQueryOptions("  ").enabled).toBe(false)
	})
})
