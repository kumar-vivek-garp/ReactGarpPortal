import { useMutation, useQueryClient } from "@tanstack/react-query"

import { cancelOrder, ordersQueryKeys } from "@/api/orders"
import { notifySuccess } from "@/api/client"

/** Cancels an unpaid order, then refreshes purchase history caches. */
export function useCancelOrder() {
	const queryClient = useQueryClient()

	return useMutation({
		mutationFn: (orderId: string) => cancelOrder(orderId),
		meta: {
			errorTitle: "Unable to cancel order",
		},
		onSuccess: async () => {
			await queryClient.invalidateQueries({
				queryKey: ordersQueryKeys.all,
			})
			notifySuccess("Order cancelled")
		},
	})
}
