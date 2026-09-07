import { useQuery } from "@tanstack/react-query"

import { accountOptionsQueryOptions } from "@/api/account/query-options"
import { toPhoneCodeOptions } from "@/api/personal-info/countries"

/** `"United States (+1)"` choices for `Mobile_Phone_Code__c`, verbatim from the org. */
export function usePhoneCodeOptions(enabled = true) {
	return useQuery({
		...accountOptionsQueryOptions(enabled),
		select: toPhoneCodeOptions,
	})
}
