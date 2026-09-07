import type { QueryClient } from "@tanstack/react-query"

import { accountQueryKeys } from "@/api/account/query-options"

/** Contact Preferences read off the composed account view; refresh it after a write. */
export async function invalidateContactPreferencesCaches(
	queryClient: QueryClient,
): Promise<void> {
	await queryClient.invalidateQueries({ queryKey: accountQueryKeys.detail })
}
