import { describe, expect, it } from "vitest"

import { AppError } from "@/api/client"
import { fetchBillingCompany } from "@/api/personal-info/billing-company"
import { billingCompanyQueryOptions } from "@/api/personal-info/query-options"
import { sdkGraphqlHandler } from "@/testing/msw/handlers/sdk-graphql"
import { server } from "@/testing/msw/server"

const serveContact = (node: unknown) =>
	sdkGraphqlHandler({
		BillingCompany: () => ({
			data: { uiapi: { query: { Contact: { edges: [{ node }] } } } },
		}),
	})

describe("fetchBillingCompany", () => {
	it("refuses a blank contact id before it reaches the network", async () => {
		await expect(fetchBillingCompany("  ")).rejects.toMatchObject({
			messages: ["Contact Id is required."],
		})
	})

	it("reads the Account's billing company off the Contact", async () => {
		server.use(
			serveContact({
				Id: "003xx1",
				Account: { Id: "001xx1", Billing_Address_Company__c: { value: " GARP " } },
			}),
		)

		await expect(fetchBillingCompany(" 003xx1 ")).resolves.toEqual({
			accountId: "001xx1",
			billingCompany: "GARP",
		})
	})

	it("resolves nulls for a Contact with no Account", async () => {
		server.use(serveContact({ Id: "003xx1", Account: null }))

		await expect(fetchBillingCompany("003xx1")).resolves.toEqual({
			accountId: null,
			billingCompany: null,
		})
	})

	it("throws the GraphQL error messages", async () => {
		server.use(
			sdkGraphqlHandler({
				BillingCompany: () => ({ errors: [{ message: "FLS on Account" }] }),
			}),
		)

		const failure = fetchBillingCompany("003xx1")
		await expect(failure).rejects.toBeInstanceOf(AppError)
		await expect(failure).rejects.toMatchObject({ messages: ["FLS on Account"] })
	})

	it("throws when no Contact row comes back", async () => {
		server.use(serveContact(null))
		await expect(fetchBillingCompany("003xx1")).rejects.toMatchObject({
			messages: ["Unable to load billing details."],
		})
	})
})

describe("billingCompanyQueryOptions", () => {
	it("keys per contact and disables itself for a blank id", () => {
		expect(billingCompanyQueryOptions("003xx1").queryKey).toEqual([
			"personal-info",
			"billing-company",
			"003xx1",
		])
		expect(billingCompanyQueryOptions("  ").enabled).toBe(false)
	})
})
