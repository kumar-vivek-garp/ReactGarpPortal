import { createDataSDK } from "@salesforce/platform-sdk"

import {
	AppError,
	memberPortalRefusalPayload,
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
 * Prices a raised modification, for the "Pay Fees" outcome.
 *
 * Called only after `examSetupId` has answered `nextScreen: "Pay Fees"` — the
 * `modificationId` it needs does not exist until that write has happened, which
 * is why fees cannot be shown while the member is still choosing.
 *
 * Returns lines only: no `orderId`, no checkout URL. Payment happens at the
 * legacy checkout (`examSetupFeesCheckoutHref`). A failure here is not fatal —
 * the caller shows the checkout link without the breakdown.
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

	const refusal = memberPortalRefusalPayload<ExamSetupFeesView>(result)
	if (refusal) {
		return { ...refusal, fees: Array.isArray(refusal.fees) ? refusal.fees : [] }
	}

	const envelope = unwrapApiResult(result)

	const data = unwrapMemberPortalEnvelope(envelope, {
		fallbackErrorMessage: "Unable to price your exam change.",
		missingDataMessage: "No fee data was returned.",
		status: result.status,
	})

	return { ...data, fees: Array.isArray(data.fees) ? data.fees : [] }
}
