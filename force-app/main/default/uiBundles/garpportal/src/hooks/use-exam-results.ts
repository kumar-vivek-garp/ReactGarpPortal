import { useQuery } from "@tanstack/react-query"

import { examResultsQueryOptions } from "@/api/exam-results"

/** Member exam attempts from `GET /memberportal/examResults`. */
export function useExamResults(enabled = true) {
	return useQuery({
		...examResultsQueryOptions,
		enabled,
	})
}
