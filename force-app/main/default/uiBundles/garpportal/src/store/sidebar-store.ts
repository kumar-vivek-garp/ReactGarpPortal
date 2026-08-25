import { create } from "zustand"
import { persist } from "zustand/middleware"

import { SIDEBAR_STORAGE_KEY } from "@/config/navigation/sidebar"

type SidebarState = {
	/** Desktop rail collapsed to icons. Irrelevant below `--breakpoint-app`. */
	isCollapsed: boolean
	setCollapsed: (collapsed: boolean) => void
	toggleCollapsed: () => void
}

/**
 * Remembers whether the desktop sidebar is collapsed to icons.
 *
 * Its own store rather than a field on `useNavigationStore`: that one holds
 * transient open/closed menu state which must never survive a reload, and
 * wrapping it in `persist` to carry one boolean would put every one of those
 * fields one `partialize` mistake away from being restored.
 *
 * `persist` over the default `localStorage` rehydrates synchronously during
 * store creation, so the very first paint is already the member's choice —
 * which is what prevents an expanded rail flashing and then snapping shut.
 *
 * Collapsed is the default, so a member who has never touched the control gets
 * the icon rail and the wider content column. Because `persist` only writes on
 * an actual toggle, an absent key means "no preference" rather than "expanded",
 * and anyone who has already chosen expanded keeps it.
 */
export const useSidebarStore = create<SidebarState>()(
	persist(
		(set) => ({
			isCollapsed: true,
			setCollapsed: (collapsed) => set({ isCollapsed: collapsed }),
			toggleCollapsed: () =>
				set((state) => ({ isCollapsed: !state.isCollapsed })),
		}),
		{ name: SIDEBAR_STORAGE_KEY },
	),
)
