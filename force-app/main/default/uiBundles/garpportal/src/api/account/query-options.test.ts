import { describe, expect, it } from "vitest"

import {
	accountContactQueryOptions,
	accountQueryKeys,
} from "@/api/account/query-options"
import { sdkGraphqlHandler } from "@/testing/msw/handlers/sdk-graphql"
import { server } from "@/testing/msw/server"
import { createTestQueryClient } from "@/testing/query-client"

describe("accountContactQueryOptions", () => {
	it("keys by contact id and disables itself for a blank one", () => {
		expect(accountContactQueryOptions("003A").queryKey).toEqual(
			accountQueryKeys.contact("003A"),
		)
		expect(accountContactQueryOptions("003A").enabled).toBe(true)
		expect(accountContactQueryOptions("   ").enabled).toBe(false)
	})

	it("fetches the contact through its queryFn", async () => {
		server.use(
			sdkGraphqlHandler({
				AccountContact: (variables) => {
					expect(variables).toMatchObject({ contactId: "003A", first: 1 })
					return {
						data: {
							uiapi: {
								query: {
									Contact: {
										edges: [
											{
												node: {
													Id: "003A",
													FirstName: { value: "Grace" },
													LastName: { value: "Hopper" },
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

		const queryClient = createTestQueryClient()
		const contact = await queryClient.fetchQuery(
			accountContactQueryOptions("003A"),
		)

		expect(contact).toMatchObject({
			contactId: "003A",
			firstName: "Grace",
			lastName: "Hopper",
		})
	})
})
