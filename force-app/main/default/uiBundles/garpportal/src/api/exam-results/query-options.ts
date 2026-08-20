import { queryOptions } from "@tanstack/react-query"

import { fetchExamResults } from "@/api/exam-results/exam-results"

export const examResultsQueryKeys = {
	all: ["exam-results"] as const,
	list: ["exam-results", "list"] as const,
}

export const examResultsQueryOptions = queryOptions({
	queryKey: examResultsQueryKeys.list,
	queryFn: fetchExamResults,
	staleTime: 60_000,
	retry: false,
	meta: {
		toastError: true,
		errorTitle: "Unable to load exam results",
	},
})
