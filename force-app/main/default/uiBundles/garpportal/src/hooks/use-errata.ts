import { useMutation, useQuery } from "@tanstack/react-query"

import {
	errataFormQueryOptions,
	submitErrataWithFile,
	type ErrataSubmission,
	type ErrataSubmitOutcome,
} from "@/api/errata"

/** The cascade's options for one programme. Resolves `null` when not entitled. */
export function useErrataForm(programType: string, enabled = true) {
	return useQuery({
		...errataFormQueryOptions(programType),
		enabled: enabled && Boolean(programType.trim()),
	})
}

type SubmitArgs = {
	submission: ErrataSubmission
	file?: File | null
}

/**
 * Files a report and attaches its file.
 *
 * The submit-then-attach rule lives in `submitErrataWithFile` — an attachment
 * failure resolves with a reason rather than rejecting, because by then the
 * report is already filed.
 *
 * No success toast: the page swaps to a receipt, which says more than a toast
 * and does not disappear.
 */
export function useSubmitErrata() {
	return useMutation({
		mutationFn: ({ submission, file }: SubmitArgs) =>
			submitErrataWithFile(submission, file),
		meta: { errorTitle: "Unable to submit your report" },
	})
}

export type { ErrataSubmitOutcome }
