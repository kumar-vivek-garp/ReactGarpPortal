import { queryOptions } from "@tanstack/react-query"

import { fetchPrograms } from "@/api/programs/programs"

export const programsQueryKeys = {
	all: ["programs"] as const,
	view: ["programs", "view"] as const,
}

export const programsQueryOptions = queryOptions({
	queryKey: programsQueryKeys.view,
	queryFn: fetchPrograms,
	staleTime: 60_000,
	retry: false,
	meta: {
		toastError: true,
		errorTitle: "Unable to load programs",
	},
})
