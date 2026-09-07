import { createDataSDK } from "@salesforce/platform-sdk"

import {
	AppError,
	memberPortalRefusalPayload,
	normalizeHttpResponse,
	unwrapApiResult,
	unwrapMemberPortalEnvelope,
} from "@/api/client"
import type {
	MaterialPurchaseRequest,
	MaterialPurchaseResult,
	MaterialQuote,
	MemberPortalEnvelope,
} from "@/api/study-materials/types"

export const MATERIAL_QUOTE_PATH =
	"/services/apexrest/memberportal/materialQuote"
export const MATERIAL_PURCHASE_PATH =
	"/services/apexrest/memberportal/materialPurchase"

/**
 * Prices one study material for this member (`materialQuote`).
 *
 * Resolves `null` — rather than throwing — for the service's deliberate 404:
 * "This item is not available to purchase." Apex gives that ONE answer for
 * already owned, not purchasable, out of stock and not on their catalogue, so
 * the page cannot be used to probe the catalogue. It is a business answer,
 * not a failure, so the page renders a state instead of toasting. A 404 with
 * an empty body is a real routing problem and still throws — see
 * `memberPortalRefusalPayload`.
 */
export async function fetchMaterialQuote(
	productCode: string,
): Promise<MaterialQuote | null> {
	const code = productCode.trim()
	if (!code) {
		throw new AppError({ messages: ["A product code is required."], status: 400 })
	}

	const sdk = await createDataSDK()
	const response = await sdk.fetch?.(
		`${MATERIAL_QUOTE_PATH}?productCode=${encodeURIComponent(code)}`,
		{ method: "GET", headers: { Accept: "application/json" } },
	)

	const result = await normalizeHttpResponse<
		MemberPortalEnvelope<MaterialQuote>
	>(response, {
		unreachableMessage: "Unable to reach the study materials service.",
		fallbackErrorMessage: "Unable to load this purchase. Please try again.",
	})

	if (result.status === 404 && memberPortalRefusalPayload<MaterialQuote>(result)) {
		return null
	}

	const data = unwrapMemberPortalEnvelope(unwrapApiResult(result), {
		fallbackErrorMessage: "Unable to load this purchase.",
		missingDataMessage: "No quote was returned.",
		status: result.status,
	})

	if (data.statusCode !== 200) {
		throw new AppError({
			messages: [data.statusMessage ?? "Unable to load this purchase."],
			status: data.statusCode,
		})
	}

	return {
		...data,
		isShippable: data.isShippable === true,
		shipTo: data.shipTo ?? null,
		shippableCountries: Array.isArray(data.shippableCountries)
			? data.shippableCountries
			: [],
	}
}

/**
 * Raises the order for one material (`materialPurchase`).
 *
 * **Not idempotent.** Under the immediate flow this writes an Opportunity; the
 * caller must never retry on its own. Every refusal — 404 not available, 501
 * missing address, 429 rate limit — throws with the server's own sentence,
 * which is the message the form shows.
 */
export async function purchaseMaterial(
	request: MaterialPurchaseRequest,
): Promise<MaterialPurchaseResult> {
	const sdk = await createDataSDK()
	const response = await sdk.fetch?.(MATERIAL_PURCHASE_PATH, {
		method: "POST",
		headers: { "Content-Type": "application/json", Accept: "application/json" },
		body: JSON.stringify(request),
	})

	const result = await normalizeHttpResponse<
		MemberPortalEnvelope<MaterialPurchaseResult>
	>(response, {
		unreachableMessage: "Unable to reach the study materials service.",
		fallbackErrorMessage: "Your order could not be created. Please try again.",
	})

	const data = unwrapMemberPortalEnvelope(unwrapApiResult(result), {
		fallbackErrorMessage: "Your order could not be created.",
		missingDataMessage: "No order was returned.",
		status: result.status,
	})

	if (data.statusCode !== 200) {
		throw new AppError({
			messages: [data.statusMessage ?? "Your order could not be created."],
			status: data.statusCode,
		})
	}

	return data
}
