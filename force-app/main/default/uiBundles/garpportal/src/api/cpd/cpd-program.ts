import { createDataSDK } from "@salesforce/platform-sdk"

import {
	normalizeHttpResponse,
	unwrapApiResult,
	unwrapMemberPortalEnvelope,
} from "@/api/client"
import type { CpdProgramView, MemberPortalEnvelope } from "@/api/cpd/types"

const CPD_PROGRAM_PATH = "/services/apexrest/memberportal/cpdProgram"

/**
 * Loads every CPD cycle with its credits and claims from Apex
 * `GARP_Portal_API` (`cpdProgram` action).
 *
 * `CpdProgramView` carries no `statusCode` of its own, so this action always
 * answers 200 — a member with no CPE contract comes back with an empty
 * `cycles` array rather than an error, and the page renders its empty state.
 */
export async function fetchCpdProgram(): Promise<CpdProgramView> {
	const sdk = await createDataSDK()
	const response = await sdk.fetch?.(CPD_PROGRAM_PATH, {
		method: "GET",
		headers: { Accept: "application/json" },
	})

	const result = await normalizeHttpResponse<
		MemberPortalEnvelope<CpdProgramView>
	>(response, {
		unreachableMessage: "Unable to reach the CPD service.",
		fallbackErrorMessage: "Unable to load CPD activities. Please try again.",
	})

	const envelope = unwrapApiResult(result)

	const data = unwrapMemberPortalEnvelope(envelope, {
		fallbackErrorMessage: "Unable to load CPD activities.",
		missingDataMessage: "No CPD data was returned.",
		status: result.status,
	})

	return {
		currentCycle: data.currentCycle ?? null,
		cycles: Array.isArray(data.cycles) ? data.cycles : [],
	}
}
