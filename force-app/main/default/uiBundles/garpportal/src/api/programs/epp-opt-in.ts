import { createDataSDK } from "@salesforce/platform-sdk"

import {
	AppError,
	normalizeHttpResponse,
	unwrapApiResult,
	unwrapMemberPortalEnvelope,
} from "@/api/client"
import type {
	EppExamType,
	EppOptInResult,
	MemberPortalEnvelope,
} from "@/api/programs/types"

const EPP_OPT_IN_PATH = "/services/apexrest/memberportal/eppOptIn"

const EPP_EXAM_TYPES: ReadonlySet<string> = new Set<EppExamType>([
	"frm",
	"scr",
	"riskai",
	"raij",
])

/**
 * The key Apex stamps the answer against, or `null` for a programme that has
 * no exam attempt to stamp (ERP, the courses) — those get no opt-in at all
 * rather than a 501 after the click. `rai` is the marketing alias of `riskai`.
 */
export function toEppExamType(
	programType: string | null | undefined,
): EppExamType | null {
	const slug = programType?.trim().toLowerCase() ?? ""
	const key = slug === "rai" ? "riskai" : slug
	return EPP_EXAM_TYPES.has(key) ? (key as EppExamType) : null
}

export type EppOptInInput = {
	examType: EppExamType
	optIn: boolean
}

/**
 * Records whether GARP may pass the member's details to exam-prep providers
 * (`GARP_Portal_EppOptInService.save`). Either answer stamps the attempt as
 * asked; only a Yes flags the Contact.
 */
export async function saveEppOptIn(
	input: EppOptInInput,
): Promise<EppOptInResult> {
	const sdk = await createDataSDK()
	const response = await sdk.fetch?.(EPP_OPT_IN_PATH, {
		method: "POST",
		headers: {
			"Content-Type": "application/json",
			Accept: "application/json",
		},
		body: JSON.stringify({ examType: input.examType, optIn: input.optIn }),
	})

	const result = await normalizeHttpResponse<
		MemberPortalEnvelope<EppOptInResult>
	>(response, {
		unreachableMessage: "Unable to reach the exam-prep service.",
		fallbackErrorMessage: "Unable to record your answer. Please try again.",
	})

	const envelope = unwrapApiResult(result)
	const data = unwrapMemberPortalEnvelope(envelope, {
		fallbackErrorMessage: "Unable to record your answer.",
		missingDataMessage: "No opt-in result was returned.",
		status: result.status,
	})

	if (data.statusCode !== 200) {
		throw new AppError({
			messages: [data.statusMessage?.trim() || "Unable to record your answer."],
			status: data.statusCode ?? result.status,
		})
	}

	return data
}
