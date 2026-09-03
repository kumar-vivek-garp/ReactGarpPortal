import { QueryClient } from "@tanstack/react-query"
import { describe, expect, it, vi } from "vitest"

import type { CurrentUser } from "@/api/auth/current-user"
import { authQueryKeys, ensureCurrentUser } from "@/api/auth/query-options"

const member: CurrentUser = {
	id: "005xx1",
	name: "Ada Lovelace",
	garpId: "G-1",
	contactId: "003xx1",
	photoUrl: null,
}

describe("ensureCurrentUser", () => {
	it("serves the cached session without refetching", async () => {
		const queryClient = new QueryClient()
		queryClient.setQueryData(authQueryKeys.currentUser, member)

		await expect(ensureCurrentUser(queryClient)).resolves.toEqual(member)
	})

	it("never throws — a failing probe resolves null for the guards", async () => {
		const queryClient = new QueryClient()
		vi.spyOn(queryClient, "ensureQueryData").mockRejectedValue(
			new Error("query client torn down"),
		)

		await expect(ensureCurrentUser(queryClient)).resolves.toBeNull()
	})
})
