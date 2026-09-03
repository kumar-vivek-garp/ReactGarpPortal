import { describe, expect, it } from "vitest"

import { fetchAccountContact } from "@/api/account/account-contact"
import { AppError } from "@/api/client"
import { sdkGraphqlHandler } from "@/testing/msw/handlers/sdk-graphql"
import { server } from "@/testing/msw/server"

/** A Contact node exercising trimming, fallbacks and boolean mapping. */
const node = {
	Id: "003xx1",
	FirstName: { value: " Ada " },
	LastName: { value: "Lovelace" },
	Name: { value: "Ada Lovelace" },
	Email: { value: "ada@example.com" },
	Phone: { value: null },
	Photo_URL__c: { value: "  " },
	GARP_Member_ID__c: { value: "  " },
	GARP_ID__c: { value: " LEGACY-1 " },
	Membership_Type__c: { value: "Individual" },
	MPS_Membership_Status__c: { value: "Active" },
	KPI_Membership_Expiration_Date__c: { value: " " },
	Membership_Caluclated_Expiration_Date__c: { value: "2027-01-31" },
	MPS_Membership_Expire_Date__c: { value: "2026-01-31" },
	KPI_Membership_Since__c: { value: "2019-06-01" },
	MPS_Membership_Autorenew_On__c: { value: true },
	Currently_in_School__c: { value: false },
	GARP_Directory_Opt_In__c: { value: true },
	GARP_Directory_Connect_Feature__c: { value: null },
	MailingCity: { value: "London" },
	MailingCountry: { value: "United Kingdom" },
	Account: {
		Id: "001xx1",
		BillingCity: { value: "New York" },
		BillingCountry: { value: "United States" },
	},
}

const serveContact = (contactNode: unknown) =>
	sdkGraphqlHandler({
		AccountContact: () => ({
			data: {
				uiapi: {
					query: { Contact: { edges: [{ node: contactNode }] } },
				},
			},
		}),
	})

describe("fetchAccountContact", () => {
	it("refuses a blank contact id before it reaches the network", async () => {
		await expect(fetchAccountContact("   ")).rejects.toMatchObject({
			messages: ["Contact Id is required."],
		})
	})

	it("maps the Contact node into the account-contact shape", async () => {
		server.use(serveContact(node))

		const contact = await fetchAccountContact(" 003xx1 ")
		expect(contact).toMatchObject({
			contactId: "003xx1",
			firstName: "Ada",
			email: "ada@example.com",
			// Member id blank → legacy GARP id fallback.
			garpId: "LEGACY-1",
			// Blank string trims to null.
			photoUrl: null,
			membershipType: "Individual",
			// firstDate: KPI blank → calculated date wins over MPS.
			membershipExpiration: "2027-01-31",
			autoRenew: true,
		})
		expect(contact.academic.currentlyInSchool).toBe(false)
		expect(contact.directory).toMatchObject({
			optedIn: true,
			connectFeature: null,
		})
		expect(contact.mailing).toMatchObject({
			city: "London",
			country: "United Kingdom",
			street: null,
		})
		expect(contact.billing).toMatchObject({
			city: "New York",
			country: "United States",
		})
	})

	it("throws the GraphQL error messages", async () => {
		server.use(
			sdkGraphqlHandler({
				AccountContact: () => ({
					errors: [{ message: "Field Phone is not accessible" }],
				}),
			}),
		)

		const failure = fetchAccountContact("003xx1")
		await expect(failure).rejects.toBeInstanceOf(AppError)
		await expect(failure).rejects.toMatchObject({
			messages: ["Field Phone is not accessible"],
		})
	})

	it("throws when no Contact row comes back", async () => {
		server.use(serveContact(null))
		await expect(fetchAccountContact("003xx1")).rejects.toMatchObject({
			messages: ["Unable to load account contact."],
		})
	})
})
