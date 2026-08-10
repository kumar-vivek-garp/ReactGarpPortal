import { createDataSDK } from "@salesforce/platform-sdk"

import {
	AppError,
	normalizeHttpResponse,
	unwrapApiResult,
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

	if (!envelope.ok) {
		throw new AppError({
			messages: [envelope.error ?? "Unable to load the dashboard."],
			status: result.status,
		})
	}

	if (!envelope.data) {
		throw new AppError({
			messages: ["No dashboard data was returned."],
			status: result.status,
		})
	}

	return envelope.data
}
