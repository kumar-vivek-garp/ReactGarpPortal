import { createDataSDK } from "@salesforce/platform-sdk"

import {
	AppError,
	normalizeHttpResponse,
	unwrapApiResult,
	unwrapMemberPortalEnvelope,
} from "@/api/client"
import type {
	MemberPortalEnvelope,
	SaveAccountProfileResult,
} from "@/api/account/types"

const PROFILE_PATH = "/services/apexrest/memberportal/profile"

export type AccountProfileValues = Record<string, string | boolean | null>

/**
 * Saves allow-listed Contact fields via Apex `GARP_Portal_ProfileService`.
 */
export async function saveAccountProfile(
	values: AccountProfileValues,
): Promise<SaveAccountProfileResult> {
	const sdk = await createDataSDK()
	const response = await sdk.fetch?.(PROFILE_PATH, {
		method: "POST",
		headers: {
			"Content-Type": "application/json",
			Accept: "application/json",
		},
		body: JSON.stringify({ values }),
	})

	const result = await normalizeHttpResponse<
		MemberPortalEnvelope<SaveAccountProfileResult>
	>(response, {
		unreachableMessage: "Unable to reach the profile service.",
		fallbackErrorMessage: "Unable to save career information. Please try again.",
	})

	const envelope = unwrapApiResult(result)
	const data = unwrapMemberPortalEnvelope(envelope, {
		fallbackErrorMessage: "Unable to save career information.",
		missingDataMessage: "No save result was returned.",
		status: result.status,
	})

	const rejected = data.rejected ?? []
	if (rejected.length > 0) {
		throw new AppError({
			messages: [
				`These fields could not be saved: ${rejected.join(", ")}.`,
			],
			status: result.status,
		})
	}

	return data
}
