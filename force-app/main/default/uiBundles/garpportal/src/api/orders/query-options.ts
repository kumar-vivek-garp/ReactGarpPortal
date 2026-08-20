import { queryOptions } from "@tanstack/react-query"

import { fetchOrderDetail } from "@/api/orders/order-detail"
import { fetchOrders } from "@/api/orders/orders"

export const ordersQueryKeys = {
	all: ["orders"] as const,
	list: ["orders", "list"] as const,
	detail: (orderNumber: string) =>
		["orders", "detail", orderNumber.trim()] as const,
}

export const ordersQueryOptions = queryOptions({
	queryKey: ordersQueryKeys.list,
	queryFn: fetchOrders,
	staleTime: 60_000,
	retry: false,
	meta: {
		toastError: true,
		errorTitle: "Unable to load orders",
	},
})

export function orderDetailQueryOptions(orderNumber: string) {
	const key = orderNumber.trim()
	return queryOptions({
		queryKey: ordersQueryKeys.detail(key),
		queryFn: () => fetchOrderDetail(key),
		enabled: Boolean(key),
		staleTime: 60_000,
		retry: false,
		meta: {
			toastError: true,
			errorTitle: "Unable to load order details",
		},
	})
}
