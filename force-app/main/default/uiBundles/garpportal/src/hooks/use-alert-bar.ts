import { useCallback, useMemo } from "react"
import { useQuery } from "@tanstack/react-query"

import { alertBarQueryOptions } from "@/api/alert-bar"
import { toAlertBarModel } from "@/lib/alert-bar-presentation"
import { type AlertBarPhase, useAlertBarStore } from "@/store/alert-bar-store"

/**
 * The portal-wide exam alert, plus where it is in its minimise cycle.
 *
 * The card, the desktop trigger and the mobile trigger all call this. The
 * query is shared by React Query and the phase by the store, so the three
 * surfaces cannot disagree about which alert exists or whether it is currently
 * a card or a button.
 *
 * The phase is deliberately in-memory. It lasts as long as the tab does, so it
 * survives navigation between pages but not a reload, and a deadline therefore
 * reasserts itself on the member's next visit. That is the point: this
 * minimises, it does not dismiss.
 *
 * It is also keyed on the alert itself rather than held as a bare flag. These
 * are deadlines, so a member who has minimised "you have not booked a seat"
 * must still be shown the *next* alert when that one is resolved and a
 * different one takes its place — keying makes that automatic instead of
 * something an effect has to notice.
 */
export function useAlertBar() {
	const { data } = useQuery(alertBarQueryOptions)
	const storedPhase = useAlertBarStore((state) => state.phase)
	const phaseFor = useAlertBarStore((state) => state.phaseFor)
	const setPhase = useAlertBarStore((state) => state.setPhase)

	const model = useMemo(() => toAlertBarModel(data), [data])
	const key = data?.alertStatus?.trim() ?? null

	const phase: AlertBarPhase =
		key !== null && phaseFor === key ? storedPhase : "expanded"

	const to = useCallback(
		(next: AlertBarPhase) => setPhase(next, key),
		[setPhase, key],
	)

	return {
		model,
		phase,
		/** Chevron pressed: start the flight into the toolbar. */
		minimise: useCallback(() => to("minimising"), [to]),
		/** Toolbar trigger pressed: start the flight back to the corner. */
		restore: useCallback(() => to("restoring"), [to]),
		/** The card has landed — the toolbar button may now appear. */
		settleMinimised: useCallback(() => to("minimised"), [to]),
		/** The card is home. */
		settleExpanded: useCallback(() => to("expanded"), [to]),
	}
}
