import { QueryClient } from "@tanstack/react-query"
import { describe, expect, it, vi } from "vitest"

import { invalidateAccountCaches } from "@/api/account/invalidate-caches"

describe("invalidateAccountCaches", () => {
	it("drops every cache a personal-info write can stale", async () => {
		const queryClient = new QueryClient()
		const invalidate = vi
			.spyOn(queryClient, "invalidateQueries")
			.mockResolvedValue(undefined)

		await invalidateAccountCaches(queryClient, " 003xx1 ")

		const keys = invalidate.mock.calls.map(([filters]) => filters?.queryKey)
		expect(keys).toEqual([
			["account", "detail"],
			// The contact PREFIX, so every AccountContact variant is dropped.
			["account", "contact"],
			["auth", "currentUser"],
			// The contact id is trimmed before keying.
			["personal-info", "edit", "003xx1"],
			["contact-preferences", "detail", "003xx1"],
		])
	})
})
