import { useMutation, useQueryClient } from "@tanstack/react-query"

import { invalidateAccountCaches } from "@/api/account/invalidate-caches"
import {
	turnOffMembershipAutoRenew,
	turnOnMembershipAutoRenew,
} from "@/api/account/auto-renew"

export function useTurnOffMembershipAutoRenew() {
	const queryClient = useQueryClient()

	return useMutation({
		mutationFn: turnOffMembershipAutoRenew,
		meta: {
			successMessage: "Auto-renew is off",
			errorTitle: "Unable to turn off auto-renew",
		},
		onSuccess: async () => {
			await invalidateAccountCaches(queryClient)
		},
	})
}

/**
 * One hop to Stripe, as in GarpAppv1: the server answers with the setup page
 * and the browser leaves for it. Nothing is invalidated or announced here —
 * the contract only flips once Stripe's webhook lands, and the page the
 * member returns to (`?status=autorenewsetupcomplete`) says so.
 */
export function useTurnOnMembershipAutoRenew() {
	return useMutation({
		mutationFn: (returnUrl: string) => turnOnMembershipAutoRenew(returnUrl),
		meta: {
			errorTitle: "Unable to turn on auto-renew",
		},
		onSuccess: (data) => {
			if (data.setupUrl) window.location.assign(data.setupUrl)
		},
	})
}
