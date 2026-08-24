import { create } from "zustand"
import { persist } from "zustand/middleware"

import {
	BENTO_STORAGE_KEY,
	BENTO_STORAGE_VERSION,
	type BentoScope,
} from "@/config/bento"

export type BentoLayout = {
	/**
	 * Card ids per column, keyed by how many columns were on screen.
	 *
	 * Keyed by count because a one-column arrangement genuinely cannot express a
	 * two-column one — collapsing them would silently destroy the desktop layout
	 * the first time the member rearranged anything on a phone.
	 */
	columns: Partial<Record<string, string[][]>>
}

type BentoLayoutState = {
	/** A scope is absent until the member has actually rearranged that page. */
	layouts: Partial<Record<BentoScope, BentoLayout>>
	setColumns: (
		scope: BentoScope,
		columnCount: number,
		columns: string[][],
	) => void
	reset: (scope: BentoScope) => void
}

/**
 * Remembers each bento page's card arrangement.
 *
 * Local only, by design — this is a display preference, not profile data, so it
 * needs no round trip and no `AccountView` field. Same shape of decision as
 * `useListViewStore`, scoped per page for the same reason: two bentos
 * reasonably want different arrangements.
 *
 * `persist` over the default `localStorage` rehydrates synchronously during
 * store creation, so the very first render is already the member's layout —
 * which is what lets the loading skeleton show the right bones instead of the
 * grid re-shuffling the moment data lands.
 */
export const useBentoLayoutStore = create<BentoLayoutState>()(
	persist(
		(set) => ({
			layouts: {},

			setColumns: (scope, columnCount, columns) =>
				set((state) => ({
					layouts: {
						...state.layouts,
						[scope]: {
							columns: {
								...state.layouts[scope]?.columns,
								[String(columnCount)]: columns,
							},
						},
					},
				})),

			reset: (scope) =>
				set((state) => {
					const layouts = { ...state.layouts }
					delete layouts[scope]
					return { layouts }
				}),
		}),
		{ name: BENTO_STORAGE_KEY, version: BENTO_STORAGE_VERSION },
	),
)
