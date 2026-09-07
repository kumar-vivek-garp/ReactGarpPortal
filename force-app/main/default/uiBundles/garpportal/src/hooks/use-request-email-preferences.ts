import { useMutation, useQueryClient } from "@tanstack/react-query"

import {
	invalidateContactPreferencesCaches,
	requestEmailPreferences,
} from "@/api/contact-preferences"

/** Stamps the email-pref date so the member receives preference-centre instructions. */
export function useRequestEmailPreferences() {
	const queryClient = useQueryClient()

	return useMutation({
		mutationFn: () => requestEmailPreferences(),
		meta: {
			errorTitle: "Unable to request email preferences",
		},
		onSuccess: async () => {
			await invalidateContactPreferencesCaches(queryClient)
		},
	})
}
