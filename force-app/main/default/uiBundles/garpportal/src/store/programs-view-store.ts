import { create } from "zustand"
import { persist } from "zustand/middleware"

import { PROGRAMS_VIEW_STORAGE_KEY, type ProgramsView } from "@/config/programs"

type ProgramsViewState = {
	/**
	 * `null` until the member has explicitly picked a layout. Once set it wins
	 * over the per-bucket default, so a choice survives leaving the listing for a
	 * program detail page — and a full reload.
	 */
	preferred: ProgramsView | null
	setPreferred: (view: ProgramsView) => void
}

/**
 * Remembers the Programs grid/list choice.
 *
 * The URL still carries `?view=` so links stay shareable, but the detail route
 * has no such param — navigating into a program and back used to drop it and
 * silently fall back to the per-bucket default. Persisting the choice is what
 * makes "respect what I picked" hold across that round trip.
 */
export const useProgramsViewStore = create<ProgramsViewState>()(
	persist(
		(set) => ({
			preferred: null,
			setPreferred: (preferred) => set({ preferred }),
		}),
		{ name: PROGRAMS_VIEW_STORAGE_KEY },
	),
)
