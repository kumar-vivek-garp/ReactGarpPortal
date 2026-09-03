import { describe, expect, it } from "vitest"

import { AppError } from "@/api/client"
import { fetchCountryOptions, phoneCodeOptions } from "@/api/personal-info/countries"
import type { CountryOption } from "@/api/personal-info/types"
import { sdkGraphqlHandler } from "@/testing/msw/handlers/sdk-graphql"
import { server } from "@/testing/msw/server"

function countryEdges(nodes: unknown[]) {
	return {
		data: {
			uiapi: {
				query: {
					Country_Code__c: { edges: nodes.map((node) => ({ node })) },
				},
			},
		},
	}
}

describe("fetchCountryOptions", () => {
	/**
	 * Runs FIRST: this module does not opt out of the SDK's in-memory GraphQL
	 * cache, so once a success response lands, later identical queries in this
	 * file are answered from cache without touching MSW. Error responses are
	 * not cached, so the failure case must come before the success case.
	 */
	it("throws the GraphQL error messages", async () => {
		server.use(
			sdkGraphqlHandler({
				PersonalInfoCountries: () => ({
					errors: [{ message: "Object Country_Code__c not accessible" }],
				}),
			}),
		)

		const failure = fetchCountryOptions()
		await expect(failure).rejects.toBeInstanceOf(AppError)
		await expect(failure).rejects.toMatchObject({
			messages: ["Object Country_Code__c not accessible"],
		})
	})

	it("maps rows, falling back to Name and de-duplicating", async () => {
		server.use(
			sdkGraphqlHandler({
				PersonalInfoCountries: (variables) => {
					expect(variables).toMatchObject({ first: 500 })
					return countryEdges([
						{
							Id: "1",
							Country__c: { value: " United States " },
							PhoneCode__c: { value: " +1 " },
						},
						// No Country__c — label comes from Name.
						{ Id: "2", Name: { value: "Curacao" }, PhoneCode__c: { value: null } },
						// Duplicate of the first — dropped.
						{ Id: "3", Country__c: { value: "United States" } },
						// No usable label at all — dropped.
						{ Id: "4", Country__c: { value: " " }, Name: { value: "" } },
					])
				},
			}),
		)

		await expect(fetchCountryOptions()).resolves.toEqual([
			{ label: "United States", value: "United States", phoneCode: "+1" },
			{ label: "Curacao", value: "Curacao", phoneCode: null },
		])
	})
})

describe("phoneCodeOptions", () => {
	const option = (phoneCode: string | null): CountryOption => ({
		label: "x",
		value: "x",
		phoneCode,
	})

	it("de-duplicates and sorts numerically", () => {
		expect(
			phoneCodeOptions([
				option("+44"),
				option("+1"),
				option(null),
				option("+44"),
				option("+7"),
			]),
		).toEqual([
			{ label: "+1", value: "+1" },
			{ label: "+7", value: "+7" },
			{ label: "+44", value: "+44" },
		])
	})
})
