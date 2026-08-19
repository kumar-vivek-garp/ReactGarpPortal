import { createDataSDK } from "@salesforce/platform-sdk"

import {
	AppError,
	normalizeHttpResponse,
	unwrapApiResult,
	unwrapMemberPortalEnvelope,
} from "@/api/client"
import type {
	CaseSummary,
	MemberPortalEnvelope,
} from "@/api/help-center/types"

const CASES_PATH = "/services/apexrest/memberportal/cases"

/**
 * Loads the signed-in member's support cases from Apex `GARP_Portal_API`
 * (`cases` action). Contact is bound server-side from the session.
 */
export async function fetchCases(): Promise<CaseSummary[]> {
	const sdk = await createDataSDK()
	const response = await sdk.fetch?.(CASES_PATH, {
		method: "GET",
		headers: { Accept: "application/json" },
	})

	const result = await normalizeHttpResponse<
		MemberPortalEnvelope<CaseSummary[]>
	>(response, {
		unreachableMessage: "Unable to reach the help center service.",
		fallbackErrorMessage: "Unable to load your requests. Please try again.",
	})

	const envelope = unwrapApiResult(result)

	const data = unwrapMemberPortalEnvelope(envelope, {
		fallbackErrorMessage: "Unable to load your requests.",
		missingDataMessage: "No request list was returned.",
		status: result.status,
	})

	if (!Array.isArray(data)) {
		throw new AppError({
			messages: ["No request list was returned."],
			status: result.status,
		})
	}

	return data
}
