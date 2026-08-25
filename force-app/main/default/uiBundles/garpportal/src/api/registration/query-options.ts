import { queryOptions } from "@tanstack/react-query"

import { fetchAffiliateRegistration } from "@/api/registration/affiliate"

export const registrationQueryKeys = {
	all: ["registration"] as const,
	affiliate: ["registration", "affiliate"] as const,
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
