import { queryOptions } from "@tanstack/react-query"

import { fetchMembership } from "@/api/membership/membership"

export const membershipQueryKeys = {
	all: ["membership"] as const,
	view: ["membership", "view"] as const,
}

export const membershipQueryOptions = queryOptions({
	queryKey: membershipQueryKeys.view,
	queryFn: fetchMembership,
	staleTime: 60_000,
	retry: false,
	meta: {
		toastError: true,
		errorTitle: "Unable to load membership",
	},
})
