import { createDataSDK } from "@salesforce/platform-sdk"

import {
	AppError,
	normalizeHttpResponse,
	unwrapApiResult,
	unwrapMemberPortalEnvelope,
} from "@/api/client"
import type {
	MemberPortalEnvelope,
	OrderCheckoutRequest,
	OrderCheckoutResult,
	PortalResult,
} from "@/api/orders/types"

export const ORDER_CHECKOUT_PATH =
	"/services/apexrest/memberportal/orderCheckout"

/**
 * Opens the hosted checkout for an order (`orderCheckout`).
 *
 * The portal's one checkout endpoint. `orderId` may be an Opportunity or a
 * staged `Order_History__c` row — `GARP_Portal_OrdersService.payableId`
 * routes on what the id points at, so the client stays flow-agnostic. Does
 * not charge anything; the redirect to `checkoutUrl` is where payment starts.
 */
export async function orderCheckout(
	request: OrderCheckoutRequest,
): Promise<OrderCheckoutResult> {
	const sdk = await createDataSDK()
	const response = await sdk.fetch?.(ORDER_CHECKOUT_PATH, {
		method: "POST",
		headers: { "Content-Type": "application/json", Accept: "application/json" },
		body: JSON.stringify(request),
	})

	const result = await normalizeHttpResponse<
		MemberPortalEnvelope<
			PortalResult & { checkoutUrl?: string | null; orderNumber?: string | null }
		>
	>(response, {
		unreachableMessage: "Unable to reach the orders service.",
		fallbackErrorMessage: "We could not open the payment page.",
	})

	const data = unwrapMemberPortalEnvelope(unwrapApiResult(result), {
		fallbackErrorMessage: "We could not open the payment page.",
		missingDataMessage: "No checkout session was returned.",
		status: result.status,
	})

	const checkoutUrl = data.checkoutUrl?.trim()
	if (data.statusCode !== 200 || !checkoutUrl) {
		throw new AppError({
			messages: [data.statusMessage ?? "We could not open the payment page."],
			status: data.statusCode,
		})
	}

	return { checkoutUrl, orderNumber: data.orderNumber?.trim() || null }
}
