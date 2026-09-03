import { act } from "@testing-library/react"
import { beforeEach, describe, expect, it } from "vitest"

import { useSidebarCollapse } from "@/hooks/use-sidebar-collapse"
import { RAIL_COLLAPSED_WIDTH_PX, RAIL_WIDTH_PX } from "@/lib/sidebar-rail"
import { useSidebarStore } from "@/store/sidebar-store"
import { renderHookWithProviders } from "@/testing/render"

beforeEach(() => {
	window.localStorage.clear()
	useSidebarStore.setState({ isCollapsed: true })
})

function isCollapsed() {
	return useSidebarStore.getState().isCollapsed
}

/** Dispatch a real keydown and hand back the event for `defaultPrevented`. */
function keydown(target: EventTarget, init: KeyboardEventInit): KeyboardEvent {
	const event = new KeyboardEvent("keydown", {
		bubbles: true,
		cancelable: true,
		...init,
	})
	act(() => {
		target.dispatchEvent(event)
	})
	return event
}

describe("useSidebarCollapse", () => {
	it("toggles on Cmd+B and claims the event", () => {
		renderHookWithProviders(() => useSidebarCollapse())

		const event = keydown(window, { key: "b", metaKey: true })
		expect(isCollapsed()).toBe(false)
		expect(event.defaultPrevented).toBe(true)

		keydown(window, { key: "b", metaKey: true })
		expect(isCollapsed()).toBe(true)
	})

	it("toggles on Ctrl+B, and on a shifted uppercase B", () => {
		renderHookWithProviders(() => useSidebarCollapse())

		keydown(window, { key: "b", ctrlKey: true })
		expect(isCollapsed()).toBe(false)

		// `event.key` is "B" with Shift held — the handler lowercases it.
		keydown(window, { key: "B", ctrlKey: true, shiftKey: true })
		expect(isCollapsed()).toBe(true)
	})

	it("ignores a bare b, a wrong key, and Alt chords", () => {
		renderHookWithProviders(() => useSidebarCollapse())

		const bare = keydown(window, { key: "b" })
		keydown(window, { key: "k", metaKey: true })
		keydown(window, { key: "b", metaKey: true, altKey: true })

		expect(isCollapsed()).toBe(true)
		expect(bare.defaultPrevented).toBe(false)
	})

	it("does not eat a literal b typed into a field", () => {
		renderHookWithProviders(() => useSidebarCollapse())

		for (const tag of ["input", "textarea", "select"] as const) {
			const field = document.createElement(tag)
			document.body.appendChild(field)
			keydown(field, { key: "b", metaKey: true })
			expect(isCollapsed()).toBe(true)
			field.remove()
		}
	})

	it("does not eat a b typed into a contentEditable region", () => {
		renderHookWithProviders(() => useSidebarCollapse())

		const editor = document.createElement("div")
		// jsdom never implements contentEditable, so the flag the guard reads is
		// stubbed on the instance — the guard's own branch still runs for real.
		Object.defineProperty(editor, "isContentEditable", { value: true })
		document.body.appendChild(editor)

		keydown(editor, { key: "b", metaKey: true })
		expect(isCollapsed()).toBe(true)
		editor.remove()
	})

	it("exposes toggle() writing the same store", () => {
		const { result } = renderHookWithProviders(() => useSidebarCollapse())

		act(() => {
			result.current.toggle()
		})
		expect(isCollapsed()).toBe(false)
		expect(result.current.isCollapsed).toBe(false)
	})

	it("derives width and label styles from the collapse progress", () => {
		const collapsed = renderHookWithProviders(() => useSidebarCollapse())
		expect(collapsed.result.current.widthStyle.width.get()).toBe(
			RAIL_COLLAPSED_WIDTH_PX,
		)
		expect(collapsed.result.current.labelStyle.opacity.get()).toBe(0)
		expect(collapsed.result.current.labelStyle.x.get()).toBe(-8)
		collapsed.unmount()

		useSidebarStore.setState({ isCollapsed: false })
		const expanded = renderHookWithProviders(() => useSidebarCollapse())
		expect(expanded.result.current.widthStyle.width.get()).toBe(RAIL_WIDTH_PX)
		expect(expanded.result.current.labelStyle.opacity.get()).toBe(1)
		expect(expanded.result.current.labelStyle.x.get()).toBe(-0)
	})

	it("stops listening after unmount", () => {
		const { unmount } = renderHookWithProviders(() => useSidebarCollapse())
		unmount()

		keydown(window, { key: "b", metaKey: true })
		expect(isCollapsed()).toBe(true)
	})
})
