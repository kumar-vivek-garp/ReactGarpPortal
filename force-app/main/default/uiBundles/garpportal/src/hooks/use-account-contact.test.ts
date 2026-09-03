import { waitFor } from "@testing-library/react"
import { describe, expect, it } from "vitest"

import { useAccountContact } from "@/hooks/use-account-contact"
import { sdkGraphqlHandler } from "@/testing/msw/handlers/sdk-graphql"
import { server } from "@/testing/msw/server"
import { renderHookWithProviders } from "@/testing/render"

describe("useAccountContact", () => {
	it("loads the contact for a real id", async () => {
		server.use(
			sdkGraphqlHandler({
				AccountContact: () => ({
					data: {
						uiapi: {
							query: {
								Contact: {
									edges: [
										{ node: { Id: "003A", Email: { value: "g@garp.org" } } },
									],
								},
							},
						},
					},
				}),
			}),
		)

		const { result } = renderHookWithProviders(() => useAccountContact("003A"))

		await waitFor(() => expect(result.current.isSuccess).toBe(true))
		expect(result.current.data).toMatchObject({
			contactId: "003A",
			email: "g@garp.org",
		})
	})

	it("never fires for a blank id or when disabled", () => {
		const blank = renderHookWithProviders(() => useAccountContact("   "))
		expect(blank.result.current.fetchStatus).toBe("idle")

		const disabled = renderHookWithProviders(() =>
			useAccountContact("003A", false),
		)
		expect(disabled.result.current.fetchStatus).toBe("idle")
	})
})
