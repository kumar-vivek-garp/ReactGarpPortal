import { useQuery } from "@tanstack/react-query"

import { countryOptionsQueryOptions } from "@/api/personal-info/query-options"

/** Country / phone-code options from `Country_Code__c`. */
export function useCountryOptions(enabled = true) {
	return useQuery({
		...countryOptionsQueryOptions,
		enabled,
	})
}
