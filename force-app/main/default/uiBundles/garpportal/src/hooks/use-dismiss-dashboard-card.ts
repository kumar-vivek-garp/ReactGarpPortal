import { useMutation, useQueryClient } from "@tanstack/react-query"

import { dashboardQueryKeys, dismissCard } from "@/api/dashboard"

/** Persists a dismissed dashboard card; caller should hide it optimistically. */
export function useDismissDashboardCard() {
	const queryClient = useQueryClient()

	return useMutation({
		mutationFn: (key: string) => dismissCard(key),
		meta: {
			errorTitle: "Unable to dismiss card",
		},
		onSuccess: async () => {
			await queryClient.invalidateQueries({ queryKey: dashboardQueryKeys.view })
		},
	})
}
