import { queryOptions } from "@tanstack/react-query"

import { fetchOsta } from "@/api/osta/osta"

export const ostaQueryKeys = {
	all: ["osta"] as const,
	identity: ["osta", "identity"] as const,
}

/**
 * Identity details on file.
 *
 * Never cached: `ostaConsent` always reads back false and `idNumber` is a
 * masked tail, so there is nothing here worth holding on to between visits.
 */
export const ostaQueryOptions = queryOptions({
	queryKey: ostaQueryKeys.identity,
	queryFn: fetchOsta,
	staleTime: 0,
	gcTime: 0,
	retry: false,
	meta: {
		toastError: true,
		errorTitle: "Unable to load your identity details",
	},
})
