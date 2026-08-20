import { createDataSDK } from "@salesforce/platform-sdk"

import {
	AppError,
	normalizeHttpResponse,
	unwrapApiResult,
} from "@/api/client"
import type { MemberPortalEnvelope, PortalResult } from "@/api/orders/types"

const PAY_ORDER_PATH = "/services/apexrest/memberportal/payOrder"

/**
 * Readies an unpaid order for hosted checkout (`payOrder`). Does not charge.
 *
 * Envelope `statusCode` may be **200** (ready for Stripe) or **201** (zero-value
 * order closed). Both are success — callers must branch on the code.
 */
export async function payOrder(orderId: string): Promise<PortalResult> {
	const id = orderId.trim()
	if (!id) {
		throw new AppError({
			messages: ["An order id is required."],
			status: 400,
		})
	}

	const sdk = await createDataSDK()
	const response = await sdk.fetch?.(PAY_ORDER_PATH, {
		method: "POST",
		headers: {
			"Content-Type": "application/json",
			Accept: "application/json",
		},
		body: JSON.stringify({ orderId: id }),
	})

	const result = await normalizeHttpResponse<
		MemberPortalEnvelope<PortalResult>
	>(response, {
		unreachableMessage: "Unable to reach the orders service.",
		fallbackErrorMessage:
			"Unable to prepare this order for payment. Please try again.",
	})

	const envelope = unwrapApiResult(result)

	// Apex `respond` lifts PayResult.statusCode onto the envelope — 201 is OK.
	if (envelope.statusCode !== 200 && envelope.statusCode !== 201) {
		throw new AppError({
			messages: [
				envelope.errorMessage?.trim() ||
					envelope.data?.statusMessage?.trim() ||
					"This order could not be prepared for payment.",
			],
			status: envelope.statusCode || result.status,
		})
	}

	if (envelope.data === undefined) {
		throw new AppError({
			messages: ["No payment result was returned."],
			status: envelope.statusCode || result.status,
		})
	}

	return {
		statusCode: envelope.data.statusCode ?? envelope.statusCode,
		statusMessage: envelope.data.statusMessage ?? null,
	}
}
