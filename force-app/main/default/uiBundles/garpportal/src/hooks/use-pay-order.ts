import { useMutation, useQueryClient } from "@tanstack/react-query"

import { ordersQueryKeys, payOrder } from "@/api/orders"
import {
	setOrdersCheckoutSessionCookie,
	stripeOrdersCheckoutUrl,
} from "@/config/order-history"

/**
 * Prepares payment then either closes a zero-value order (201) or sends the
 * member to Stripe checkout (200) — same branch as legacy garpApp2.
 */
export function usePayOrder() {
	const queryClient = useQueryClient()

	return useMutation({
		mutationFn: (orderId: string) => payOrder(orderId),
		meta: {
			errorTitle: "Unable to prepare payment",
		},
		onSuccess: async (result, orderId) => {
			await queryClient.invalidateQueries({
				queryKey: ordersQueryKeys.all,
			})

			if (result.statusCode === 201) {
				return
			}

			setOrdersCheckoutSessionCookie(orderId)
			window.location.assign(stripeOrdersCheckoutUrl(orderId))
		},
	})
}
