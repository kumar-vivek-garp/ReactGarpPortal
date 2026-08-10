import { queryOptions } from "@tanstack/react-query"

import { fetchDashboard } from "@/api/dashboard/dashboard"

export const dashboardQueryKeys = {
	all: ["dashboard"] as const,
	view: ["dashboard", "view"] as const,
}

export const dashboardQueryOptions = queryOptions({
	queryKey: dashboardQueryKeys.view,
	queryFn: fetchDashboard,
	staleTime: 60_000,
	retry: false,
	meta: {
		toastError: true,
		errorTitle: "Unable to load dashboard",
	},
})
