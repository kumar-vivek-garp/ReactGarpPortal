import { createDataSDK } from "@salesforce/platform-sdk"

import {
	normalizeHttpResponse,
	unwrapApiResult,
	unwrapMemberPortalEnvelope,
} from "@/api/client"
import type {
	CpdActivityFilters,
	CpdActivityView,
	MemberPortalEnvelope,
} from "@/api/cpd/types"

const CPD_ACTIVITIES_PATH = "/services/apexrest/memberportal/cpdActivities"

/** Apex splits these on ";" and binds each value — never interpolated. */
function joinFacet(values: string[] | undefined): string | null {
	const list = (values ?? []).map((value) => value.trim()).filter(Boolean)
	return list.length > 0 ? list.join(";") : null
}

/** Only the params the caller actually set, so Apex sees null for the rest. */
export function buildActivitySearchParams(
	filters: CpdActivityFilters,
): URLSearchParams {
	const params = new URLSearchParams()
	const entries: [string, string | null][] = [
		["activityTypes", joinFacet(filters.activityTypes)],
		["areasOfStudy", joinFacet(filters.areasOfStudy)],
		["providers", joinFacet(filters.providers)],
		["sortOrder", filters.sortOrder?.trim() || null],
		["pageSize", filters.pageSize == null ? null : String(filters.pageSize)],
		[
			"pageCurrent",
			filters.pageCurrent == null ? null : String(filters.pageCurrent),
		],
	]
	for (const [key, value] of entries) {
		if (value !== null) params.set(key, value)
	}
	return params
}

/**
 * Browse Credit Opportunities, from Apex `GARP_Portal_API` (`cpdActivities`).
 *
 * Paging and sorting are server-side: `pageCurrent` is 1-based and `pageSize`
 * defaults to 20 and is capped at 100. `sortOrder` must be one of the four
 * labels the service recognises — anything else silently falls back to its
 * default ordering rather than erroring.
 */
export async function fetchCpdActivities(
	filters: CpdActivityFilters = {},
): Promise<CpdActivityView> {
	const sdk = await createDataSDK()
	const params = buildActivitySearchParams(filters)
	const query = params.toString()
	const path = query ? `${CPD_ACTIVITIES_PATH}?${query}` : CPD_ACTIVITIES_PATH

	const response = await sdk.fetch?.(path, {
		method: "GET",
		headers: { Accept: "application/json" },
	})

	const result = await normalizeHttpResponse<
		MemberPortalEnvelope<CpdActivityView>
	>(response, {
		unreachableMessage: "Unable to reach the CPD service.",
		fallbackErrorMessage:
			"Unable to load credit opportunities. Please try again.",
	})

	const envelope = unwrapApiResult(result)

	const data = unwrapMemberPortalEnvelope(envelope, {
		fallbackErrorMessage: "Unable to load credit opportunities.",
		missingDataMessage: "No credit opportunities were returned.",
		status: result.status,
	})

	return {
		sortOptions: data.sortOptions ?? [],
		activityTypes: data.activityTypes ?? [],
		areasOfStudy: data.areasOfStudy ?? [],
		providers: data.providers ?? [],
		cpdActivities: Array.isArray(data.cpdActivities) ? data.cpdActivities : [],
		totalCount: data.totalCount ?? 0,
	}
}
