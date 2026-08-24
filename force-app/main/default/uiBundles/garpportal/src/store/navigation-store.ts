import { create } from "zustand"

import type { TopNavItem } from "@/config/navigation/types"

type NavigationState = {
	isMobileNavOpen: boolean
	/** Drill-down mega-menu item while the mobile panel is open; null = Account / Browse root. */
	mobileSelectedNavItem: TopNavItem | null
	/** Desktop mega-menu currently open (click); null = all closed. */
	openDesktopNavTitle: string | null
	/**
	 * Menu drilled into from the desktop "More" overflow panel; null = the
	 * overflow list itself. Only meaningful while `openDesktopNavTitle` is the
	 * overflow trigger.
	 */
	desktopMoreDrillTitle: string | null
	openMobileNav: () => void
	closeMobileNav: () => void
	toggleMobileNav: () => void
	openMobileNavItem: (item: TopNavItem) => void
	backToMobileRoot: () => void
	/** Open (or switch to) a desktop mega-menu. */
	openDesktopNav: (title: string) => void
	/** Same title closes, a different one switches — the click-trigger contract. */
	toggleDesktopNav: (title: string) => void
	closeDesktopNav: () => void
	openDesktopMoreDrill: (title: string) => void
	backToDesktopMoreRoot: () => void
}

export const useNavigationStore = create<NavigationState>((set) => ({
	isMobileNavOpen: false,
	mobileSelectedNavItem: null,
	openDesktopNavTitle: null,
	desktopMoreDrillTitle: null,
	openMobileNav: () => set({ isMobileNavOpen: true, mobileSelectedNavItem: null }),
	closeMobileNav: () => set({ isMobileNavOpen: false, mobileSelectedNavItem: null }),
	toggleMobileNav: () =>
		set((state) => ({
			isMobileNavOpen: !state.isMobileNavOpen,
			mobileSelectedNavItem: null,
		})),
	openMobileNavItem: (item) => set({ mobileSelectedNavItem: item }),
	backToMobileRoot: () => set({ mobileSelectedNavItem: null }),
	openDesktopNav: (title) => set({ openDesktopNavTitle: title, desktopMoreDrillTitle: null }),
	toggleDesktopNav: (title) =>
		set((state) => ({
			openDesktopNavTitle: state.openDesktopNavTitle === title ? null : title,
			desktopMoreDrillTitle: null,
		})),
	closeDesktopNav: () => set({ openDesktopNavTitle: null, desktopMoreDrillTitle: null }),
	openDesktopMoreDrill: (title) => set({ desktopMoreDrillTitle: title }),
	backToDesktopMoreRoot: () => set({ desktopMoreDrillTitle: null }),
}))
