import { create } from "zustand"

import type { TopNavItem } from "@/lib/navigation/types"

/** Grace period so the cursor can cross the toolbar → panel gap without closing. */
const DESKTOP_NAV_CLOSE_DELAY_MS = 300

let desktopNavCloseTimer: ReturnType<typeof setTimeout> | null = null

function clearDesktopNavCloseTimer() {
	if (desktopNavCloseTimer !== null) {
		clearTimeout(desktopNavCloseTimer)
		desktopNavCloseTimer = null
	}
}

type NavigationState = {
	isMobileNavOpen: boolean
	/** Drill-down mega-menu item while the mobile panel is open; null = Account / Browse root. */
	mobileSelectedNavItem: TopNavItem | null
	/** Desktop mega-menu currently open (hover); null = all closed. */
	openDesktopNavTitle: string | null
	openMobileNav: () => void
	closeMobileNav: () => void
	toggleMobileNav: () => void
	openMobileNavItem: (item: TopNavItem) => void
	backToMobileRoot: () => void
	/** Open (or switch) a desktop mega-menu and cancel any pending close. */
	openDesktopNav: (title: string) => void
	/** Close after a short delay — cancelled if the cursor re-enters the menu. */
	scheduleCloseDesktopNav: () => void
	cancelCloseDesktopNav: () => void
	/** Immediate close (Escape, overlay click). */
	closeDesktopNav: () => void
	/** @deprecated Prefer openDesktopNav / closeDesktopNav */
	setOpenDesktopNavTitle: (title: string | null) => void
}

export const useNavigationStore = create<NavigationState>((set) => ({
	isMobileNavOpen: false,
	mobileSelectedNavItem: null,
	openDesktopNavTitle: null,
	openMobileNav: () => set({ isMobileNavOpen: true, mobileSelectedNavItem: null }),
	closeMobileNav: () => set({ isMobileNavOpen: false, mobileSelectedNavItem: null }),
	toggleMobileNav: () =>
		set((state) =>
			state.isMobileNavOpen
				? { isMobileNavOpen: false, mobileSelectedNavItem: null }
				: { isMobileNavOpen: true, mobileSelectedNavItem: null }
		),
	openMobileNavItem: (item) => set({ mobileSelectedNavItem: item }),
	backToMobileRoot: () => set({ mobileSelectedNavItem: null }),
	openDesktopNav: (title) => {
		clearDesktopNavCloseTimer()
		set({ openDesktopNavTitle: title })
	},
	scheduleCloseDesktopNav: () => {
		clearDesktopNavCloseTimer()
		desktopNavCloseTimer = setTimeout(() => {
			set({ openDesktopNavTitle: null })
			desktopNavCloseTimer = null
		}, DESKTOP_NAV_CLOSE_DELAY_MS)
	},
	cancelCloseDesktopNav: () => {
		clearDesktopNavCloseTimer()
	},
	closeDesktopNav: () => {
		clearDesktopNavCloseTimer()
		set({ openDesktopNavTitle: null })
	},
	setOpenDesktopNavTitle: (title) => {
		clearDesktopNavCloseTimer()
		set({ openDesktopNavTitle: title })
	},
}))
