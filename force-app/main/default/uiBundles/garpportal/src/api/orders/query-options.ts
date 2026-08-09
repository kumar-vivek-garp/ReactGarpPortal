import { queryOptions } from "@tanstack/react-query"

import { fetchOrders } from "@/api/orders/orders"

export const ordersQueryKeys = {
	all: ["orders"] as const,
	list: ["orders", "list"] as const,
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
