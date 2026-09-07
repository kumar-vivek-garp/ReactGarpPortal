import { createDataSDK } from "@salesforce/platform-sdk"

import type { MemberPortalEnvelope } from "@/api/account/types"
import {
	AppError,
	normalizeHttpResponse,
	unwrapApiResult,
	unwrapMemberPortalEnvelope,
} from "@/api/client"
import type { AddressResult, AddressSubmission } from "@/api/personal-info/types"

const ADDRESSES_PATH = "/services/apexrest/memberportal/addresses"

/**
 * Writes the mailing (Contact) and billing (Account) addresses through Apex
 * `GARP_Portal_AddressService`. The body is the raw submission — the service
 * deserialises the request body itself, so there is no `{ values }` wrapper.
 *
 * Apex writes the Contact first; if the Account write then fails it answers
 * 501 with a partial-success message, mirrored into the HTTP status. That is
 * surfaced verbatim rather than reported as a save.
 */
export async function saveAddresses(
	submission: AddressSubmission,
): Promise<AddressResult> {
	const sdk = await createDataSDK()
	const response = await sdk.fetch?.(ADDRESSES_PATH, {
		method: "POST",
		headers: {
			"Content-Type": "application/json",
			Accept: "application/json",
		},
		body: JSON.stringify(submission),
	})

	const result = await normalizeHttpResponse<MemberPortalEnvelope<AddressResult>>(
		response,
		{
			unreachableMessage: "Unable to reach the address service.",
			fallbackErrorMessage: "Your address could not be saved.",
		},
	)

	const data = unwrapMemberPortalEnvelope(unwrapApiResult(result), {
		fallbackErrorMessage: "Your address could not be saved.",
		missingDataMessage: "No response was returned.",
		status: result.status,
	})

	if (data.statusCode !== 200) {
		throw new AppError({
			messages: [data.statusMessage?.trim() || "Your address could not be saved."],
			status: data.statusCode,
		})
	}

	return data
}
