import { http, HttpResponse } from "msw"

import type { EmailPreferenceResult } from "@/api/contact-preferences/types"

export const EMAIL_PREFERENCE_UPDATE_PATH =
	"/services/apexrest/memberportal/emailPreferenceUpdate"

/**
 * The "send me my email preferences link" action. Apex stamps a Contact date
 * and returns a status payload; a non-200 `statusCode` is mirrored into the
 * HTTP status the way `GARP_Portal_API.respond` does.
 */
export function emailPreferenceHandler(
	respond: (hits: number) => EmailPreferenceResult = () => ({
		statusMessage: "Email Pref Date Updated",
		statusCode: 200,
	}),
) {
	const spy = { hits: 0 }
	const handler = http.post(EMAIL_PREFERENCE_UPDATE_PATH, () => {
		spy.hits += 1
		const payload = respond(spy.hits)
		const failed = payload.statusCode >= 400
		return HttpResponse.json(
			{
				status: failed ? "Error" : "Success",
				statusCode: payload.statusCode,
				errorMessage: failed ? payload.statusMessage : null,
				data: payload,
			},
			{ status: payload.statusCode },
		)
	})
	return { spy, handler }
}
