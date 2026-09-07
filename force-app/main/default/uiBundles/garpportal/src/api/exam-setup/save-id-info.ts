import { createDataSDK } from "@salesforce/platform-sdk"

import {
	memberPortalRefusalPayload,
	normalizeHttpResponse,
	unwrapApiResult,
	unwrapMemberPortalEnvelope,
} from "@/api/client"
import type {
	ExamSetupIdInput,
	ExamSetupIdSaveResult,
	ExamSetupProgramType,
	ExamSetupSelectionInput,
	MemberPortalEnvelope,
} from "@/api/exam-setup/types"

const EXAM_SETUP_ID_PATH = "/services/apexrest/memberportal/examSetupId"

/**
 * Saves the ID details AND the sitting in one call.
 *
 * Apex takes both halves together (`saveIdInfo(programType, id, selection)`).
 *
 * **A refusal is returned, not thrown**, for the same reason as the read — and
 * here it matters more. Every deferral rule lives on this response:
 * "You can only defer your exam registration once", "Part II cannot be taken
 * before Part I", "Exam changes are currently not allowed". Those are sentences
 * the member has to act on, so they belong in the banner against the step that
 * can fix them, not in a toast. The caller checks `statusCode` before treating
 * the result as a success.
 *
 * When the selection changed, Apex raises an `Exam_Registration_Modification__c`
 * as a side effect and returns its id. It does that on **every** call with no
 * dedupe, so this must not be retried automatically.
 */
export async function saveExamSetupId(args: {
	programType: ExamSetupProgramType
	id: ExamSetupIdInput
	selection: ExamSetupSelectionInput
}): Promise<ExamSetupIdSaveResult> {
	const sdk = await createDataSDK()
	const response = await sdk.fetch?.(EXAM_SETUP_ID_PATH, {
		method: "POST",
		headers: { "Content-Type": "application/json", Accept: "application/json" },
		body: JSON.stringify({
			programType: args.programType,
			id: args.id,
			selection: args.selection,
		}),
	})

	const result = await normalizeHttpResponse<
		MemberPortalEnvelope<ExamSetupIdSaveResult>
	>(response, {
		unreachableMessage: "Unable to reach the exam setup service.",
		fallbackErrorMessage: "Unable to save your exam setup. Please try again.",
	})

	const refusal = memberPortalRefusalPayload<ExamSetupIdSaveResult>(result)
	if (refusal) return refusal

	const envelope = unwrapApiResult(result)

	return unwrapMemberPortalEnvelope(envelope, {
		fallbackErrorMessage: "Unable to save your exam setup.",
		missingDataMessage: "No response was returned.",
		status: result.status,
	})
}
