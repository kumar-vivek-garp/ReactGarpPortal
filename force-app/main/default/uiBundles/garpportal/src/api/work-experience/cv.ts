import { createDataSDK } from "@salesforce/platform-sdk"

import {
	AppError,
	memberPortalRefusalPayload,
	normalizeHttpResponse,
	unwrapApiResult,
	unwrapMemberPortalEnvelope,
} from "@/api/client"
import type {
	CvProgramType,
	CvView,
	MemberPortalEnvelope,
} from "@/api/work-experience/types"

const CV_PATH = "/services/apexrest/memberportal/cv"

/**
 * The Work Experience page for one certification, from Apex
 * `GARP_Portal_CvService.build` (`cv` action).
 *
 * Resolves `null` — rather than throwing — when the member has no CV
 * requirement to answer. Apex says so with its own 401 ("Program Contract not
 * found" / "FRM CV Candidate Requirement not found") and still describes
 * itself in `data`, so this is a business answer, not a failure. A 401 with an
 * empty body is a real transport or session problem and still throws; see
 * `memberPortalRefusalPayload`.
 *
 * 403 ("Portal Access Denied" — not a member) is deliberately NOT caught.
 */
export async function fetchCv(
	programType: CvProgramType,
): Promise<CvView | null> {
	const sdk = await createDataSDK()
	const path = `${CV_PATH}?programType=${encodeURIComponent(programType)}`
	const response = await sdk.fetch?.(path, {
		method: "GET",
		headers: { Accept: "application/json" },
	})

	const result = await normalizeHttpResponse<MemberPortalEnvelope<CvView>>(
		response,
		{
			unreachableMessage: "Unable to reach the work experience service.",
			fallbackErrorMessage:
				"Unable to load your work experience. Please try again.",
		},
	)

	if (result.status === 401 && memberPortalRefusalPayload<CvView>(result)) {
		return null
	}

	const envelope = unwrapApiResult(result)

	const data = unwrapMemberPortalEnvelope(envelope, {
		fallbackErrorMessage: "Unable to load your work experience.",
		missingDataMessage: "No work experience data was returned.",
		status: result.status,
	})

	if (data.statusCode !== 200) {
		throw new AppError({
			messages: [data.statusMessage ?? "Unable to load your work experience."],
			status: data.statusCode,
		})
	}

	return {
		...data,
		workExperiences: Array.isArray(data.workExperiences)
			? data.workExperiences
			: [],
		totalTimeAllotted: data.totalTimeAllotted ?? 0,
		timeRequired: data.timeRequired ?? 0,
	}
}
