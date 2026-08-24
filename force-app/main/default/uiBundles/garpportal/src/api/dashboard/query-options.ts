import { queryOptions } from "@tanstack/react-query"

import { fetchAd } from "@/api/dashboard/ad"
import { fetchDashboard } from "@/api/dashboard/dashboard"

export const dashboardQueryKeys = {
	all: ["dashboard"] as const,
	ad: ["dashboard", "ad"] as const,
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

/**
 * The cross-sell card's payload.
 *
 * Short stale time and no long cache: Apex draws the programme at random per
 * request, so holding one for a session would pin a rotating card.
 */
export const adQueryOptions = queryOptions({
	queryKey: dashboardQueryKeys.ad,
	queryFn: fetchAd,
	staleTime: 60_000,
	retry: false,
	meta: {
		toastError: false,
		errorTitle: "Unable to load the recommendation",
	},
})
