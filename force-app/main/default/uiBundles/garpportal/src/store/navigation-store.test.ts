import { beforeEach, describe, expect, it } from "vitest"

import type { TopNavItem } from "@/config/navigation/types"
import { useNavigationStore } from "@/store/navigation-store"

// Only `title` is read by the store; the rest is mega-menu render data.
const programsItem = { title: "Programs" } as TopNavItem

beforeEach(() => {
	useNavigationStore.setState({
		isMobileNavOpen: false,
		mobileSelectedNavItem: null,
		openDesktopNavTitle: null,
		desktopMoreDrillTitle: null,
	})
})

describe("toggleDesktopNav", () => {
	it("opens a closed menu", () => {
		useNavigationStore.getState().toggleDesktopNav("Programs")

		expect(useNavigationStore.getState().openDesktopNavTitle).toBe("Programs")
	})

	it("closes when the same title is toggled again", () => {
		useNavigationStore.getState().toggleDesktopNav("Programs")
		useNavigationStore.getState().toggleDesktopNav("Programs")

		expect(useNavigationStore.getState().openDesktopNavTitle).toBeNull()
	})

	it("switches when a different title is toggled", () => {
		useNavigationStore.getState().toggleDesktopNav("Programs")
		useNavigationStore.getState().toggleDesktopNav("Membership")

		expect(useNavigationStore.getState().openDesktopNavTitle).toBe("Membership")
	})

	it("resets the More drill on every toggle", () => {
		useNavigationStore.getState().toggleDesktopNav("More")
		useNavigationStore.getState().openDesktopMoreDrill("Careers")

		useNavigationStore.getState().toggleDesktopNav("Programs")

		expect(useNavigationStore.getState().desktopMoreDrillTitle).toBeNull()
	})
})

describe("desktop drill state", () => {
	it("openDesktopNav switches menus and resets the drill", () => {
		useNavigationStore.getState().openDesktopNav("More")
		useNavigationStore.getState().openDesktopMoreDrill("Careers")

		useNavigationStore.getState().openDesktopNav("Programs")

		expect(useNavigationStore.getState().openDesktopNavTitle).toBe("Programs")
		expect(useNavigationStore.getState().desktopMoreDrillTitle).toBeNull()
	})

	it("backToDesktopMoreRoot clears the drill but keeps the menu open", () => {
		useNavigationStore.getState().openDesktopNav("More")
		useNavigationStore.getState().openDesktopMoreDrill("Careers")

		useNavigationStore.getState().backToDesktopMoreRoot()

		expect(useNavigationStore.getState().openDesktopNavTitle).toBe("More")
		expect(useNavigationStore.getState().desktopMoreDrillTitle).toBeNull()
	})

	it("closeDesktopNav clears both the menu and the drill", () => {
		useNavigationStore.getState().openDesktopNav("More")
		useNavigationStore.getState().openDesktopMoreDrill("Careers")

		useNavigationStore.getState().closeDesktopNav()

		expect(useNavigationStore.getState().openDesktopNavTitle).toBeNull()
		expect(useNavigationStore.getState().desktopMoreDrillTitle).toBeNull()
	})
})

describe("mobile nav", () => {
	it("opening always lands on the root, not a stale drill-down", () => {
		useNavigationStore.setState({ mobileSelectedNavItem: programsItem })

		useNavigationStore.getState().openMobileNav()

		expect(useNavigationStore.getState().isMobileNavOpen).toBe(true)
		expect(useNavigationStore.getState().mobileSelectedNavItem).toBeNull()
	})

	it("toggle flips the panel and resets the drill-down each time", () => {
		useNavigationStore.getState().toggleMobileNav()
		useNavigationStore.getState().openMobileNavItem(programsItem)

		useNavigationStore.getState().toggleMobileNav()

		expect(useNavigationStore.getState().isMobileNavOpen).toBe(false)
		expect(useNavigationStore.getState().mobileSelectedNavItem).toBeNull()
	})

	it("drills into an item and back to the root", () => {
		useNavigationStore.getState().openMobileNav()
		useNavigationStore.getState().openMobileNavItem(programsItem)
		expect(useNavigationStore.getState().mobileSelectedNavItem).toBe(programsItem)

		useNavigationStore.getState().backToMobileRoot()

		expect(useNavigationStore.getState().mobileSelectedNavItem).toBeNull()
		expect(useNavigationStore.getState().isMobileNavOpen).toBe(true)
	})

	it("close clears the drill-down with the panel", () => {
		useNavigationStore.getState().openMobileNav()
		useNavigationStore.getState().openMobileNavItem(programsItem)

		useNavigationStore.getState().closeMobileNav()

		expect(useNavigationStore.getState().isMobileNavOpen).toBe(false)
		expect(useNavigationStore.getState().mobileSelectedNavItem).toBeNull()
	})
})
