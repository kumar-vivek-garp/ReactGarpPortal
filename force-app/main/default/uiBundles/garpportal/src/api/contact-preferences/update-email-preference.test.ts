import { afterEach, beforeEach, describe, expect, it, vi } from "vitest"

import { requestEmailPreferences } from "@/api/contact-preferences/update-email-preference"
import { sdkGraphqlHandler } from "@/testing/msw/handlers/sdk-graphql"
import { server } from "@/testing/msw/server"

beforeEach(() => {
	// Only Date is faked — faking timers would stall MSW's fetch internals.
	vi.useFakeTimers({ toFake: ["Date"] })
	vi.setSystemTime(new Date("2026-09-03T12:00:00.000Z"))
})

afterEach(() => {
	vi.useRealTimers()
})

describe("requestEmailPreferences", () => {
	it("refuses a blank contact id before it reaches the network", async () => {
		await expect(requestEmailPreferences("  ")).rejects.toMatchObject({
			messages: ["Contact Id is required."],
		})
	})

	it("stamps the trimmed contact with the current instant", async () => {
		const stamps: Array<Record<string, unknown>> = []
		server.use(
			sdkGraphqlHandler({
				RequestEmailPreferences: (variables) => {
					stamps.push(variables)
					return { data: { uiapi: { ContactUpdate: { success: true } } } }
				},
			}),
		)

		await expect(requestEmailPreferences(" 003xx1 ")).resolves.toBeUndefined()
		expect(stamps).toEqual([
			{ contactId: "003xx1", updatedAt: "2026-09-03T12:00:00.000Z" },
		])
	})

	it("treats an unsuccessful update as a failure", async () => {
		server.use(
			sdkGraphqlHandler({
				RequestEmailPreferences: () => ({
					data: { uiapi: { ContactUpdate: { success: false } } },
				}),
			}),
		)

		await expect(requestEmailPreferences("003xx1")).rejects.toMatchObject({
			messages: ["Unable to request email preference update."],
		})
	})

	it("throws the GraphQL error messages", async () => {
		server.use(
			sdkGraphqlHandler({
				RequestEmailPreferences: () => ({
					errors: [{ message: "Row locked" }],
				}),
			}),
		)

		await expect(requestEmailPreferences("003xx1")).rejects.toMatchObject({
			messages: ["Row locked"],
		})
	})
})
