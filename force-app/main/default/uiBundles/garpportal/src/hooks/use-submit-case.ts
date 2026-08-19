import { useMutation, useQueryClient } from "@tanstack/react-query"

import {
	helpCenterQueryKeys,
	submitCase,
	type SubmitCaseInput,
} from "@/api/help-center"

/** Submits an Open Support Case via Apex REST, then refreshes the case list. */
export function useSubmitCase() {
	const queryClient = useQueryClient()

	return useMutation({
		mutationFn: (input: SubmitCaseInput) => submitCase(input),
		meta: {
			successMessage:
				"Thank you for your submission. A representative from Member Services will be in touch with you shortly.",
			errorTitle: "Unable to submit support case",
		},
		onSuccess: async () => {
			await queryClient.invalidateQueries({
				queryKey: helpCenterQueryKeys.cases,
			})
		},
	})
}
