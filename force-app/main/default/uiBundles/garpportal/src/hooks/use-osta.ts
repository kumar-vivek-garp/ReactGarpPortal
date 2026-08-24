import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query"

import { ostaQueryOptions, saveOsta, type OstaIdInput } from "@/api/osta"
import { personalInfoQueryKeys } from "@/api/personal-info/query-options"
import { programsQueryKeys } from "@/api/programs"

/** Identity details on file (`GET /memberportal/osta`). */
export function useOsta(enabled = true) {
	return useQuery({ ...ostaQueryOptions, enabled })
}

/**
 * Save the identity details (`POST /memberportal/osta`).
 *
 * Invalidates programmes and personal info as well as this query. The write
 * lands on the member's own Contact — ID type, number, expiry, consent, and
 * the `OSTA_Collect_Info__c` prompt flag — and Apex clears its server-side
 * contact cache afterwards, so the ID panel on the programme page would
 * otherwise keep showing the old value.
 */
export function useSaveOsta() {
	const queryClient = useQueryClient()
	return useMutation({
		mutationFn: (input: OstaIdInput) => saveOsta(input),
		meta: {
			successMessage: "Identity details saved",
			errorTitle: "Unable to save your identity details",
		},
		onSuccess: async () => {
			await Promise.all([
				queryClient.invalidateQueries({ queryKey: ["osta"] }),
				queryClient.invalidateQueries({ queryKey: programsQueryKeys.all }),
				queryClient.invalidateQueries({ queryKey: personalInfoQueryKeys.all }),
			])
		},
	})
}
