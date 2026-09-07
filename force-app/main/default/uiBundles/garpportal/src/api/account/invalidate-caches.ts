import type { QueryClient } from "@tanstack/react-query"

import { accountQueryKeys } from "@/api/account/query-options"
import { authQueryKeys } from "@/api/auth/query-options"
import { personalInfoQueryKeys } from "@/api/personal-info/query-options"

/**
 * After any My Account write, refresh:
 * - the composed REST account view (every tab, the edit dialogs and the
 *   registration forms all read from it)
 * - GraphQL currentUser (sidebar photo / garpId)
 * - the Account billing company the account view omits
 */
export async function invalidateAccountCaches(
	queryClient: QueryClient,
): Promise<void> {
	await Promise.all([
		queryClient.invalidateQueries({ queryKey: accountQueryKeys.detail }),
		queryClient.invalidateQueries({ queryKey: authQueryKeys.currentUser }),
		queryClient.invalidateQueries({ queryKey: personalInfoQueryKeys.all }),
	])
}
