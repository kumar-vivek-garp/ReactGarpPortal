import { createDataSDK } from "@salesforce/platform-sdk"

import {
	AppError,
	normalizeHttpResponse,
	unwrapApiResult,
} from "@/api/client"
import type {
	MemberPortalEnvelope,
	StudyMaterialsView,
} from "@/api/study-materials/types"

const STUDY_MATERIALS_PATH = "/services/apexrest/memberportal/studyMaterials"

/**
 * Loads study materials catalogue + entitlements from Apex
 * `GARP_MemberPortal_API` (studyMaterials action).
 * Unwraps `{ ok, data }` / `{ ok, error }` into `StudyMaterialsView` or throws `AppError`.
 */
export async function fetchStudyMaterials(): Promise<StudyMaterialsView> {
	const sdk = await createDataSDK()
	const response = await sdk.fetch?.(STUDY_MATERIALS_PATH, {
		method: "GET",
		headers: { Accept: "application/json" },
	})

	const result = await normalizeHttpResponse<
		MemberPortalEnvelope<StudyMaterialsView>
	>(response, {
		unreachableMessage: "Unable to reach the study materials service.",
		fallbackErrorMessage: "Unable to load study materials. Please try again.",
	})

	const envelope = unwrapApiResult(result)

	if (!envelope.ok) {
		throw new AppError({
			messages: [envelope.error ?? "Unable to load study materials."],
			status: result.status,
		})
	}

	if (!envelope.data) {
		throw new AppError({
			messages: ["No study materials data was returned."],
			status: result.status,
		})
	}

	return envelope.data
}
