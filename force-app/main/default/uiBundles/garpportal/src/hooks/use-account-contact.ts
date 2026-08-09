import { useQuery } from "@tanstack/react-query"

import { accountContactQueryOptions } from "@/api/account/query-options"

/**
 * GraphQL Contact essentials for My Account (scaffold — expand fields later).
 * Completeness continues to come from REST `useAccount()`.
 */
export function useAccountContact(contactId: string, enabled = true) {
	return useQuery({
		...accountContactQueryOptions(contactId),
		enabled: enabled && Boolean(contactId.trim()),
	})
}
