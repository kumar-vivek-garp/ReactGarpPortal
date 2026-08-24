import { useCallback, useState } from "react"
import { useMutation, useQueryClient } from "@tanstack/react-query"

import { notifyWithUndo } from "@/api/client"
import { dashboardQueryKeys, dismissCard, restoreCard } from "@/api/dashboard"
import { DASHBOARD_CARD_VISIBILITY } from "@/config/dashboard"

/**
 * Hiding a dashboard card, and taking it back.
 *
 * The two directions are one concern because the optimistic state is shared:
 * `hiddenKeys` is what the member sees between clicking and the dashboard
 * refetching, in both directions. Splitting them into two hooks would mean two
 * copies of that list disagreeing with each other.
 *
 * Dismiss is optimistic because the card is already on screen. Restore cannot
 * be — the card is gone from the server's manifest, so there is nothing to
 * re-render until the refetch brings it back. Clearing the key is still needed
 * so the filter does not hide it again on arrival.
 */
export function useDashboardCardVisibility() {
	const queryClient = useQueryClient()
	const [hiddenKeys, setHiddenKeys] = useState<string[]>([])

	const invalidate = useCallback(
		() => queryClient.invalidateQueries({ queryKey: dashboardQueryKeys.view }),
		[queryClient],
	)

	const dismissMutation = useMutation({
		mutationFn: (key: string) => dismissCard(key),
		meta: { errorTitle: "Unable to dismiss card" },
		onSuccess: invalidate,
	})

	const restoreMutation = useMutation({
		mutationFn: (key: string) => restoreCard(key),
		meta: { errorTitle: "Unable to restore card" },
		onSuccess: invalidate,
	})

	const restore = useCallback(
		(key: string) => {
			setHiddenKeys((current) => current.filter((k) => k !== key))
			restoreMutation.mutate(key, {
				// Put it back in the hidden list: the server still has it muted,
				// so showing it as restored would be a lie until a retry succeeds.
				onError: () =>
					setHiddenKeys((current) =>
						current.includes(key) ? current : [...current, key],
					),
			})
		},
		[restoreMutation],
	)

	const dismiss = useCallback(
		(key: string) => {
			setHiddenKeys((current) =>
				current.includes(key) ? current : [...current, key],
			)
			dismissMutation.mutate(key, {
				// Only offer undo once Apex has actually recorded the dismissal —
				// undoing a write that never landed would toast a second error.
				onSuccess: () =>
					notifyWithUndo(
						DASHBOARD_CARD_VISIBILITY.dismissedMessage,
						() => restore(key),
						DASHBOARD_CARD_VISIBILITY.undoLabel,
					),
				onError: () =>
					setHiddenKeys((current) => current.filter((k) => k !== key)),
			})
		},
		[dismissMutation, restore],
	)

	return { hiddenKeys, dismiss, restore }
}
