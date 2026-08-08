import { useQuery } from "@tanstack/react-query"

import { currentUserQueryOptions } from "@/api/auth/query-options"

/** Session identity from Salesforce GraphQL `currentUser` (React Query cache). */
export function useCurrentUser() {
	return useQuery(currentUserQueryOptions)
}
