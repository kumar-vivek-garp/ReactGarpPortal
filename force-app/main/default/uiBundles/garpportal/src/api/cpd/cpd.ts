import { createDataSDK } from "@salesforce/platform-sdk"

import {
	AppError,
	memberPortalRefusalPayload,
	normalizeHttpResponse,
	unwrapApiResult,
	unwrapMemberPortalEnvelope,
} from "@/api/client"
import type { CpdView, MemberPortalEnvelope } from "@/api/cpd/types"

const CPD_PATH = "/services/apexrest/memberportal/cpd"

/**
 * Loads the dashboard CPD summary from Apex `GARP_Portal_API` (`cpd` action).
 *
 * Resolves `null` — rather than throwing — when the member has no CPE
 * contract. `GARP_Portal_CpdService` returns its own `statusCode: 401` for
 * that case (as does `GARP_Portal_Access` for an account with no contracts at
 * all) and the envelope lifts it onto the HTTP status, so a 401 here means
 * "no CPD program", NOT an expired session. Left to throw it would surface as
 * an error toast reading like a sign-in failure.
 *
 * 403 ("No Membership Found") is deliberately NOT caught here — that is a
 * genuine failure and must still toast. So is everything else.
 *
 * The 401 is matched on the *payload*, not the status. Apex answers a refusal
 * with its own code plus the reason, while a request that could not run at all
 * — an expired session above all — answers the same 401 with an empty body.
 * Keying on the status alone would show "no CPD programme" to a member who had
 * merely been signed out.
 *
 * The check has to sit here rather than in the query options: on any non-2xx,
 * `normalizeHttpResponse` builds an `AppError` and `unwrapApiResult` throws it,
 * so by the time a caller sees the result the business meaning is gone and
 * `QueryCache.onError` has already fired.
 */
export async function fetchCpd(): Promise<CpdView | null> {
	const sdk = await createDataSDK()
	const response = await sdk.fetch?.(CPD_PATH, {
		method: "GET",
		headers: { Accept: "application/json" },
	})

	const result = await normalizeHttpResponse<MemberPortalEnvelope<CpdView>>(
		response,
		{
			unreachableMessage: "Unable to reach the CPD service.",
			fallbackErrorMessage: "Unable to load CPD credits. Please try again.",
		},
	)

	if (result.status === 401) {
		const refusal = memberPortalRefusalPayload<CpdView>(result)
		if (refusal) {
			return null
		}
		// No payload — the request never ran. Fall through and throw.
	}

	const envelope = unwrapApiResult(result)

	const data = unwrapMemberPortalEnvelope(envelope, {
		fallbackErrorMessage: "Unable to load CPD credits.",
		missingDataMessage: "No CPD data was returned.",
		status: result.status,
	})

	if (data.statusCode !== 200) {
		throw new AppError({
			messages: [data.statusMessage ?? "Unable to load CPD credits."],
			status: data.statusCode,
		})
	}

	return data
}
