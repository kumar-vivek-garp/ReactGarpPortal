import { queryOptions } from "@tanstack/react-query"

import { fetchExamSetupForm } from "@/api/exam-setup/exam-setup"
import type { ExamSetupProgramType } from "@/api/exam-setup/types"

export const examSetupQueryKeys = {
	all: ["exam-setup"] as const,
	form: (programType: ExamSetupProgramType) =>
		["exam-setup", "form", programType] as const,
}

/**
 * The wizard's form for one programme.
 *
 * Not cached: the administration and site lists close on real dates, and a
 * successful save changes what the next visit should offer. Serving a stale
 * copy here would show a member a sitting they can no longer choose.
 *
 * `toastError` stays on — unlike the alert bar, this page IS what the member
 * asked for, so a failure should say so out loud.
 */
export function examSetupQueryOptions(programType: ExamSetupProgramType) {
	return queryOptions({
		queryKey: examSetupQueryKeys.form(programType),
		queryFn: () => fetchExamSetupForm(programType),
		staleTime: 0,
		retry: false,
		meta: {
			toastError: true,
			errorTitle: "Unable to load exam setup",
		},
	})
}
