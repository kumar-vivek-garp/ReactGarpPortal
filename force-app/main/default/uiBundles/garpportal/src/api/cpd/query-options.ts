import { queryOptions } from "@tanstack/react-query"

import type { CpdActivityFilters } from "@/api/cpd/types"

import { fetchCpdActivities } from "@/api/cpd/activities"
import { fetchCpdActivityTypes } from "@/api/cpd/activity-types"
import { fetchCpd } from "@/api/cpd/cpd"
import { fetchCpdProgram } from "@/api/cpd/cpd-program"

export const cpdQueryKeys = {
	all: ["cpd"] as const,
	view: ["cpd", "view"] as const,
	program: ["cpd", "program"] as const,
	activityTypes: ["cpd", "activity-types"] as const,
	activities: (filters: CpdActivityFilters) =>
		["cpd", "activities", filters] as const,
}

/** Dashboard CPD summary. Resolves `null` for a member with no CPD program. */
export const cpdQueryOptions = queryOptions({
	queryKey: cpdQueryKeys.view,
	queryFn: fetchCpd,
	staleTime: 60_000,
	retry: false,
	meta: {
		toastError: true,
		errorTitle: "Unable to load CPD credits",
	},
})

/** Every cycle for the CPD page. Empty `cycles` means no CPD program. */
export const cpdProgramQueryOptions = queryOptions({
	queryKey: cpdQueryKeys.program,
	queryFn: fetchCpdProgram,
	staleTime: 60_000,
	retry: false,
	meta: {
		toastError: true,
		errorTitle: "Unable to load CPD activities",
	},
})

/** Activity types + their per-type field labels for the Add Credits form. */
export const cpdActivityTypesQueryOptions = queryOptions({
	queryKey: cpdQueryKeys.activityTypes,
	queryFn: fetchCpdActivityTypes,
	// Org configuration, not member data — it barely changes within a session.
	staleTime: 5 * 60_000,
	retry: false,
	meta: {
		toastError: true,
		errorTitle: "Unable to load activity types",
	},
})

/**
 * One page of Browse Credit Opportunities.
 *
 * The filters are part of the key, so paging and filtering are ordinary cache
 * misses rather than refetches of one key — going back a page is instant.
 * `placeholderData` keeps the previous page on screen while the next loads, so
 * the list does not collapse to a skeleton on every page change.
 */
export function cpdActivitiesQueryOptions(filters: CpdActivityFilters) {
	return queryOptions({
		queryKey: cpdQueryKeys.activities(filters),
		queryFn: () => fetchCpdActivities(filters),
		placeholderData: (previous) => previous,
		staleTime: 60_000,
		retry: false,
		meta: {
			toastError: true,
			errorTitle: "Unable to load credit opportunities",
		},
	})
}
