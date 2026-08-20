import { createDataSDK } from "@salesforce/platform-sdk"

import {
	normalizeHttpResponse,
	unwrapApiResult,
	unwrapMemberPortalEnvelope,
} from "@/api/client"
import type {
	AutoRenewOffResult,
	AutoRenewOnResult,
	MemberPortalEnvelope,
} from "@/api/account/types"

const AUTO_RENEW_OFF_PATH =
	"/services/apexrest/memberportal/membershipAutoRenewOff"
const AUTO_RENEW_ON_PATH =
	"/services/apexrest/memberportal/membershipAutoRenewOn"

/**
 * Stops recurring membership payment. Session-scoped — no body.
 */
export async function turnOffMembershipAutoRenew(): Promise<AutoRenewOffResult> {
	const sdk = await createDataSDK()
	const response = await sdk.fetch?.(AUTO_RENEW_OFF_PATH, {
		method: "POST",
		headers: {
			"Content-Type": "application/json",
			Accept: "application/json",
		},
		body: JSON.stringify({}),
	})

	const result = await normalizeHttpResponse<
		MemberPortalEnvelope<AutoRenewOffResult>
	>(response, {
		unreachableMessage: "Unable to reach the membership service.",
		fallbackErrorMessage:
			"Unable to turn off auto-renew. Please try again.",
	})

	const envelope = unwrapApiResult(result)
	return unwrapMemberPortalEnvelope(envelope, {
		fallbackErrorMessage: "Unable to turn off auto-renew.",
		missingDataMessage: "No auto-renew result was returned.",
		status: result.status,
	})
}

/**
 * Stages auto-renew. When `needPaymentInfo` is true the member finishes on
 * `/stripe_checkout?mode=setup&id={orderId}` (same as legacy garpApp).
 */
export async function turnOnMembershipAutoRenew(): Promise<AutoRenewOnResult> {
	const sdk = await createDataSDK()
	const response = await sdk.fetch?.(AUTO_RENEW_ON_PATH, {
		method: "POST",
		headers: {
			"Content-Type": "application/json",
			Accept: "application/json",
		},
		body: JSON.stringify({}),
	})

	const result = await normalizeHttpResponse<
		MemberPortalEnvelope<AutoRenewOnResult>
	>(response, {
		unreachableMessage: "Unable to reach the membership service.",
		fallbackErrorMessage: "Unable to turn on auto-renew. Please try again.",
	})

	const envelope = unwrapApiResult(result)
	const data = unwrapMemberPortalEnvelope(envelope, {
		fallbackErrorMessage: "Unable to turn on auto-renew.",
		missingDataMessage: "No auto-renew result was returned.",
		status: result.status,
	})

	return {
		...data,
		needPaymentInfo: data.needPaymentInfo === true,
	}
}
