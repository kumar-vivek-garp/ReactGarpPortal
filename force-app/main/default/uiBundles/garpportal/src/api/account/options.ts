import { createDataSDK } from "@salesforce/platform-sdk"

import {
	normalizeHttpResponse,
	unwrapApiResult,
	unwrapMemberPortalEnvelope,
} from "@/api/client"
import type {
	AccountOptionsView,
	MemberPortalEnvelope,
} from "@/api/account/types"

const OPTIONS_PATH = "/services/apexrest/memberportal/options"

/**
 * Contact picklists for My Account edit forms (`GARP_Portal_OptionsService`).
 */
export async function fetchAccountOptions(): Promise<AccountOptionsView> {
	const sdk = await createDataSDK()
	const response = await sdk.fetch?.(OPTIONS_PATH, {
		method: "GET",
		headers: { Accept: "application/json" },
	})

	const result = await normalizeHttpResponse<
		MemberPortalEnvelope<AccountOptionsView>
	>(response, {
		unreachableMessage: "Unable to reach the account options service.",
		fallbackErrorMessage: "Unable to load form options. Please try again.",
	})

	const envelope = unwrapApiResult(result)
	const data = unwrapMemberPortalEnvelope(envelope, {
		fallbackErrorMessage: "Unable to load form options.",
		missingDataMessage: "No form options were returned.",
		status: result.status,
	})

	return {
		picklists: data.picklists ?? {},
		chapters: data.chapters ?? [],
	}
}
