import { useQuery } from "@tanstack/react-query"

import { programsQueryOptions } from "@/api/programs"

/** Program listing buckets from `GET /memberportal/programs`. */
export function usePrograms() {
	return useQuery(programsQueryOptions)
}
