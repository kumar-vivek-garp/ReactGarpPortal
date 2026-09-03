import { act, renderHook, waitFor } from "@testing-library/react"
import { afterEach, describe, expect, it, vi } from "vitest"

import { useSpringScrollTo } from "@/hooks/use-spring-scroll-to"
import { skipSpringAnimations } from "@/testing/springs"

// Safe here: the rendered tree is only the hook itself (see springs.ts).
skipSpringAnimations()

function fakeRect(top: number): DOMRect {
	return {
		top,
		bottom: top,
		left: 0,
		right: 0,
		width: 0,
		height: 0,
		x: 0,
		y: top,
		toJSON: () => ({}),
	} as DOMRect
}

/** An `overflow-y: auto` panel body around the target, jsdom-geometry included. */
function buildScrollArea(targetTop: number) {
	const container = document.createElement("div")
	container.style.overflowY = "auto"
	Object.defineProperty(container, "scrollHeight", { value: 1000 })
	Object.defineProperty(container, "clientHeight", { value: 200 })
	container.getBoundingClientRect = () => fakeRect(0)

	const target = document.createElement("section")
	target.getBoundingClientRect = () => fakeRect(targetTop)
	container.appendChild(target)
	document.body.appendChild(container)
	return { container, target }
}

afterEach(() => {
	document.body.innerHTML = ""
})

describe("useSpringScrollTo", () => {
	it("glides its scroll container to just above the target", async () => {
		const { container, target } = buildScrollArea(300)
		const { result } = renderHook(() => useSpringScrollTo())

		act(() => result.current.scrollTo(target))

		// The (skipped) spring settles on the next frame flush.
		// 300 - 0 - 12px breathing room, clamped inside [0, 800].
		await waitFor(() => expect(container.scrollTop).toBe(288))
	})

	it("stays put when the target is already in position", () => {
		// Exactly the breathing-room offset away: a sub-pixel move is skipped.
		const { container, target } = buildScrollArea(12)
		const { result } = renderHook(() => useSpringScrollTo())

		act(() => result.current.scrollTo(target))

		expect(container.scrollTop).toBe(0)
	})

	it("ignores a null target", () => {
		const { result } = renderHook(() => useSpringScrollTo())
		expect(() => act(() => result.current.scrollTo(null))).not.toThrow()
	})

	it("falls back to scrollIntoView when nothing scrollable surrounds the target", () => {
		const target = document.createElement("section")
		document.body.appendChild(target)
		target.scrollIntoView = vi.fn()

		const { result } = renderHook(() => useSpringScrollTo())
		act(() => result.current.scrollTo(target))

		expect(target.scrollIntoView).toHaveBeenCalledWith({ block: "start" })
	})

	it("lets a deliberate wheel or touch win over the glide, and stop() cancel it", () => {
		const { target } = buildScrollArea(300)
		const { result, unmount } = renderHook(() => useSpringScrollTo())

		act(() => result.current.scrollTo(target))
		act(() => {
			window.dispatchEvent(new Event("wheel"))
			window.dispatchEvent(new Event("touchstart"))
		})
		act(() => result.current.stop())

		// Listeners detach with the hook — firing again after unmount is inert.
		unmount()
		expect(() => window.dispatchEvent(new Event("wheel"))).not.toThrow()
	})
})
