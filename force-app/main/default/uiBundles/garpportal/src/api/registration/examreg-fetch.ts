import { createDataSDK } from "@salesforce/platform-sdk"

import type { MemberPortalEnvelope } from "@/api/account/types"
import {
	normalizeHttpResponse,
	unwrapApiResult,
	unwrapMemberPortalEnvelope,
} from "@/api/client"

/** `GARP_ExamReg_API` — one `@RestResource` for every registration programme. */
export const EXAMREG_BASE = "/services/apexrest/examreg"

export const EXAMREG_UNREACHABLE = "Unable to reach the registration service."

/**
 * Shared transport for the registration endpoints.
 *
 * Guest-reachable by design — the same endpoint serves someone with no session
 * — and it answers with the portal-standard envelope. `sdk.fetch` still
 * carries the session when one exists, which is how the load reports
 * `isAuthenticated`.
 */
export async function examregFetch<T>(
	path: string,
	init: RequestInit,
	messages: { unreachable: string; fallback: string },
): Promise<T> {
	const sdk = await createDataSDK()
	const response = await sdk.fetch?.(`${EXAMREG_BASE}${path}`, {
		...init,
		headers: {
			Accept: "application/json",
			...(init.body ? { "Content-Type": "application/json" } : {}),
			...init.headers,
		},
	})

	const result = await normalizeHttpResponse<MemberPortalEnvelope<T>>(response, {
		unreachableMessage: messages.unreachable,
		fallbackErrorMessage: messages.fallback,
	})

	return unwrapMemberPortalEnvelope(unwrapApiResult(result), {
		fallbackErrorMessage: messages.fallback,
		missingDataMessage: messages.fallback,
		status: result.status,
	})
}
