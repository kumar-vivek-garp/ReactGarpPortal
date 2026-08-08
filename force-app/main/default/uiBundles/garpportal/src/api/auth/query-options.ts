import type { QueryClient } from "@tanstack/react-query"

import { fetchCurrentUser } from "@/api/auth/current-user"

export const authQueryKeys = {
	all: ["auth"] as const,
	currentUser: ["auth", "currentUser"] as const,
}

export const currentUserQueryOptions = {
	queryKey: authQueryKeys.currentUser,
	queryFn: fetchCurrentUser,
	staleTime: 60_000,
	retry: false as const,
	/** Auth probe — never toast; null means guest. */
	meta: { silent: true },
}

/**
 * Prefetch / reuse cached session identity for route `beforeLoad` guards.
 * Never throws — guest / 401 / transport failures resolve to `null`.
 */
export async function ensureCurrentUser(queryClient: QueryClient) {
	try {
		return await queryClient.ensureQueryData(currentUserQueryOptions)
	} catch {
		return null
	}
}
