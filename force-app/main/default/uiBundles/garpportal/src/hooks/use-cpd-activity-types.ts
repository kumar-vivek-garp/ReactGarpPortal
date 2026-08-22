import { useQuery } from "@tanstack/react-query"

import { cpdActivityTypesQueryOptions } from "@/api/cpd"

/** Activity types + per-type field labels from `GET /memberportal/cpdActivityTypes`. */
export function useCpdActivityTypes(enabled = true) {
	return useQuery({ ...cpdActivityTypesQueryOptions, enabled })
}
