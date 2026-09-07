import { useQuery } from "@tanstack/react-query"

import { accountOptionsQueryOptions } from "@/api/account/query-options"
import { toCountryOptions } from "@/api/personal-info/countries"

/** Country options for the address selects (`GET /memberportal/options`). */
export function useCountryOptions(enabled = true) {
	return useQuery({
		...accountOptionsQueryOptions(enabled),
		select: toCountryOptions,
	})
}
