import { useEffect, useState } from "react"

import type { AccountSaveState } from "@/components/molecules/account-section-card"

/** How long the "Saved" confirmation lingers before fading back to idle. */
const SAVED_HOLD_MS = 2200

type MutationLike = {
	isPending: boolean
	isSuccess: boolean
	/** Bumped on every mutate, so repeated saves re-show the confirmation. */
	submittedAt: number
}

/**
 * Turns a React Query mutation into the card header's save indicator state.
 *
 * The autosave cards write on change and rely on a global Sonner toast, which
 * is easy to miss when the control that changed is still under the cursor.
 * This keeps the confirmation next to the thing that saved.
 */
export function useSaveState(mutation: MutationLike): AccountSaveState {
	const { isPending, isSuccess, submittedAt } = mutation
	/** The `submittedAt` whose confirmation has already been shown and expired. */
	const [expiredAt, setExpiredAt] = useState(0)

	useEffect(() => {
		if (isPending || !isSuccess) return
		// Only the timer writes state — "saved" itself is derived below, so the
		// effect never triggers a cascading render on the success frame.
		const timer = window.setTimeout(
			() => setExpiredAt(submittedAt),
			SAVED_HOLD_MS,
		)
		return () => window.clearTimeout(timer)
		// `submittedAt` re-arms the timer when the same mutation succeeds again.
	}, [isPending, isSuccess, submittedAt])

	if (isPending) return "saving"
	return isSuccess && expiredAt !== submittedAt ? "saved" : "idle"
}
