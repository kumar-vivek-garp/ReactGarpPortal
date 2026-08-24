import { createDataSDK } from "@salesforce/platform-sdk"

import {
	AppError,
	normalizeHttpResponse,
	unwrapApiResult,
	unwrapMemberPortalEnvelope,
} from "@/api/client"
import type {
	ExamSetupProgramType,
	ExamSetupView,
	MemberPortalEnvelope,
} from "@/api/exam-setup/types"

const EXAM_SETUP_PATH = "/services/apexrest/memberportal/examSetup"

/**
 * The wizard's form, from `GARP_Portal_ExamSetupService.form`.
 *
 * One administration list per exam part, each carrying the sites open under
 * it, plus the ID step's fields already filled in. `isSelected` on both marks
 * where the member sits today — that is what makes the fee gate decidable
 * without a server round trip.
 *
 * Apex's own refusals arrive as a populated `data` with a non-200
 * `statusCode`, so they are lifted into an `AppError` carrying the server's
 * sentence rather than a generic one. The three that matter:
 *
 *   501  the programme has no exam setup
 *   502  an unpaid reschedule order already exists — offering the form again
 *        would raise a second one
 *   401 / 403  the membership gate
 *
 * The caller distinguishes them by `status`; see `examSetupRefusal`.
 */
export async function fetchExamSetupForm(
	programType: ExamSetupProgramType,
): Promise<ExamSetupView> {
	const sdk = await createDataSDK()
	const path = `${EXAM_SETUP_PATH}?programType=${encodeURIComponent(programType)}`
	const response = await sdk.fetch?.(path, {
		method: "GET",
		headers: { Accept: "application/json" },
	})

	const result = await normalizeHttpResponse<
		MemberPortalEnvelope<ExamSetupView>
	>(response, {
		unreachableMessage: "Unable to reach the exam setup service.",
		fallbackErrorMessage: "Unable to load exam setup. Please try again.",
	})

	const envelope = unwrapApiResult(result)

	const data = unwrapMemberPortalEnvelope(envelope, {
		fallbackErrorMessage: "Unable to load exam setup.",
		missingDataMessage: "No exam setup data was returned.",
		status: result.status,
	})

	if (data.statusCode !== 200) {
		throw new AppError({
			messages: [data.statusMessage ?? "Unable to load exam setup."],
			status: data.statusCode,
		})
	}

	return {
		...data,
		examPart1SelectionInfo: Array.isArray(data.examPart1SelectionInfo)
			? data.examPart1SelectionInfo
			: [],
		examPart2SelectionInfo: Array.isArray(data.examPart2SelectionInfo)
			? data.examPart2SelectionInfo
			: [],
	}
}
