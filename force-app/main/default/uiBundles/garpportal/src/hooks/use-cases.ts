import { useQuery } from "@tanstack/react-query"

import { casesQueryOptions } from "@/api/help-center"

/** Support cases from `GET /memberportal/cases`. */
export function useCases() {
	return useQuery(casesQueryOptions)
}
