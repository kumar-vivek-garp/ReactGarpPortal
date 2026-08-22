import { useQuery } from "@tanstack/react-query"

import { cpdProgramQueryOptions } from "@/api/cpd"

/** Every CPD cycle with its claims from `GET /memberportal/cpdProgram`. */
export function useCpdProgram(enabled = true) {
	return useQuery({ ...cpdProgramQueryOptions, enabled })
}
