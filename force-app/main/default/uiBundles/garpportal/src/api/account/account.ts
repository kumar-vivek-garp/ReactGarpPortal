import { createDataSDK } from "@salesforce/platform-sdk"

import {
	normalizeHttpResponse,
	unwrapApiResult,
	unwrapMemberPortalEnvelope,
} from "@/api/client"
import type { AccountView, MemberPortalEnvelope } from "@/api/account/types"

const ACCOUNT_PATH = "/services/apexrest/memberportal/account"

/**
 * Loads the composed My Account view from Apex `GARP_MemberPortal_API`.
 * Unwraps the memberportal envelope into `AccountView` or throws `AppError`.
 */
export async function fetchAccount(): Promise<AccountView> {
	const sdk = await createDataSDK()
	const response = await sdk.fetch?.(ACCOUNT_PATH, {
		method: "GET",
		headers: { Accept: "application/json" },
	})

	const result = await normalizeHttpResponse<MemberPortalEnvelope<AccountView>>(
		response,
		{
			unreachableMessage: "Unable to reach the account service.",
			fallbackErrorMessage: "Unable to load account. Please try again.",
		},
	)

	const envelope = unwrapApiResult(result)

	return unwrapMemberPortalEnvelope(envelope, {
		fallbackErrorMessage: "Unable to load account.",
		missingDataMessage: "No account data was returned.",
		status: result.status,
	})
}
