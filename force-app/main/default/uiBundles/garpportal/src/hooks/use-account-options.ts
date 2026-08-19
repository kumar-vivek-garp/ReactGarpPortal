import { useQuery } from "@tanstack/react-query"

import { accountOptionsQueryOptions } from "@/api/account/query-options"

/** Contact picklists from `GET /memberportal/options`. */
export function useAccountOptions(enabled = true) {
	return useQuery(accountOptionsQueryOptions(enabled))
}
