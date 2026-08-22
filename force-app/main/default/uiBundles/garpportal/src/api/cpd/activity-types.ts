import { createDataSDK } from "@salesforce/platform-sdk"

import {
	normalizeHttpResponse,
	unwrapApiResult,
	unwrapMemberPortalEnvelope,
} from "@/api/client"
import type {
	CpdActivityFieldInfo,
	MemberPortalEnvelope,
} from "@/api/cpd/types"

const CPD_ACTIVITY_TYPES_PATH =
	"/services/apexrest/memberportal/cpdActivityTypes"

/**
 * Activity types for the Add Credits form, from Apex `GARP_Portal_API`
 * (`cpdActivityTypes` action) — a port of `getCPDActivityFieldInfo`.
 */
export async function fetchCpdActivityTypes(): Promise<CpdActivityFieldInfo[]> {
	const sdk = await createDataSDK()
	const response = await sdk.fetch?.(CPD_ACTIVITY_TYPES_PATH, {
		method: "GET",
		headers: { Accept: "application/json" },
	})

	const result = await normalizeHttpResponse<
		MemberPortalEnvelope<CpdActivityFieldInfo[]>
	>(response, {
		unreachableMessage: "Unable to reach the CPD service.",
		fallbackErrorMessage: "Unable to load activity types. Please try again.",
	})

	const envelope = unwrapApiResult(result)

	const data = unwrapMemberPortalEnvelope(envelope, {
		fallbackErrorMessage: "Unable to load activity types.",
		missingDataMessage: "No activity types were returned.",
		status: result.status,
	})

	return Array.isArray(data) ? data : []
}
