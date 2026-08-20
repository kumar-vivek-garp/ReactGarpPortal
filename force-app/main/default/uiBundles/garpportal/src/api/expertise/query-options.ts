import { queryOptions } from "@tanstack/react-query"

import { fetchExpertise } from "@/api/expertise/expertise"

export const expertiseQueryKeys = {
	all: ["expertise"] as const,
	view: ["expertise", "view"] as const,
}

export const expertiseQueryOptions = queryOptions({
	queryKey: expertiseQueryKeys.view,
	queryFn: fetchExpertise,
	staleTime: 60_000,
	retry: false,
	meta: {
		toastError: true,
		errorTitle: "Unable to load expertise",
	},
})
