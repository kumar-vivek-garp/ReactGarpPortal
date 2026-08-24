import { createDataSDK } from "@salesforce/platform-sdk"

import {
	AppError,
	normalizeHttpResponse,
	unwrapApiResult,
	unwrapMemberPortalEnvelope,
} from "@/api/client"
import type {
	CvAddressPayload,
	CvExperienceResult,
	MemberPortalEnvelope,
} from "@/api/work-experience/types"

const CV_ADDRESS_PATH = "/services/apexrest/memberportal/cvAddress"

/**
 * Saves where the certificate is posted (`cvAddress`).
 *
 * **This writes the member's own Contact, not a CV-local address.** Apex maps
 * `mailingAddress` straight onto `MailingStreet` / `MailingCity` /
 * `MailingState` / `MailingPostalCode` / `MailingCountry` /
 * `Mailing_Address_Company__c` / `HomePhone` — the same seven fields the My
 * Account dialog edits. Two consequences the caller must respect:
 *
 * 1. **It is a full overwrite, not a patch.** Every field is assigned from the
 *    payload, so any one omitted is written as null. `GET cv` returns neither
 *    `company` nor `phone`, so a form seeded only from the CV view would
 *    silently blank both on the member's Contact. Seed from the personal-info
 *    payload, which carries all nine fields.
 * 2. **It invalidates My Account too.** Apex calls `clearContactCache()` on the
 *    server; the client must drop its personal-info queries to match.
 *
 * The OSTA block is written only when one is sent — a candidate not sitting in
 * China has no OSTA address to clear, and passing an empty one would erase it.
 */
export async function saveCvAddress(
	payload: CvAddressPayload,
): Promise<CvExperienceResult> {
	if (!payload.mailingAddress) {
		throw new AppError({
			messages: ["A delivery address is required."],
			status: 400,
		})
	}

	const sdk = await createDataSDK()
	const response = await sdk.fetch?.(CV_ADDRESS_PATH, {
		method: "POST",
		headers: { "Content-Type": "application/json", Accept: "application/json" },
		// Apex deserializes the RAW body into CvAddressInput — the payload is the
		// body itself, not wrapped in another key.
		body: JSON.stringify({
			mailingAddress: payload.mailingAddress,
			...(payload.ostaAddress ? { ostaAddress: payload.ostaAddress } : {}),
			...(payload.ostaRecipient
				? { ostaRecipient: payload.ostaRecipient }
				: {}),
		}),
	})

	const result = await normalizeHttpResponse<
		MemberPortalEnvelope<CvExperienceResult>
	>(response, {
		unreachableMessage: "Unable to reach the work experience service.",
		fallbackErrorMessage: "Your address could not be saved.",
	})

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
