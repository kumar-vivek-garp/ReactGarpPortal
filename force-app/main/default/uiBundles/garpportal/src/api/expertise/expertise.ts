import { createDataSDK } from "@salesforce/platform-sdk"

import {
	AppError,
	normalizeHttpResponse,
	unwrapApiResult,
	unwrapMemberPortalEnvelope,
} from "@/api/client"
import type { MemberPortalEnvelope } from "@/api/account/types"
import type {
	ExpertiseResult,
	ExpertiseValues,
	ExpertiseView,
} from "@/api/expertise/types"

const EXPERTISE_PATH = "/services/apexrest/memberportal/expertise"

/**
 * SME multi-selects from Apex `GARP_Portal_ExpertiseService` (SME_Registration__c).
 */
export async function fetchExpertise(): Promise<ExpertiseView> {
	const sdk = await createDataSDK()
	const response = await sdk.fetch?.(EXPERTISE_PATH, {
		method: "GET",
		headers: { Accept: "application/json" },
	})

	const result = await normalizeHttpResponse<
		MemberPortalEnvelope<ExpertiseView>
	>(response, {
		unreachableMessage: "Unable to reach the expertise service.",
		fallbackErrorMessage: "Unable to load expertise. Please try again.",
	})

	const envelope = unwrapApiResult(result)
	const data = unwrapMemberPortalEnvelope(envelope, {
		fallbackErrorMessage: "Unable to load expertise.",
		missingDataMessage: "No expertise data was returned.",
		status: result.status,
	})

	if (data.statusCode !== 200) {
		throw new AppError({
			messages: [data.statusMessage ?? "Unable to load expertise."],
			status: data.statusCode,
		})
	}

	return {
		...data,
		values: data.values ?? {},
		options: data.options ?? {},
		labels: data.labels ?? {},
	}
}

/**
 * Upserts the member's SME_Registration__c. Values are semicolon-joined.
 */
export async function saveExpertise(
	values: ExpertiseValues,
): Promise<ExpertiseResult> {
	const sdk = await createDataSDK()
	const response = await sdk.fetch?.(EXPERTISE_PATH, {
		method: "POST",
		headers: {
			"Content-Type": "application/json",
			Accept: "application/json",
		},
		body: JSON.stringify({ values }),
	})

	const result = await normalizeHttpResponse<
		MemberPortalEnvelope<ExpertiseResult>
	>(response, {
		unreachableMessage: "Unable to reach the expertise service.",
		fallbackErrorMessage: "Unable to save expertise. Please try again.",
	})

	const envelope = unwrapApiResult(result)
	const data = unwrapMemberPortalEnvelope(envelope, {
		fallbackErrorMessage: "Unable to save expertise.",
		missingDataMessage: "No save result was returned.",
		status: result.status,
	})

	if (data.statusCode !== 200) {
		throw new AppError({
			messages: [data.statusMessage ?? "Your expertise could not be saved."],
			status: data.statusCode,
		})
	}

	return data
}
