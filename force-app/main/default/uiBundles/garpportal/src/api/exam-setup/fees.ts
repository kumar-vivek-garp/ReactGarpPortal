import { createDataSDK } from "@salesforce/platform-sdk"

import {
	AppError,
	normalizeHttpResponse,
	unwrapApiResult,
	unwrapMemberPortalEnvelope,
} from "@/api/client"
import type {
	ExamSetupFeesView,
	MemberPortalEnvelope,
} from "@/api/exam-setup/types"

const EXAM_SETUP_FEES_PATH = "/services/apexrest/memberportal/examSetupFees"

/**
 * Prices a raised modification.
 *
 * **Written but not yet called.** It returns fee lines and nothing else — no
 * `orderId`, no checkout URL — and `examSetupAuthorize` refuses any sitting
 * whose Opportunity is not already `Closed`. The endpoint that raises that
 * Opportunity (the legacy's `createExamRescheduleFeesOrder`) was never ported,
 * so there is no way to pay what this quotes.
 *
 * Kept here, exercised by tests, and wired the moment that endpoint lands.
 * `predictFee` in `lib/exam-setup-presentation` covers the member-facing need
 * in the meantime, from the fixed literals Apex itself uses.
 */
export async function fetchExamSetupFees(
	modificationId: string,
): Promise<ExamSetupFeesView> {
	const trimmed = modificationId.trim()
	if (!trimmed) {
		throw new AppError({ messages: ["A modification id is required."] })
	}

	const sdk = await createDataSDK()
	const response = await sdk.fetch?.(EXAM_SETUP_FEES_PATH, {
		method: "POST",
		headers: { "Content-Type": "application/json", Accept: "application/json" },
		body: JSON.stringify({ modificationId: trimmed }),
	})

	const result = await normalizeHttpResponse<
		MemberPortalEnvelope<ExamSetupFeesView>
	>(response, {
		unreachableMessage: "Unable to reach the exam setup service.",
		fallbackErrorMessage: "Unable to price your exam change. Please try again.",
	})

	const envelope = unwrapApiResult(result)

	const data = unwrapMemberPortalEnvelope(envelope, {
		fallbackErrorMessage: "Unable to price your exam change.",
		missingDataMessage: "No fee data was returned.",
		status: result.status,
	})

	if (data.statusCode !== 200) {
		throw new AppError({
			messages: [data.statusMessage ?? "Unable to price your exam change."],
			status: data.statusCode,
		})
	}

	return { ...data, fees: Array.isArray(data.fees) ? data.fees : [] }
}
