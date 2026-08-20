import { createDataSDK } from "@salesforce/platform-sdk"

import {
	AppError,
	normalizeHttpResponse,
	unwrapApiResult,
	unwrapMemberPortalEnvelope,
} from "@/api/client"
import type { MemberPortalEnvelope, PortalResult } from "@/api/orders/types"

const CANCEL_ORDER_PATH = "/services/apexrest/memberportal/cancelOrder"

/**
 * Cancels the member's unpaid order (`cancelOrder` — New Lead only).
 */
export async function cancelOrder(orderId: string): Promise<PortalResult> {
	const id = orderId.trim()
	if (!id) {
		throw new AppError({
			messages: ["An order id is required."],
			status: 400,
		})
	}

	const sdk = await createDataSDK()
	const response = await sdk.fetch?.(CANCEL_ORDER_PATH, {
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
			"Unable to cancel this order. Please try again.",
	})

	const envelope = unwrapApiResult(result)

	const data = unwrapMemberPortalEnvelope(envelope, {
		fallbackErrorMessage: "Your order could not be cancelled.",
		missingDataMessage: "No cancel result was returned.",
		status: result.status,
	})

	if (data.statusCode !== 200) {
		throw new AppError({
			messages: [
				data.statusMessage ?? "Your order could not be cancelled.",
			],
			status: data.statusCode,
		})
	}

	return data
}
