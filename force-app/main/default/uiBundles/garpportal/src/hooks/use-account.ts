import { useQuery } from "@tanstack/react-query"

import { accountQueryOptions } from "@/api/account/query-options"

/** Composed My Account view from `GET /memberportal/account`. */
export function useAccount() {
	return useQuery(accountQueryOptions)
}
