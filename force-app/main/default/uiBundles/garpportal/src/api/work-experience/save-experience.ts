import { createDataSDK } from "@salesforce/platform-sdk"

import {
	AppError,
	normalizeHttpResponse,
	unwrapApiResult,
	unwrapMemberPortalEnvelope,
} from "@/api/client"
import type {
	CvExperienceInput,
	CvExperienceResult,
	CvProgramType,
	MemberPortalEnvelope,
} from "@/api/work-experience/types"

const CV_EXPERIENCE_PATH = "/services/apexrest/memberportal/cvExperience"
const CV_EXPERIENCE_DELETE_PATH =
	"/services/apexrest/memberportal/cvExperienceDelete"

/**
 * Posts one of the CV write actions.
 *
 * Unlike the CPD writes, these carry their own `statusCode`, so the router
 * answers a refusal with a real non-2xx AND lifts `statusMessage` into the
 * envelope's `errorMessage`. `normalizeHttpResponse` therefore already has the
 * server's own sentence and there is no HTTP-200-on-failure case to defend
 * against — the `statusCode` re-check below is for the 200-with-error shape
 * only, which the service does not currently produce but is free to.
 */
async function postCvWrite(
	path: string,
	body: unknown,
	messages: { unreachable: string; fallback: string },
): Promise<CvExperienceResult> {
	const sdk = await createDataSDK()
	const response = await sdk.fetch?.(path, {
		method: "POST",
		headers: { "Content-Type": "application/json", Accept: "application/json" },
		body: JSON.stringify(body),
	})

	const result = await normalizeHttpResponse<
		MemberPortalEnvelope<CvExperienceResult>
	>(response, {
		unreachableMessage: messages.unreachable,
		fallbackErrorMessage: messages.fallback,
	})

	const envelope = unwrapApiResult(result)

	const data = unwrapMemberPortalEnvelope(envelope, {
		fallbackErrorMessage: messages.fallback,
		missingDataMessage: "No response was returned.",
		status: result.status,
	})

	if (data.statusCode !== 200) {
		throw new AppError({
			messages: [data.statusMessage?.trim() || messages.fallback],
			status: data.statusCode,
		})
	}

	return data
}

/**
 * Creates or updates one logged role (`cvExperience`).
 *
 * `input` MUST come from `toExperienceInput()`. Apex deserializes the
 * `experience` member with a typed `JSON.deserialize`, so a single key it does
 * not declare — `programRequirement`, `timeAllotted`, `attachmentCount`, or
 * anything else echoed back off a read — throws inside the router and the
 * request dies as an opaque HTTP 500 carrying no message at all.
 *
 * Apex resolves the row against the signed-in member's Contact before touching
 * it, so an id belonging to someone else is refused (401), not rewritten.
 */
export async function saveExperience(
	programType: CvProgramType,
	input: CvExperienceInput,
): Promise<CvExperienceResult> {
	if (!input.startDateMonth || !input.startDateYear) {
		throw new AppError({
			messages: ["A start month and year are required."],
			status: 400,
		})
	}
	if (!input.isCurrentPosition && (!input.endDateMonth || !input.endDateYear)) {
		throw new AppError({
			messages: ["An end month and year are required."],
			status: 400,
		})
	}

	return postCvWrite(
		CV_EXPERIENCE_PATH,
		{ programType, experience: input },
		{
			unreachable: "Unable to reach the work experience service.",
			fallback: "This experience could not be saved.",
		},
	)
}

/** Removes one of the member's own logged roles (`cvExperienceDelete`). */
export async function deleteExperience(
	experienceId: string,
): Promise<CvExperienceResult> {
	const key = experienceId.trim()
	if (!key) {
		throw new AppError({
			messages: ["An experience id is required."],
			status: 400,
		})
	}

	return postCvWrite(
		CV_EXPERIENCE_DELETE_PATH,
		{ experienceId: key },
		{
			unreachable: "Unable to reach the work experience service.",
			fallback: "This experience could not be removed.",
		},
	)
}
