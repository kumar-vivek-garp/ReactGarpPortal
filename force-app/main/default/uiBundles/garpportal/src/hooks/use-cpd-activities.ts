import { useQuery } from "@tanstack/react-query"

import { cpdActivitiesQueryOptions, type CpdActivityFilters } from "@/api/cpd"

/** One page of Browse Credit Opportunities (`GET /memberportal/cpdActivities`). */
export function useCpdActivities(filters: CpdActivityFilters) {
	return useQuery(cpdActivitiesQueryOptions(filters))
}
