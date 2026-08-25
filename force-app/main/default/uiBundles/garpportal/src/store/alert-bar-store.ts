import { create } from "zustand"

/**
 * Where the portal-wide exam alert is in its minimise / restore cycle.
 *
 * Two states would be enough to describe the *look* — a card or a toolbar
 * button — but not the motion between them. The card has to finish travelling
 * into the toolbar before the button appears, and grow back out of it on the
 * way home, so the two transient phases are real states that both surfaces read
 * rather than a timing detail hidden inside one component.
 */
export type AlertBarPhase = "expanded" | "minimising" | "minimised" | "restoring"

/** Which toolbar a trigger belongs to. Both are mounted; CSS picks one. */
export type AlertBarPlacement = "desktop" | "mobile"

type AlertBarState = {
	phase: AlertBarPhase
	/**
	 * The `alertStatus` the phase was set on.
	 *
	 * A member who minimises "you have not booked a seat" must still be shown
	 * the *next* alert when that one is resolved and a different one takes its
	 * place. Keying the phase makes that automatic: a mismatch reads as
	 * `expanded` without anything having to notice the change.
	 */
	phaseFor: string | null
	/**
	 * The live trigger elements, so the card can measure where to fly to.
	 *
	 * Both toolbars are always in the DOM and hidden from each other by a media
	 * query, so this holds both and the reader picks whichever one measures.
	 */
	anchors: Record<AlertBarPlacement, HTMLElement | null>
	setPhase: (phase: AlertBarPhase, key: string | null) => void
	setAnchor: (placement: AlertBarPlacement, element: HTMLElement | null) => void
}

export const useAlertBarStore = create<AlertBarState>((set) => ({
	phase: "expanded",
	phaseFor: null,
	anchors: { desktop: null, mobile: null },
	setPhase: (phase, key) => set({ phase, phaseFor: key }),
	setAnchor: (placement, element) =>
		set((state) => ({ anchors: { ...state.anchors, [placement]: element } })),
}))
