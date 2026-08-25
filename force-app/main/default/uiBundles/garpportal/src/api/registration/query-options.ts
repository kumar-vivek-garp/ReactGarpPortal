import { queryOptions } from "@tanstack/react-query"

import { fetchAffiliateRegistration } from "@/api/registration/affiliate"
import {
	calculateFees,
	fetchExamRegistration,
} from "@/api/registration/exam-registration"
import type { FeesRequest } from "@/api/registration/exam-types"

export const registrationQueryKeys = {
	all: ["registration"] as const,
	affiliate: ["registration", "affiliate"] as const,
	/** One programme's load. Keyed by reg code too — a code changes pricing. */
	exam: (programType: string, regCode?: string | null, courseCode?: string | null) =>
		[
			"registration",
			"exam",
			programType.trim().toLowerCase(),
			regCode ?? null,
			courseCode ?? null,
		] as const,
	/** The priced cart. The request itself is the key — see below. */
	fees: (request: unknown) => ["registration", "fees", request] as const,
}

/**
 * The Affiliate registration form's own load.
 *
 * `retry: false` because the two ways this fails — the guest profile is
 * missing Apex Class Access, or the programme row is inactive in metadata —
 * are both configuration, and neither is fixed by asking again.
 */
export const affiliateRegistrationQueryOptions = queryOptions({
	queryKey: registrationQueryKeys.affiliate,
	queryFn: fetchAffiliateRegistration,
	staleTime: 5 * 60_000,
	retry: false,
	meta: {
		toastError: true,
		errorTitle: "Unable to open registration",
	},
})

/* ===================== exam registration ===================== */

/**
 * The form's own load. Keyed by programme AND reg code, because a code changes
 * eligibility, pricing and the exam options the payload carries.
 */
export function examRegistrationQueryOptions(
	programType: string,
	regCode?: string,
	courseCode?: string,
) {
	return queryOptions({
		queryKey: registrationQueryKeys.exam(programType, regCode, courseCode),
		queryFn: () => fetchExamRegistration(programType, regCode, courseCode),
		enabled: Boolean(programType.trim()),
		staleTime: 5 * 60_000,
		retry: false,
		meta: { toastError: true, errorTitle: "Unable to open registration" },
	})
}

/**
 * Prices the cart.
 *
 * The request itself is the cache key, so an identical cart is never re-priced
 * and — the part that matters — a slow response for a superseded cart is never
 * applied. That is the out-of-order guard, for free.
 */
export function examFeesQueryOptions(request: FeesRequest | null) {
	return queryOptions({
		queryKey: registrationQueryKeys.fees(request),
		queryFn: () => calculateFees(request as FeesRequest),
		enabled: request !== null,
		staleTime: 60_000,
		retry: false,
		meta: { toastError: true, errorTitle: "Could not calculate fees" },
	})
}
