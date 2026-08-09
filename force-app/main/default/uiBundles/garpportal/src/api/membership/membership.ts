import { createDataSDK } from "@salesforce/platform-sdk"

import {
	AppError,
	normalizeHttpResponse,
	unwrapApiResult,
} from "@/api/client"
import type {
	MemberPortalEnvelope,
	MembershipView,
} from "@/api/membership/types"

const MEMBERSHIP_PATH = "/services/apexrest/memberportal/membership"

/**
 * Loads membership identity hero + benefit sections from Apex
 * `GARP_MemberPortal_API` (membership action).
 * Unwraps `{ ok, data }` / `{ ok, error }` into `MembershipView` or throws `AppError`.
 */
export async function fetchMembership(): Promise<MembershipView> {
	const sdk = await createDataSDK()
	const response = await sdk.fetch?.(MEMBERSHIP_PATH, {
		method: "GET",
		headers: { Accept: "application/json" },
	})

	const result = await normalizeHttpResponse<
		MemberPortalEnvelope<MembershipView>
	>(response, {
		unreachableMessage: "Unable to reach the membership service.",
		fallbackErrorMessage: "Unable to load membership. Please try again.",
	})

	const envelope = unwrapApiResult(result)

	if (!envelope.ok) {
		throw new AppError({
			messages: [envelope.error ?? "Unable to load membership."],
			status: result.status,
		})
	}

	if (!envelope.data) {
		throw new AppError({
			messages: ["No membership data was returned."],
			status: result.status,
		})
	}

	return envelope.data
}
