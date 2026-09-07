import { useMutation, useQueryClient } from "@tanstack/react-query"

import { invalidateAccountCaches } from "@/api/account/invalidate-caches"
import { accountQueryKeys } from "@/api/account/query-options"
import {
	savePersonalInfo,
	type PersonalInfoIdentityBaseline,
	type PersonalInfoSaveInput,
} from "@/api/personal-info"

type UpdatePersonalInfoArgs = {
	input: PersonalInfoSaveInput
	/** What was hydrated, so only changed identity fields are posted. */
	baseline?: PersonalInfoIdentityBaseline
}

/** Saves identity + billing + mailing via `profile` then `addresses`; refreshes account + session caches. */
export function useUpdatePersonalInfo() {
	const queryClient = useQueryClient()

	return useMutation({
		mutationFn: ({ input, baseline }: UpdatePersonalInfoArgs) =>
			savePersonalInfo(input, baseline),
		meta: {
			successMessage: "Personal information saved",
			errorTitle: "Unable to save personal information",
		},
		onSuccess: async () => {
			await invalidateAccountCaches(queryClient)
		},
		onError: async () => {
			// The identity half may have landed before the address half was
			// refused. Mark the account stale without refetching under the open
			// dialog — a refetch would reset the form the member is still fixing.
			await queryClient.invalidateQueries({
				queryKey: accountQueryKeys.detail,
				refetchType: "none",
			})
		},
	})
}
