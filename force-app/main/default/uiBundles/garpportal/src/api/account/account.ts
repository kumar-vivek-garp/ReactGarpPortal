import { createDataSDK } from "@salesforce/platform-sdk"

import {
	AppError,
	normalizeHttpResponse,
	unwrapApiResult,
} from "@/api/client"
import type { AccountView, MemberPortalEnvelope } from "@/api/account/types"

const ACCOUNT_PATH = "/services/apexrest/memberportal/account"

/**
 * Loads the composed My Account view from Apex `GARP_MemberPortal_API`.
 * Unwraps `{ ok, data }` / `{ ok, error }` into `AccountView` or throws `AppError`.
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

	if (!envelope.ok) {
		throw new AppError({
			messages: [envelope.error ?? "Unable to load account."],
			status: result.status,
		})
	}

	if (!envelope.data) {
		throw new AppError({
			messages: ["No account data was returned."],
			status: result.status,
		})
	}

	return envelope.data
}
