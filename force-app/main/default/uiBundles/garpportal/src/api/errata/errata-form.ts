import { createDataSDK } from "@salesforce/platform-sdk"

import {
	AppError,
	memberPortalRefusalPayload,
	normalizeHttpResponse,
	unwrapApiResult,
	unwrapMemberPortalEnvelope,
} from "@/api/client"
import type {
	ErrataFormView,
	MemberPortalEnvelope,
} from "@/api/errata/types"

const ERRATA_FORM_PATH = "/services/apexrest/memberportal/errataForm"

/**
 * The cascade's options for one programme (`errataForm`).
 *
 * Resolves `null` — rather than throwing — when the member is not entitled to
 * report errata. Reporting needs an *activated* contract on one of the
 * programmes the catalogue marks as errata-capable, and Apex says so with its
 * own 403 "Errata Access Denied" while still describing itself in `data`. That
 * is a business answer, not a failure, so the page renders an empty state
 * instead of an error toast. A 403 with an empty body is a real access problem
 * and still throws — see `memberPortalRefusalPayload`.
 */
export async function fetchErrataForm(
	programType: string,
): Promise<ErrataFormView | null> {
	const key = programType.trim()
	if (!key) {
		throw new AppError({
			messages: ["A program type is required."],
			status: 400,
		})
	}

	const sdk = await createDataSDK()
	const response = await sdk.fetch?.(
		`${ERRATA_FORM_PATH}?programType=${encodeURIComponent(key)}`,
		{ method: "GET", headers: { Accept: "application/json" } },
	)

	const result = await normalizeHttpResponse<
		MemberPortalEnvelope<ErrataFormView>
	>(response, {
		unreachableMessage: "Unable to reach the errata service.",
		fallbackErrorMessage: "Unable to load the errata form. Please try again.",
	})

	if (
		result.status === 403 &&
		memberPortalRefusalPayload<ErrataFormView>(result)
	) {
		return null
	}

	const data = unwrapMemberPortalEnvelope(unwrapApiResult(result), {
		fallbackErrorMessage: "Unable to load the errata form.",
		missingDataMessage: "No errata options were returned.",
		status: result.status,
	})

	if (data.statusCode !== 200) {
		throw new AppError({
			messages: [data.statusMessage ?? "Unable to load the errata form."],
			status: data.statusCode,
		})
	}

	// An empty map is a valid answer for a programme with no matching books.
	return { ...data, errataPicklistOption: data.errataPicklistOption ?? {} }
}
