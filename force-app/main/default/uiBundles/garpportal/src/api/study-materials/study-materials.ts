import { createDataSDK } from "@salesforce/platform-sdk"

import {
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

const STUDY_MATERIALS_PATH = "/services/apexrest/memberportal/studyMaterials"

/**
 * Loads study materials from Apex `GARP_Portal_API` (studyMaterials action).
 * Maps legacy `studyMaterialsInfo` buckets into the React panel model.
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

	const envelope = unwrapApiResult(result)

	const data = unwrapMemberPortalEnvelope(envelope, {
		fallbackErrorMessage: "Unable to load study materials.",
		missingDataMessage: "No study materials data was returned.",
		status: result.status,
	})

	return normalizeStudyMaterialsPayload(data)
}
