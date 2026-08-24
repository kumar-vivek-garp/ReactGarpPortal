import { createDataSDK } from "@salesforce/platform-sdk"

import {
	AppError,
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
 * Apex takes both halves together (`saveIdInfo(programType, id, selection)`),
 * which is why this is one page and not the legacy's two screens — nothing on
 * the ID step depends on what was chosen for the sitting.
 *
 * When the selection changed, Apex raises an
 * `Exam_Registration_Modification__c` as a side effect and returns its id. A
 * fee-incurring selection must therefore be stopped BEFORE this call, not
 * after: a modification raised here and then abandoned would sit Pending and
 * the legacy wizard would raise a second one against the same sitting.
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

	const envelope = unwrapApiResult(result)

	const data = unwrapMemberPortalEnvelope(envelope, {
		fallbackErrorMessage: "Unable to save your exam setup.",
		missingDataMessage: "No response was returned.",
		status: result.status,
	})

	if (data.statusCode !== 200) {
		throw new AppError({
			messages: [data.statusMessage ?? "Unable to save your exam setup."],
			status: data.statusCode,
		})
	}

	return data
}
