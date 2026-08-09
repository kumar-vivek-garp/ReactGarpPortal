import type { QueryClient } from "@tanstack/react-query"

import { accountQueryKeys } from "@/api/account/query-options"
import { authQueryKeys } from "@/api/auth/query-options"
import { personalInfoQueryKeys } from "@/api/personal-info"

/**
 * After personal-info / photo mutations, refresh:
 * - REST account (completeness)
 * - GraphQL AccountContact (information panel)
 * - GraphQL currentUser (sidebar photo / garpId)
 * - personal-info edit hydrate
 */
export async function invalidateAccountCaches(
	queryClient: QueryClient,
	contactId: string,
): Promise<void> {
	const trimmedId = contactId.trim()
	await Promise.all([
		queryClient.invalidateQueries({ queryKey: accountQueryKeys.detail }),
		// Prefix matches `["account", "contact", contactId]` (and any future variants).
		queryClient.invalidateQueries({ queryKey: accountQueryKeys.contacts }),
		queryClient.invalidateQueries({ queryKey: authQueryKeys.currentUser }),
		queryClient.invalidateQueries({
			queryKey: personalInfoQueryKeys.edit(trimmedId),
		}),
	])
}
