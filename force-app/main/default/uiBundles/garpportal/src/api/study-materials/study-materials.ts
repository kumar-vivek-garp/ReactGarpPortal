import { createDataSDK } from "@salesforce/platform-sdk"

import {
	AppError,
	memberPortalRefusalPayload,
	normalizeHttpResponse,
	unwrapApiResult,
	unwrapMemberPortalEnvelope,
} from "@/api/client"
import { normalizeStudyMaterialsPayload } from "@/api/study-materials/normalize"
import type {
	ApexStudyMaterialsPayload,
	MemberPortalEnvelope,
	StudyMaterialsView,
} from "@/api/study-materials/types"

export const STUDY_MATERIALS_PATH =
	"/services/apexrest/memberportal/studyMaterials"

/** `GARP_Portal_Access.verify` answers with one of these when there is no contract. */
function isAccessDenied(status: number | null | undefined): boolean {
	return status === 401 || status === 403
}

/**
 * Loads study materials from Apex `GARP_Portal_API` (studyMaterials action).
 *
 * A member without a membership contract is refused — HTTP 401/403 with
 * "Portal Access Denied" and the payload still present. That is the service
 * answering, not failing, so it resolves as a `denied` view the page renders
 * rather than an error it toasts. A 401/403 with an EMPTY body is a real
 * access problem (an expired session) and still throws — see
 * `memberPortalRefusalPayload`.
 */
export async function fetchStudyMaterials(): Promise<StudyMaterialsView> {
	const sdk = await createDataSDK()
	const response = await sdk.fetch?.(STUDY_MATERIALS_PATH, {
		method: "GET",
		headers: { Accept: "application/json" },
	})

	const result = await normalizeHttpResponse<
		MemberPortalEnvelope<ApexStudyMaterialsPayload>
	>(response, {
		unreachableMessage: "Unable to reach the study materials service.",
		fallbackErrorMessage: "Unable to load study materials. Please try again.",
	})

	if (!result.ok && isAccessDenied(result.status)) {
		const refusal = memberPortalRefusalPayload<ApexStudyMaterialsPayload>(result)
		if (refusal) {
			return {
				kind: "denied",
				statusCode: result.status,
				message: refusal.statusMessage ?? null,
			}
		}
	}

	const data = unwrapMemberPortalEnvelope(unwrapApiResult(result), {
		fallbackErrorMessage: "Unable to load study materials.",
		missingDataMessage: "No study materials data was returned.",
		status: result.status,
	})

	// The same refusal, should the router ever mirror it as HTTP 200.
	if (isAccessDenied(data.statusCode)) {
		return {
			kind: "denied",
			statusCode: data.statusCode ?? 403,
			message: data.statusMessage ?? null,
		}
	}

	if (data.statusCode != null && data.statusCode !== 200) {
		throw new AppError({
			messages: [data.statusMessage ?? "Unable to load study materials."],
			status: data.statusCode,
		})
	}

	return { kind: "ok", programs: normalizeStudyMaterialsPayload(data) }
}
