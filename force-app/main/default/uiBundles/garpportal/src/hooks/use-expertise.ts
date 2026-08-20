import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query"

import {
	expertiseQueryKeys,
	expertiseQueryOptions,
	saveExpertise,
	type ExpertiseValues,
} from "@/api/expertise"

/** SME registration fields from `GET /memberportal/expertise`. */
export function useExpertise(enabled = true) {
	return useQuery({ ...expertiseQueryOptions, enabled })
}

/** Writes SME multi-selects via `POST /memberportal/expertise`. */
export function useSaveExpertise() {
	const queryClient = useQueryClient()

	return useMutation({
		mutationFn: (values: ExpertiseValues) => saveExpertise(values),
		meta: {
			successMessage: "Expertise saved",
			errorTitle: "Unable to save expertise",
		},
		onSuccess: async () => {
			await queryClient.invalidateQueries({
				queryKey: expertiseQueryKeys.view,
			})
		},
	})
}
