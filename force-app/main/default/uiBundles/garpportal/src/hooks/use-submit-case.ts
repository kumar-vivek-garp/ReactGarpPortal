import { useMutation } from "@tanstack/react-query"

import { submitCase, type SubmitCaseInput } from "@/api/help-center"

/** Submits an Open Support Case via Apex REST. */
export function useSubmitCase() {
	return useMutation({
		mutationFn: (input: SubmitCaseInput) => submitCase(input),
		meta: {
			successMessage:
				"Thank you for your submission. A representative from Member Services will be in touch with you shortly.",
			errorTitle: "Unable to submit support case",
		},
	})
}
