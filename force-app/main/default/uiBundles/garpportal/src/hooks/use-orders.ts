import { useQuery } from "@tanstack/react-query"

import { ordersQueryOptions } from "@/api/orders/query-options"

/** Purchase history from `GET /memberportal/orders`. Fetch only when `enabled`. */
export function useOrders(enabled: boolean) {
	return useQuery({
		...ordersQueryOptions,
		enabled,
	})
}
