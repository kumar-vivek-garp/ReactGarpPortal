import { QueryClient } from "@tanstack/react-query"
import { describe, expect, it, vi } from "vitest"

import { invalidatePurchaseCaches } from "./invalidate-caches"

describe("invalidatePurchaseCaches", () => {
	it("refreshes the catalogue and order history, nothing else", async () => {
		const queryClient = new QueryClient()
		const spy = vi.spyOn(queryClient, "invalidateQueries")

		await invalidatePurchaseCaches(queryClient)

		expect(spy.mock.calls.map(([options]) => options?.queryKey)).toEqual([
			["study-materials"],
			["orders"],
		])
	})
})
