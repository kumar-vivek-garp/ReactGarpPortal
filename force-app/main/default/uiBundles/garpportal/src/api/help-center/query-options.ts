import { queryOptions } from "@tanstack/react-query"

import { fetchCases } from "@/api/help-center/cases"

export const helpCenterQueryKeys = {
	all: ["help-center"] as const,
	cases: ["help-center", "cases"] as const,
}

export const casesQueryOptions = queryOptions({
	queryKey: helpCenterQueryKeys.cases,
	queryFn: fetchCases,
	staleTime: 60_000,
	retry: false,
	meta: {
		toastError: true,
		errorTitle: "Unable to load your requests",
	},
})
