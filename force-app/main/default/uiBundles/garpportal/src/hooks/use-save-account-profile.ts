import { useMutation, useQueryClient } from "@tanstack/react-query"

import { invalidateAccountCaches } from "@/api/account/invalidate-caches"
import {
	saveAccountProfile,
	type AccountProfileValues,
} from "@/api/account/save-profile"

/** Saves Contact profile fields via REST `/memberportal/profile`. */
export function useSaveAccountProfile(contactId: string) {
	const queryClient = useQueryClient()

	return useMutation({
		mutationFn: (values: AccountProfileValues) => saveAccountProfile(values),
		meta: {
			successMessage: "Career information saved",
			errorTitle: "Unable to save career information",
		},
		onSuccess: async () => {
			await invalidateAccountCaches(queryClient, contactId)
		},
	})
}
