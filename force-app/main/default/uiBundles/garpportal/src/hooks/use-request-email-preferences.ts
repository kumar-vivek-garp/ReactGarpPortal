import { useMutation, useQueryClient } from "@tanstack/react-query"

import {
	invalidateContactPreferencesCaches,
	requestEmailPreferences,
} from "@/api/contact-preferences"

/** Stamps email-pref datetime so the member receives preference-center instructions. */
export function useRequestEmailPreferences() {
	const queryClient = useQueryClient()

	return useMutation({
		mutationFn: (contactId: string) => requestEmailPreferences(contactId),
		meta: {
			errorTitle: "Unable to request email preferences",
		},
		onSuccess: async (_data, contactId) => {
			await invalidateContactPreferencesCaches(queryClient, contactId)
		},
	})
}
