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
	SubmitCaseInput,
} from "@/api/help-center/types"

const SUBMIT_CASE_PATH = "/services/apexrest/memberportal/submitCase"

/**
 * Raises a support case via Apex `GARP_MemberPortal_API` (submitCase).
 * Contact is bound server-side from the session.
 */
export async function submitCase(input: SubmitCaseInput): Promise<CaseSummary> {
	const subject = input.subject.trim()
	const description = input.description.trim()

	if (!subject) {
		throw new AppError({ messages: ["A subject is required."] })
	}
	if (!description) {
		throw new AppError({ messages: ["A description is required."] })
	}

	const sdk = await createDataSDK()
	const response = await sdk.fetch?.(SUBMIT_CASE_PATH, {
		method: "POST",
		headers: {
			"Content-Type": "application/json",
			Accept: "application/json",
		},
		body: JSON.stringify({ subject, description }),
	})

	const result = await normalizeHttpResponse<MemberPortalEnvelope<CaseSummary>>(
		response,
		{
			unreachableMessage: "Unable to reach the help center service.",
			fallbackErrorMessage: "Unable to submit your support case. Please try again.",
		},
	)

	const envelope = unwrapApiResult(result)

	return unwrapMemberPortalEnvelope(envelope, {
		fallbackErrorMessage: "Unable to submit your support case.",
		missingDataMessage: "No case confirmation was returned.",
		status: result.status,
	})
}
