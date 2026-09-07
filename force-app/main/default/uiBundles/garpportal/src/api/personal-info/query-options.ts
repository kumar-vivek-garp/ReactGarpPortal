import { queryOptions } from "@tanstack/react-query"

import { fetchBillingCompany } from "@/api/personal-info/billing-company"

export const personalInfoQueryKeys = {
	all: ["personal-info"] as const,
	billingCompany: (contactId: string) =>
		["personal-info", "billing-company", contactId] as const,
}

/** The Account billing company the account payload omits — see `billing-company.ts`. */
export function billingCompanyQueryOptions(contactId: string) {
	return queryOptions({
		queryKey: personalInfoQueryKeys.billingCompany(contactId),
		queryFn: () => fetchBillingCompany(contactId),
		enabled: Boolean(contactId.trim()),
		staleTime: 30_000,
		retry: false,
		meta: {
			toastError: true,
			errorTitle: "Unable to load billing details",
		},
	})
}
