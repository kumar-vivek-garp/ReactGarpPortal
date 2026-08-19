import { create } from "zustand"
import { persist } from "zustand/middleware"

import {
	LIST_VIEW_STORAGE_KEY,
	type ListView,
	type ListViewScope,
} from "@/config/list-view"

type ListViewState = {
	/**
	 * Remembered layout per page. A scope is absent until the member has
	 * explicitly picked one there; only then does it win over that page's default.
	 */
	preferred: Partial<Record<ListViewScope, ListView>>
	setPreferred: (scope: ListViewScope, view: ListView) => void
}

/**
 * Remembers each collection page's grid/list choice.
 *
 * The URL still carries `?view=` so links stay shareable, but detail routes have
 * no such param — navigating into a record and back would otherwise drop the
 * choice and silently fall back to the page default. Scoped rather than global
 * because a catalogue and a personal list reasonably want different layouts.
 */
export const useListViewStore = create<ListViewState>()(
	persist(
		(set) => ({
			preferred: {},
			setPreferred: (scope, view) =>
				set((state) => ({ preferred: { ...state.preferred, [scope]: view } })),
		}),
		{ name: LIST_VIEW_STORAGE_KEY },
	),
)
