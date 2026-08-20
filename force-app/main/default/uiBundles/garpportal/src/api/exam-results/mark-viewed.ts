import { createDataSDK } from "@salesforce/platform-sdk"

import {
	AppError,
	normalizeHttpResponse,
	unwrapApiResult,
	unwrapMemberPortalEnvelope,
} from "@/api/client"
import type {
	ExamResultViewedResult,
	MemberPortalEnvelope,
} from "@/api/exam-results/types"

const EXAM_RESULT_VIEWED_PATH =
	"/services/apexrest/memberportal/examResultViewed"

/**
 * Stamps `Results_Viewed_Date__c` so "new result" markers clear elsewhere.
 * Fire-and-forget from the listing — failures must not block the page.
 */
export async function markExamResultViewed(
	examAttemptId: string,
): Promise<ExamResultViewedResult> {
	const id = examAttemptId.trim()
	if (!id) {
		throw new AppError({
			messages: ["An exam attempt id is required."],
			status: 400,
		})
	}

	const sdk = await createDataSDK()
	const response = await sdk.fetch?.(EXAM_RESULT_VIEWED_PATH, {
		method: "POST",
		headers: {
			"Content-Type": "application/json",
			Accept: "application/json",
		},
		body: JSON.stringify({ examAttemptId: id }),
	})

	const result = await normalizeHttpResponse<
		MemberPortalEnvelope<ExamResultViewedResult>
	>(response, {
		unreachableMessage: "Unable to reach the exam results service.",
		fallbackErrorMessage:
			"Unable to mark this exam result as viewed.",
	})

	const envelope = unwrapApiResult(result)

	const data = unwrapMemberPortalEnvelope(envelope, {
		fallbackErrorMessage: "Unable to mark this exam result as viewed.",
		missingDataMessage: "No view-result payload was returned.",
		status: result.status,
	})

	if (data.statusCode != null && data.statusCode !== 200) {
		throw new AppError({
			messages: [
				data.statusMessage?.trim() ||
					"Unable to mark this exam result as viewed.",
			],
			status: data.statusCode,
		})
	}

	return data
}
