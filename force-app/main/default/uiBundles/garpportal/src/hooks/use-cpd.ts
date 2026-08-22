import { useQuery } from "@tanstack/react-query"

import { cpdQueryOptions } from "@/api/cpd"

/**
 * Dashboard CPD summary from `GET /memberportal/cpd`.
 * Resolves `null` when the member has no CPD program.
 */
export function useCpd(enabled = true) {
	return useQuery({ ...cpdQueryOptions, enabled })
}
