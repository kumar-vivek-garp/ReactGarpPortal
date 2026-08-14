import { useQuery } from "@tanstack/react-query"

import { programDetailQueryOptions } from "@/api/programs"

/** Program detail from `GET /memberportal/programDetail`. */
export function useProgramDetail(programType: string) {
	return useQuery(programDetailQueryOptions(programType))
}
