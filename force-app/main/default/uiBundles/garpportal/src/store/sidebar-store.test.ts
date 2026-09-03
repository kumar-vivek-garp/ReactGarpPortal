import { beforeEach, describe, expect, it } from "vitest"

import { SIDEBAR_STORAGE_KEY } from "@/config/navigation/sidebar"
import { useSidebarStore } from "@/store/sidebar-store"

beforeEach(() => {
	window.localStorage.clear()
	useSidebarStore.setState({ isCollapsed: true })
})

describe("sidebar store", () => {
	it("toggles the collapsed rail back and forth", () => {
		useSidebarStore.getState().toggleCollapsed()
		expect(useSidebarStore.getState().isCollapsed).toBe(false)

		useSidebarStore.getState().toggleCollapsed()
		expect(useSidebarStore.getState().isCollapsed).toBe(true)
	})

	it("setCollapsed writes the given value", () => {
		useSidebarStore.getState().setCollapsed(false)

		expect(useSidebarStore.getState().isCollapsed).toBe(false)
	})

	it("persists the choice to localStorage on toggle", () => {
		useSidebarStore.getState().toggleCollapsed()

		const raw = window.localStorage.getItem(SIDEBAR_STORAGE_KEY)
		expect(raw).not.toBeNull()
		const parsed = JSON.parse(raw as string) as {
			state: { isCollapsed: boolean }
		}
		expect(parsed.state.isCollapsed).toBe(false)
	})
})
