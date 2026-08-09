import { createDataSDK } from "@salesforce/platform-sdk"

import {
	AppError,
	normalizeHttpResponse,
	unwrapApiResult,
} from "@/api/client"
import type { MemberPortalEnvelope, OrdersView } from "@/api/orders/types"

const ORDERS_PATH = "/services/apexrest/memberportal/orders"

/**
 * Loads purchase history from Apex `GARP_MemberPortal_API` (orders action).
 * Unwraps `{ ok, data }` / `{ ok, error }` into `OrdersView` or throws `AppError`.
 */
export async function fetchOrders(): Promise<OrdersView> {
	const sdk = await createDataSDK()
	const response = await sdk.fetch?.(ORDERS_PATH, {
		method: "GET",
		headers: { Accept: "application/json" },
	})

	const result = await normalizeHttpResponse<MemberPortalEnvelope<OrdersView>>(
		response,
		{
			unreachableMessage: "Unable to reach the orders service.",
			fallbackErrorMessage: "Unable to load orders. Please try again.",
		},
	)

	const envelope = unwrapApiResult(result)

	if (!envelope.ok) {
		throw new AppError({
			messages: [envelope.error ?? "Unable to load orders."],
			status: result.status,
		})
	}

	if (!envelope.data) {
		throw new AppError({
			messages: ["No order data was returned."],
			status: result.status,
		})
	}

	return envelope.data
}
