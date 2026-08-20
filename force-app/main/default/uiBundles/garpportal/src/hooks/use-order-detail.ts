import { useQuery } from "@tanstack/react-query"

import { orderDetailQueryOptions } from "@/api/orders"

/** One order from `GET /memberportal/orderDetail`. */
export function useOrderDetail(orderNumber: string) {
	return useQuery(orderDetailQueryOptions(orderNumber))
}
