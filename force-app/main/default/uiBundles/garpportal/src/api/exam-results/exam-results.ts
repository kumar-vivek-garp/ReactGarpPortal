import { createDataSDK } from "@salesforce/platform-sdk"

import {
	normalizeHttpResponse,
	unwrapApiResult,
	unwrapMemberPortalEnvelope,
} from "@/api/client"
import type {
	ExamResult,
	MemberPortalEnvelope,
} from "@/api/exam-results/types"

const EXAM_RESULTS_PATH = "/services/apexrest/memberportal/examResults"

/**
 * Loads the member's exam attempts from Apex `GARP_Portal_API`
 * (`examResults` action). Returns a bare list under the envelope `data`.
 */
export async function fetchExamResults(): Promise<ExamResult[]> {
	const sdk = await createDataSDK()
	const response = await sdk.fetch?.(EXAM_RESULTS_PATH, {
		method: "GET",
		headers: { Accept: "application/json" },
	})

	const result = await normalizeHttpResponse<
		MemberPortalEnvelope<ExamResult[]>
	>(response, {
		unreachableMessage: "Unable to reach the exam results service.",
		fallbackErrorMessage:
			"Unable to load exam results. Please try again.",
	})

	const envelope = unwrapApiResult(result)

	const data = unwrapMemberPortalEnvelope(envelope, {
		fallbackErrorMessage: "Unable to load exam results.",
		missingDataMessage: "No exam results were returned.",
		status: result.status,
	})

	return Array.isArray(data) ? data : []
}
