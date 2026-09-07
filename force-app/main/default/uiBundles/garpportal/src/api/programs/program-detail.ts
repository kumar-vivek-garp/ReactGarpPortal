import { createDataSDK } from "@salesforce/platform-sdk"

import {
	AppError,
	normalizeHttpResponse,
	unwrapApiResult,
	unwrapMemberPortalEnvelope,
} from "@/api/client"
import type {
	MemberPortalEnvelope,
	ProgramDetailView,
} from "@/api/programs/types"

const PROGRAM_DETAIL_PATH = "/services/apexrest/memberportal/programDetail"

/**
 * Loads read-only program detail from Apex `GARP_Portal_API`
 * (`programDetail` action).
 */
export async function fetchProgramDetail(
	programType: string,
): Promise<ProgramDetailView> {
	const slug = programType.trim()
	if (!slug) {
		throw new AppError({
			messages: ["A program type is required."],
			status: 400,
		})
	}

	const sdk = await createDataSDK()
	const path = `${PROGRAM_DETAIL_PATH}?programType=${encodeURIComponent(slug)}`
	const response = await sdk.fetch?.(path, {
		method: "GET",
		headers: { Accept: "application/json" },
	})

	const result = await normalizeHttpResponse<
		MemberPortalEnvelope<ProgramDetailView>
	>(response, {
		unreachableMessage: "Unable to reach the program detail service.",
		fallbackErrorMessage:
			"Unable to load program details. Please try again.",
	})

	const envelope = unwrapApiResult(result)

	const data = unwrapMemberPortalEnvelope(envelope, {
		fallbackErrorMessage: "Unable to load program details.",
		missingDataMessage: "No program detail data was returned.",
		status: result.status,
	})

	if (data.statusCode !== 200) {
		const serverMessage = data.statusMessage?.trim()
		// 401 here is the service's "no contract for this programme", not an
		// auth failure — GarpAppv1 words it for the member. The server text is
		// kept behind it rather than dropped.
		const messages =
			data.statusCode === 401
				? [
						"You aren't enrolled in this program.",
						...(serverMessage ? [serverMessage] : []),
					]
				: [serverMessage || "Unable to load program details."]
		throw new AppError({ messages, status: data.statusCode })
	}

	return data
}
