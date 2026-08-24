import { createDataSDK } from "@salesforce/platform-sdk"

import {
	memberPortalRefusalPayload,
	normalizeHttpResponse,
	unwrapApiResult,
	unwrapMemberPortalEnvelope,
} from "@/api/client"
import type { AlertBarView, MemberPortalEnvelope } from "@/api/alert-bar/types"

const ALERT_BAR_PATH = "/services/apexrest/memberportal/alertBar"

/**
 * The one exam alert this member must act on, or `null` for none.
 *
 * Two ordinary outcomes both resolve `null` rather than throwing, because the
 * banner is chrome and neither is worth interrupting a page for:
 *
 *   200 "No alerts found"      nothing to say — by far the common case
 *   401 "Portal Access Denied" no live contract, so no exam to alert about
 *
 * That second one is told apart from a dead session the usual way — a refusal
 * describes itself in `data`, an expired session does not. An empty body still
 * throws, and the query is configured not to toast it.
 *
 * Apex accepts an optional `?loadKey=` that previews an administration still
 * loading. It exists for internal callers checking an unreleased sitting; a
 * member must never see one, so it is deliberately not sent.
 */
export async function fetchAlertBar(): Promise<AlertBarView | null> {
	const sdk = await createDataSDK()
	const response = await sdk.fetch?.(ALERT_BAR_PATH, {
		method: "GET",
		headers: { Accept: "application/json" },
	})

	const result = await normalizeHttpResponse<
		MemberPortalEnvelope<AlertBarView>
	>(response, {
		unreachableMessage: "Unable to reach the alert service.",
		fallbackErrorMessage: "Unable to load your alerts.",
	})

	if (
		(result.status === 401 || result.status === 403) &&
		memberPortalRefusalPayload<AlertBarView>(result)
	) {
		return null
	}

	const data = unwrapMemberPortalEnvelope(unwrapApiResult(result), {
		fallbackErrorMessage: "Unable to load your alerts.",
		missingDataMessage: "No alert data was returned.",
		status: result.status,
	})

	// A non-200 inner code that still carried a payload is a refusal, not a
	// failure — the same reasoning as above, reached by a different route.
	if (data.statusCode !== 200) return null

	return data.alertStatus ? data : null
}
