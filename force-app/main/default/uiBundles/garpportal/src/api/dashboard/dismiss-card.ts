import { createDataSDK } from "@salesforce/platform-sdk"

import {
	AppError,
	assertMemberPortalEnvelopeOk,
	normalizeHttpResponse,
	unwrapApiResult,
} from "@/api/client"
import type {
	DismissCardResult,
	MemberPortalEnvelope,
} from "@/api/dashboard/types"

const DISMISS_CARD_PATH = "/services/apexrest/memberportal/dismissCard"

/**
 * Persists a dismissed dashboard card for the signed-in member
 * (`GARP_MemberPortal_API` dismissCard).
 */
export async function dismissCard(key: string): Promise<DismissCardResult> {
	const trimmed = key.trim()
	if (!trimmed) {
		throw new AppError({ messages: ["A card key is required."] })
	}

	const sdk = await createDataSDK()
	const response = await sdk.fetch?.(DISMISS_CARD_PATH, {
		method: "POST",
		headers: {
			"Content-Type": "application/json",
			Accept: "application/json",
		},
		body: JSON.stringify({ key: trimmed }),
	})

	const result = await normalizeHttpResponse<
		MemberPortalEnvelope<DismissCardResult>
	>(response, {
		unreachableMessage: "Unable to reach the dashboard service.",
		fallbackErrorMessage: "Unable to dismiss this card. Please try again.",
	})

	const envelope = unwrapApiResult(result)

	assertMemberPortalEnvelopeOk(envelope, {
		fallbackErrorMessage: "Unable to dismiss this card.",
		status: result.status,
	})

	return envelope.data ?? { dismissed: trimmed }
}
