import { createDataSDK } from "@salesforce/platform-sdk"

import {
	AppError,
	normalizeHttpResponse,
	unwrapApiResult,
	unwrapMemberPortalEnvelope,
} from "@/api/client"
import type {
	ExamSetupAuthorizeResult,
	ExamSetupProgramType,
	MemberPortalEnvelope,
} from "@/api/exam-setup/types"

const EXAM_SETUP_AUTHORIZE_PATH =
	"/services/apexrest/memberportal/examSetupAuthorize"

/**
 * Pushes the registration to the exam provider and hands back scheduling links.
 *
 * **This is an outbound integration**, not a portal write:
 * `ExamRegistrationsStatusCls.updateRegistration` talks to Pearson / PSI / ATA.
 * Calling it from a sandbox reaches the real provider, which is why
 * `EXAM_SETUP_AUTHORIZE_ENABLED` gates every call site until the backend team
 * confirms that is safe.
 *
 * `isRetry` exists because the provider can answer "unprocessed" — the caller
 * polls with it rather than treating the first answer as final.
 */
export async function authorizeExamSetup(args: {
	programType: ExamSetupProgramType
	isRetry?: boolean
}): Promise<ExamSetupAuthorizeResult> {
	const sdk = await createDataSDK()
	const response = await sdk.fetch?.(EXAM_SETUP_AUTHORIZE_PATH, {
		method: "POST",
		headers: { "Content-Type": "application/json", Accept: "application/json" },
		body: JSON.stringify({
			programType: args.programType,
			isRetry: args.isRetry === true,
		}),
	})

	const result = await normalizeHttpResponse<
		MemberPortalEnvelope<ExamSetupAuthorizeResult>
	>(response, {
		unreachableMessage: "Unable to reach the exam scheduling service.",
		fallbackErrorMessage:
			"Unable to authorize your exam scheduling. Please try again.",
	})

	const envelope = unwrapApiResult(result)

	const data = unwrapMemberPortalEnvelope(envelope, {
		fallbackErrorMessage: "Unable to authorize your exam scheduling.",
		missingDataMessage: "No authorization data was returned.",
		status: result.status,
	})

	if (data.statusCode !== 200) {
		throw new AppError({
			messages: [
				data.statusMessage ?? "Unable to authorize your exam scheduling.",
			],
			status: data.statusCode,
		})
	}

	return data
}
