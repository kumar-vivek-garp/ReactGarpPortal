import { createDataSDK } from "@salesforce/platform-sdk"

import {
	AppError,
	normalizeHttpResponse,
	unwrapApiResult,
	unwrapMemberPortalEnvelope,
} from "@/api/client"
import type { AdInfo, MemberPortalEnvelope } from "@/api/dashboard/types"

const AD_PATH = "/services/apexrest/memberportal/ad"

/**
 * The dashboard's cross-sell (`ad`).
 *
 * Advertises a programme the member does **not** currently sit — no contract,
 * an expired one, or a live one whose last sitting is over a year old. A
 * member with any sitting still awaiting a result gets nothing at all, because
 * they are mid-programme and there is nothing to sell them.
 *
 * `adType` is `null` in that case, and that is a success, not a failure. It is
 * also drawn **at random** from the eligible programmes on every request, so
 * the card legitimately changes between visits — do not cache it long or treat
 * a change as a bug.
 */
export async function fetchAd(): Promise<AdInfo> {
	const sdk = await createDataSDK()
	const response = await sdk.fetch?.(AD_PATH, {
		method: "GET",
		headers: { Accept: "application/json" },
	})

	const result = await normalizeHttpResponse<MemberPortalEnvelope<AdInfo>>(
		response,
		{
			unreachableMessage: "Unable to reach the dashboard service.",
			fallbackErrorMessage: "Unable to load the recommendation.",
		},
	)

	const data = unwrapMemberPortalEnvelope(unwrapApiResult(result), {
		fallbackErrorMessage: "Unable to load the recommendation.",
		missingDataMessage: "No recommendation was returned.",
		status: result.status,
	})

	if (data.statusCode !== 200) {
		throw new AppError({
			messages: [data.statusMessage ?? "Unable to load the recommendation."],
			status: data.statusCode,
		})
	}

	return data
}
