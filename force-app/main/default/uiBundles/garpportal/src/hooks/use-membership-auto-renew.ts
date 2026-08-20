import { useMutation, useQueryClient } from "@tanstack/react-query"

import { invalidateAccountCaches } from "@/api/account/invalidate-caches"
import {
	turnOffMembershipAutoRenew,
	turnOnMembershipAutoRenew,
} from "@/api/account/auto-renew"
import { notifySuccess } from "@/api/client"
import { stripeSetupCheckoutUrl } from "@/config/membership-account"

export function useTurnOffMembershipAutoRenew(contactId: string) {
	const queryClient = useQueryClient()

	return useMutation({
		mutationFn: turnOffMembershipAutoRenew,
		meta: {
			successMessage: "Auto-renew is off",
			errorTitle: "Unable to turn off auto-renew",
		},
		onSuccess: async () => {
			await invalidateAccountCaches(queryClient, contactId)
		},
	})
}

export function useTurnOnMembershipAutoRenew(contactId: string) {
	const queryClient = useQueryClient()

	return useMutation({
		mutationFn: turnOnMembershipAutoRenew,
		meta: {
			errorTitle: "Unable to turn on auto-renew",
		},
		onSuccess: async (data) => {
			if (data.needPaymentInfo) {
				window.location.assign(stripeSetupCheckoutUrl(data.orderId))
				return
			}
			await invalidateAccountCaches(queryClient, contactId)
			notifySuccess("Auto-renew is on")
		},
	})
}
