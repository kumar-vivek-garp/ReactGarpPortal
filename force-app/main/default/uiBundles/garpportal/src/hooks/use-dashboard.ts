import { useQuery } from "@tanstack/react-query"

import { dashboardQueryOptions } from "@/api/dashboard"

/** Dashboard cards + completeness from `GET /memberportal/dashboard`. */
export function useDashboard() {
	return useQuery(dashboardQueryOptions)
}
