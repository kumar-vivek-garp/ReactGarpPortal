import { createDataSDK } from "@salesforce/platform-sdk"

import {
	normalizeHttpResponse,
	unwrapApiResult,
	unwrapMemberPortalEnvelope,
} from "@/api/client"
import type {
	DashboardView,
	MemberPortalEnvelope,
} from "@/api/dashboard/types"

const DASHBOARD_PATH = "/services/apexrest/memberportal/dashboard"

/**
 * Loads identity, completeness, and ranked dashboard cards from Apex
 * `GARP_MemberPortal_API` (dashboard action).
 */
export async function fetchDashboard(): Promise<DashboardView> {
	const sdk = await createDataSDK()
	const response = await sdk.fetch?.(DASHBOARD_PATH, {
		method: "GET",
		headers: { Accept: "application/json" },
	})

	const result = await normalizeHttpResponse<
		MemberPortalEnvelope<DashboardView>
	>(response, {
		unreachableMessage: "Unable to reach the dashboard service.",
		fallbackErrorMessage: "Unable to load the dashboard. Please try again.",
	})

	const envelope = unwrapApiResult(result)

	return unwrapMemberPortalEnvelope(envelope, {
		fallbackErrorMessage: "Unable to load the dashboard.",
		missingDataMessage: "No dashboard data was returned.",
		status: result.status,
	})
}
