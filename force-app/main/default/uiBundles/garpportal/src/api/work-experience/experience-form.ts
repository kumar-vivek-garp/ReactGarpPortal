import { createDataSDK } from "@salesforce/platform-sdk"

import {
	AppError,
	normalizeHttpResponse,
	unwrapApiResult,
	unwrapMemberPortalEnvelope,
} from "@/api/client"
import type {
	CvProgramType,
	ExperienceFormView,
	MemberPortalEnvelope,
} from "@/api/work-experience/types"

const CV_EXPERIENCE_PATH = "/services/apexrest/memberportal/cvExperience"

/**
 * One experience plus the four picklists the form binds to
 * (`GARP_Portal_CvService.experience`).
 *
 * A blank `experienceId` is the Add form: the deployed class answers 200 with
 * an all-null `workExperience` and the populated picklists. That is specific to
 * the GarpAppv1 copy of the service — MyGarp's older one 401s instead — and is
 * why the options are fetched rather than hard-coded client-side.
 *
 * `workExperience.attachmentCount` is always 0 on this path; the service never
 * calls `applyAttachmentCounts` here. Read `hasAttachments` instead.
 */
export async function fetchExperienceForm(
	programType: CvProgramType,
	experienceId?: string | null,
): Promise<ExperienceFormView> {
	const sdk = await createDataSDK()
	const params = new URLSearchParams({ programType })
	const key = experienceId?.trim()
	if (key) params.set("experienceId", key)

	const response = await sdk.fetch?.(`${CV_EXPERIENCE_PATH}?${params}`, {
		method: "GET",
		headers: { Accept: "application/json" },
	})

	const result = await normalizeHttpResponse<
		MemberPortalEnvelope<ExperienceFormView>
	>(response, {
		unreachableMessage: "Unable to reach the work experience service.",
		fallbackErrorMessage: "Unable to open this experience. Please try again.",
	})

	const envelope = unwrapApiResult(result)

	const data = unwrapMemberPortalEnvelope(envelope, {
		fallbackErrorMessage: "Unable to open this experience.",
		missingDataMessage: "No experience data was returned.",
		status: result.status,
	})

	if (data.statusCode !== 200) {
		throw new AppError({
			messages: [data.statusMessage ?? "Unable to open this experience."],
			status: data.statusCode,
		})
	}

	// Every picklist is optional on the wire; the form maps over all four.
	return {
		...data,
		jobFunctions: Array.isArray(data.jobFunctions) ? data.jobFunctions : [],
		riskSpecialties: Array.isArray(data.riskSpecialties)
			? data.riskSpecialties
			: [],
		jobTypes: Array.isArray(data.jobTypes) ? data.jobTypes : [],
		educationalRoles: Array.isArray(data.educationalRoles)
			? data.educationalRoles
			: [],
	}
}
