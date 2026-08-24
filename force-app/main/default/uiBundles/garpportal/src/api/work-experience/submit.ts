import { createDataSDK } from "@salesforce/platform-sdk"

import {
	AppError,
	normalizeHttpResponse,
	unwrapApiResult,
	unwrapMemberPortalEnvelope,
} from "@/api/client"
import type {
	CvExperienceResult,
	CvProgramType,
	MemberPortalEnvelope,
} from "@/api/work-experience/types"

const CV_SUBMIT_PATH = "/services/apexrest/memberportal/cvSubmit"

/**
 * Sends the CV to GARP for review (`cvSubmit`) — flips the Job_Experience
 * requirement to "Ready For Review".
 *
 * Apex re-checks the months itself and answers **501** with "Work Experience is
 * not more than the required 24 months" if they fall short. That check runs
 * against `totalTimeAllotted`, while the page's Submit button is gated on
 * `isValidExperienceSubmission` — the two are computed differently, so a 501
 * here is a real possibility even from a page that offered the button, and it
 * must surface rather than being swallowed as a generic failure.
 *
 * It does **not** check the address. Nothing server-side stops a member
 * submitting with nowhere to post the certificate, so that gate is ours.
 */
export async function submitCv(
	programType: CvProgramType,
): Promise<CvExperienceResult> {
	const sdk = await createDataSDK()
	const response = await sdk.fetch?.(CV_SUBMIT_PATH, {
		method: "POST",
		headers: { "Content-Type": "application/json", Accept: "application/json" },
		body: JSON.stringify({ programType }),
	})

	const result = await normalizeHttpResponse<
		MemberPortalEnvelope<CvExperienceResult>
	>(response, {
		unreachableMessage: "Unable to reach the work experience service.",
		fallbackErrorMessage: "Your work experience could not be submitted.",
	})

	const data = unwrapMemberPortalEnvelope(unwrapApiResult(result), {
		fallbackErrorMessage: "Your work experience could not be submitted.",
		missingDataMessage: "No response was returned.",
		status: result.status,
	})

	if (data.statusCode !== 200) {
		throw new AppError({
			messages: [
				data.statusMessage?.trim() ||
					"Your work experience could not be submitted.",
			],
			status: data.statusCode,
		})
	}

	return data
}
