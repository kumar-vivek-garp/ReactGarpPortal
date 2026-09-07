import { createDataSDK } from "@salesforce/platform-sdk"

import type { MemberPortalEnvelope } from "@/api/account/types"
import {
	AppError,
	normalizeHttpResponse,
	unwrapApiResult,
	unwrapMemberPortalEnvelope,
} from "@/api/client"
import type { EmailPreferenceResult } from "@/api/contact-preferences/types"

const EMAIL_PREFERENCE_UPDATE_PATH =
	"/services/apexrest/memberportal/emailPreferenceUpdate"

const FAILURE = "Unable to request email preferences."

/**
 * The legacy "Manage My Email Subscription Preferences" link. Apex stamps
 * `Contact.Last_Email_Pref_Update_Date__c`; the org's own automation then
 * mails the member their preference-centre link. A 200 means the request was
 * recorded, which is what the confirmation copy promises.
 */
export async function requestEmailPreferences(): Promise<void> {
	const sdk = await createDataSDK()
	const response = await sdk.fetch?.(EMAIL_PREFERENCE_UPDATE_PATH, {
		method: "POST",
		headers: {
			"Content-Type": "application/json",
			Accept: "application/json",
		},
		body: "{}",
	})

	const result = await normalizeHttpResponse<
		MemberPortalEnvelope<EmailPreferenceResult>
	>(response, {
		unreachableMessage: "Unable to reach the email preferences service.",
		fallbackErrorMessage: FAILURE,
	})

	const data = unwrapMemberPortalEnvelope(unwrapApiResult(result), {
		fallbackErrorMessage: FAILURE,
		missingDataMessage: "No response was returned.",
		status: result.status,
	})

	if (data.statusCode !== 200) {
		throw new AppError({
			messages: [data.statusMessage?.trim() || FAILURE],
			status: data.statusCode,
		})
	}
}
