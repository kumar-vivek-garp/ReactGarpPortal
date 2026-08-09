import { useQuery } from "@tanstack/react-query"

import { membershipQueryOptions } from "@/api/membership/query-options"

/** Membership benefits from `GET /memberportal/membership`. */
export function useMembership() {
	return useQuery(membershipQueryOptions)
}
