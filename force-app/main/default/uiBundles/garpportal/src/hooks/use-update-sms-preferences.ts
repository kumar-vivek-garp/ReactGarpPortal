import { useMutation, useQueryClient } from "@tanstack/react-query"

import {
	invalidateContactPreferencesCaches,
	updateSmsPreferences,
	type UpdateSmsPreferencesInput,
} from "@/api/contact-preferences"

/** Saves SMS promotional + registration checkboxes through `/memberportal/profile`. */
export function useUpdateSmsPreferences() {
	const queryClient = useQueryClient()

	return useMutation({
		mutationFn: (input: UpdateSmsPreferencesInput) => updateSmsPreferences(input),
		meta: {
			errorTitle: "Unable to update SMS preferences",
		},
		onSuccess: async () => {
			await invalidateContactPreferencesCaches(queryClient)
		},
	})
}
