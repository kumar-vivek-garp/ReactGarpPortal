import { createDataSDK } from "@salesforce/platform-sdk"

import {
	memberPortalRefusalPayload,
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

/** Apex may answer with `null` for a part it has nothing to offer. */
function normalizeView(data: ExamSetupView): ExamSetupView {
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

/**
 * The wizard's form, from `GARP_Portal_ExamSetupService.form`.
 *
 * One administration list per exam part, each carrying the sites open under
 * it, plus the ID step's fields already filled in. `isSelected` on both marks
 * where the member sits today.
 *
 * **A refusal is returned, not thrown.** Apex answers its own refusals with a
 * populated `data` and a non-200 `statusCode`, and the envelope lifts that code
 * onto the HTTP status — so `memberPortalRefusalPayload` is what tells a
 * refusal apart from a request that never ran. The three that matter:
 *
 *   501  the programme has no exam setup
 *   502  an unpaid reschedule order already exists
 *   401 / 403  the membership gate
 *
 * The panel branches on `statusCode` via `examSetupViewState`. Throwing here
 * instead — which is what this function used to do — collapsed all three into
 * one generic "unavailable" screen and left the 502 copy unreachable.
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

	// A refusal carries the payload the screen needs. No payload means the
	// request never ran — fall through and throw.
	const refusal = memberPortalRefusalPayload<ExamSetupView>(result)
	if (refusal) return normalizeView(refusal)

	const envelope = unwrapApiResult(result)

	const data = unwrapMemberPortalEnvelope(envelope, {
		fallbackErrorMessage: "Unable to load exam setup.",
		missingDataMessage: "No exam setup data was returned.",
		status: result.status,
	})

	return normalizeView(data)
}
