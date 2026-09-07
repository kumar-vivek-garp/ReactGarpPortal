import { useMutation, useQueryClient } from "@tanstack/react-query"

import { AppError } from "@/api/client"
import {
	programsQueryKeys,
	saveEppOptIn,
	toEppExamType,
} from "@/api/programs"

/**
 * "Need Help Studying?" — opts the member into GARP's exam-prep-provider
 * network. The programme detail is refetched afterwards so
 * `examResources.IsOptedIntoEPP` flips and the offer disappears.
 *
 * No success toast: the dialog carries the thank-you copy itself.
 */
export function useEppOptIn(programType: string) {
	const queryClient = useQueryClient()
	const examType = toEppExamType(programType)

	return useMutation({
		mutationFn: (optIn: boolean) => {
			if (!examType) {
				throw new AppError({
					messages: ["This program has no exam-prep opt-in."],
					status: 400,
				})
			}
			return saveEppOptIn({ examType, optIn })
		},
		meta: { errorTitle: "Unable to record your answer" },
		onSuccess: async () => {
			await queryClient.invalidateQueries({
				queryKey: programsQueryKeys.detail(programType),
			})
		},
	})
}
