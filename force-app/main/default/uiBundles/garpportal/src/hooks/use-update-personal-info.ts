import { useMutation, useQueryClient } from "@tanstack/react-query"

import { invalidateAccountCaches } from "@/api/account/invalidate-caches"
import {
	savePersonalInfo,
	type PersonalInfoSaveInput,
} from "@/api/personal-info"

/** Saves personal + billing + mailing via GraphQL; refreshes account + session caches. */
export function useUpdatePersonalInfo() {
	const queryClient = useQueryClient()

	return useMutation({
		mutationFn: (input: PersonalInfoSaveInput) => savePersonalInfo(input),
		meta: {
			successMessage: "Personal information saved",
			errorTitle: "Unable to save personal information",
		},
		onSuccess: async (_data, variables) => {
			await invalidateAccountCaches(queryClient, variables.contactId)
		},
	})
}
