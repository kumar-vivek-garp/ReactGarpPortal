import { QueryClient } from "@tanstack/react-query"
import { describe, expect, it, vi } from "vitest"

import {
	invalidateCvAddressCaches,
	invalidateWorkExperienceCaches,
} from "@/api/work-experience/invalidate-caches"

function spiedClient() {
	const queryClient = new QueryClient()
	const invalidate = vi
		.spyOn(queryClient, "invalidateQueries")
		.mockResolvedValue(undefined)
	return { queryClient, invalidate }
}

describe("invalidateWorkExperienceCaches", () => {
	it("drops the whole work-experience prefix — every row can go stale", async () => {
		const { queryClient, invalidate } = spiedClient()
		await invalidateWorkExperienceCaches(queryClient)

		expect(invalidate.mock.calls.map(([f]) => f?.queryKey)).toEqual([
			["work-experience"],
		])
	})
})

describe("invalidateCvAddressCaches", () => {
	it("also drops personal-info — cvAddress writes the Contact itself", async () => {
		const { queryClient, invalidate } = spiedClient()
		await invalidateCvAddressCaches(queryClient)

		expect(invalidate.mock.calls.map(([f]) => f?.queryKey)).toEqual([
			["work-experience"],
			["personal-info"],
		])
	})
})
