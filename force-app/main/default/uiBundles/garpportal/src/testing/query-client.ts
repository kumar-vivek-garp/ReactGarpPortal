import { QueryClient } from "@tanstack/react-query"

import type { CurrentUser } from "@/api/auth/current-user"
import { authQueryKeys } from "@/api/auth/query-options"

/**
 * Fresh QueryClient for tests. Never reuse the app's exported singleton: its
 * `retry: 1` makes a failing query hit the wire twice (four times once the
 * SDK's own CSRF retry joins in), and its caches bleed between tests.
 *
 * `user` seeds the session the way guards and hooks read it:
 * pass a member object, `null` for a guest, or omit for "not yet fetched".
 */
export function createTestQueryClient(user?: CurrentUser | null) {
	const queryClient = new QueryClient({
		defaultOptions: {
			queries: { retry: false },
			mutations: { retry: false },
		},
	})

	if (user !== undefined) {
		queryClient.setQueryData(authQueryKeys.currentUser, user)
	}

	return queryClient
}
