import { useQuery } from "@tanstack/react-query"

import { adQueryOptions } from "@/api/dashboard"

/**
 * The dashboard cross-sell (`GET /memberportal/ad`).
 *
 * Silent on failure — this is a recommendation, and a member does not need a
 * toast telling them an advert could not load. The card is simply dropped.
 */
export function useAd(enabled = true) {
	return useQuery({ ...adQueryOptions, enabled })
}
