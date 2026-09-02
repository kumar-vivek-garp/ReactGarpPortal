import { queryOptions } from "@tanstack/react-query"

import { fetchAffiliateRegistration } from "@/api/registration/affiliate"
import {
	fetchEventOptions,
	fetchEventRegistration,
} from "@/api/registration/event-registration"
import type { EventVariant } from "@/api/registration/event-types"
import {
	calculateFees,
	fetchExamRegistration,
	fetchRegistrationOptions,
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
	/** Company/school typeahead lists — one static payload per session. */
	options: ["registration", "options"] as const,
	/** One event's registration load — variant + id name the record family. */
	event: (variant: EventVariant, eventId: string) =>
		["registration", "event", variant, eventId.trim()] as const,
	/** Country list for the webcast address card — static per session. */
	eventOptions: ["registration", "event-options"] as const,
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
 * The OSTA company/school suggestion lists — ~2,000 rows, so a second request
 * on purpose, made only once the OSTA card is actually on screen. No error
 * toast: the fields are plain inputs without it, and the legacy swallows this
 * failure the same way — autocomplete just stays empty.
 */
export const registrationOptionsQueryOptions = queryOptions({
	queryKey: registrationQueryKeys.options,
	queryFn: fetchRegistrationOptions,
	staleTime: Infinity,
	retry: false,
})

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

/* ===================== event registration ===================== */

/**
 * One event's registration load. Not-found and ineligible both arrive as data
 * (200 with `event_x: null` / `eligibility`), so an actual error here is
 * transport or configuration — `retry: false` for the same reason as the
 * affiliate load above.
 */
export function eventRegistrationQueryOptions(
	variant: EventVariant,
	eventId: string,
) {
	return queryOptions({
		queryKey: registrationQueryKeys.event(variant, eventId),
		queryFn: () => fetchEventRegistration(eventId, variant),
		enabled: Boolean(eventId.trim()),
		staleTime: 5 * 60_000,
		retry: false,
		meta: { toastError: true, errorTitle: "Unable to open registration" },
	})
}

/**
 * Countries for the webcast address card — static reference data. No toast:
 * the card renders its selects empty-but-usable text fields without it, and
 * the submit-side validation still holds.
 */
export const eventOptionsQueryOptions = queryOptions({
	queryKey: registrationQueryKeys.eventOptions,
	queryFn: fetchEventOptions,
	staleTime: Infinity,
	retry: false,
})

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
