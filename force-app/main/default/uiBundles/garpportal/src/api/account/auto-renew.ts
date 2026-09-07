import { createDataSDK } from "@salesforce/platform-sdk"

import {
	AppError,
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
 * Starts switching auto-renew on. Charges nothing and creates no order: the
 * server opens a Stripe setup session and answers with its `setupUrl`, and
 * Stripe brings the browser back to `returnUrl` once the card is stored.
 * Same contract as GarpAppv1's `turnOnAutoRenew`.
 *
 * A 200 without a URL has nowhere to send the member, so it is an error here
 * rather than a silent no-op.
 */
export async function turnOnMembershipAutoRenew(
	returnUrl: string,
): Promise<AutoRenewOnResult> {
	const sdk = await createDataSDK()
	const response = await sdk.fetch?.(AUTO_RENEW_ON_PATH, {
		method: "POST",
		headers: {
			"Content-Type": "application/json",
			Accept: "application/json",
		},
		body: JSON.stringify({ returnUrl }),
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

	const setupUrl = data.setupUrl?.trim() || null
	if (!setupUrl) {
		throw new AppError({
			messages: [data.statusMessage?.trim() || "Auto-renew could not be switched on."],
			status: result.status,
		})
	}

	return {
		...data,
		needPaymentInfo: data.needPaymentInfo !== false,
		setupUrl,
	}
}
