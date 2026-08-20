import { createDataSDK } from "@salesforce/platform-sdk"

import {
	AppError,
	normalizeHttpResponse,
	unwrapApiResult,
	unwrapMemberPortalEnvelope,
} from "@/api/client"
import type {
	MemberPortalEnvelope,
	OrderDetailView,
} from "@/api/orders/types"

const ORDER_DETAIL_PATH = "/services/apexrest/memberportal/orderDetail"

/**
 * Loads one order by invoice number or Opportunity Id from Apex
 * `GARP_Portal_API` (`orderDetail` action).
 */
export async function fetchOrderDetail(
	orderNumber: string,
): Promise<OrderDetailView> {
	const key = orderNumber.trim()
	if (!key) {
		throw new AppError({
			messages: ["An order number is required."],
			status: 400,
		})
	}

	const sdk = await createDataSDK()
	const path = `${ORDER_DETAIL_PATH}?orderNumber=${encodeURIComponent(key)}`
	const response = await sdk.fetch?.(path, {
		method: "GET",
		headers: { Accept: "application/json" },
	})

	const result = await normalizeHttpResponse<
		MemberPortalEnvelope<OrderDetailView>
	>(response, {
		unreachableMessage: "Unable to reach the order detail service.",
		fallbackErrorMessage: "Unable to load this order. Please try again.",
	})

	const envelope = unwrapApiResult(result)

	const data = unwrapMemberPortalEnvelope(envelope, {
		fallbackErrorMessage: "Unable to load this order.",
		missingDataMessage: "No order detail was returned.",
		status: result.status,
	})

	if (data.statusCode !== 200) {
		throw new AppError({
			messages: [data.statusMessage ?? "Unable to load this order."],
			status: data.statusCode,
		})
	}

	return data
}
