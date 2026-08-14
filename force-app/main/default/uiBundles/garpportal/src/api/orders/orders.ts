import { createDataSDK } from "@salesforce/platform-sdk"

import {
	normalizeHttpResponse,
	unwrapApiResult,
	unwrapMemberPortalEnvelope,
} from "@/api/client"
import type { MemberPortalEnvelope, OrdersView } from "@/api/orders/types"

const ORDERS_PATH = "/services/apexrest/memberportal/orders"

/**
 * Loads purchase history from Apex `GARP_MemberPortal_API` (orders action).
 * Unwraps the memberportal envelope into `OrdersView` or throws `AppError`.
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

	return unwrapMemberPortalEnvelope(envelope, {
		fallbackErrorMessage: "Unable to load orders.",
		missingDataMessage: "No order data was returned.",
		status: result.status,
	})
}
