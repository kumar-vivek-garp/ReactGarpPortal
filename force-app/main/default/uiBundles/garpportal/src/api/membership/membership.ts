import { createDataSDK } from "@salesforce/platform-sdk"

import {
	normalizeHttpResponse,
	unwrapApiResult,
	unwrapMemberPortalEnvelope,
} from "@/api/client"
import type {
	MemberPortalEnvelope,
	MembershipView,
} from "@/api/membership/types"

const MEMBERSHIP_PATH = "/services/apexrest/memberportal/membership"

/**
 * Loads membership identity hero + benefit sections from Apex
 * `GARP_MemberPortal_API` (membership action).
 * Unwraps the memberportal envelope into `MembershipView` or throws `AppError`.
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

	return unwrapMemberPortalEnvelope(envelope, {
		fallbackErrorMessage: "Unable to load membership.",
		missingDataMessage: "No membership data was returned.",
		status: result.status,
	})
}
