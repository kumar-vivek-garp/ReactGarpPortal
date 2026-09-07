import { QueryClient } from "@tanstack/react-query"
import { describe, expect, it, vi } from "vitest"

import { invalidateAccountCaches } from "@/api/account/invalidate-caches"

describe("invalidateAccountCaches", () => {
	it("drops every cache a My Account write can stale", async () => {
		const queryClient = new QueryClient()
		const invalidate = vi
			.spyOn(queryClient, "invalidateQueries")
			.mockResolvedValue(undefined)

		await invalidateAccountCaches(queryClient)

		const keys = invalidate.mock.calls.map(([filters]) => filters?.queryKey)
		expect(keys).toEqual([
			["account", "detail"],
			["auth", "currentUser"],
			// The PREFIX, so the per-contact billing-company read is dropped too.
			["personal-info"],
		])
	})
})
