import { describe, expect, it, vi } from "vitest"

import { chainHandlers } from "./chain-handlers"

describe("chainHandlers", () => {
	it("calls both handlers for a colliding key, in order", () => {
		const calls: string[] = []
		const merged = chainHandlers(
			{ onPointerDown: () => calls.push("a") },
			{ onPointerDown: () => calls.push("b") },
		)
		merged.onPointerDown()
		expect(calls).toEqual(["a", "b"])
	})

	it("forwards the same arguments to both", () => {
		const a = vi.fn()
		const b = vi.fn()
		const event = { type: "pointerdown" }
		chainHandlers({ onPointerDown: a }, { onPointerDown: b }).onPointerDown(
			event,
		)
		expect(a).toHaveBeenCalledWith(event)
		expect(b).toHaveBeenCalledWith(event)
	})

	it("keeps non-colliding keys from both sides", () => {
		const merged = chainHandlers(
			{ onKeyDown: () => {}, "aria-label": "grip" },
			{ onTouchStart: () => {} },
		)
		expect(Object.keys(merged).sort()).toEqual([
			"aria-label",
			"onKeyDown",
			"onTouchStart",
		])
	})

	it("lets a non-function value on the right win, as a spread would", () => {
		expect(chainHandlers({ "data-x": 1 }, { "data-x": 2 })["data-x"]).toBe(2)
	})

	it("never drops a handler whatever key the gesture layer chose", () => {
		// The device use-gesture picks is decided at import time, so the test
		// asserts the property for every family it can produce.
		for (const key of ["onPointerDown", "onTouchStart", "onMouseDown"]) {
			const gesture = vi.fn()
			const press = vi.fn()
			const merged = chainHandlers({ [key]: press }, { [key]: gesture })
			;(merged[key] as () => void)()
			expect(press, key).toHaveBeenCalled()
			expect(gesture, key).toHaveBeenCalled()
		}
	})
})
