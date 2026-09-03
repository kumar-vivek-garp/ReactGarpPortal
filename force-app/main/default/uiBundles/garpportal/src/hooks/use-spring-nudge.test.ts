import { act, renderHook } from "@testing-library/react"
import { describe, expect, it } from "vitest"

import { useSpringNudge } from "@/hooks/use-spring-nudge"

describe("useSpringNudge", () => {
	it("nudges forward on hover and returns to rest on leave", () => {
		const { result } = renderHook(() => useSpringNudge())

		expect(result.current.direction).toBe("forward")
		expect(result.current.containerStyle.x.goal).toBe(0)

		act(() => result.current.bind.onMouseEnter())
		expect(result.current.containerStyle.x.goal).toBe(4)
		expect(result.current.iconStyle.x.goal).toBe(3)

		act(() => result.current.bind.onMouseLeave())
		expect(result.current.containerStyle.x.goal).toBe(0)
		expect(result.current.iconStyle.x.goal).toBe(0)
	})

	it("engages for keyboard focus and releases on blur", () => {
		const { result } = renderHook(() =>
			useSpringNudge({ direction: "backward" }),
		)

		act(() => result.current.bind.onFocus())
		expect(result.current.containerStyle.x.goal).toBe(-5)
		expect(result.current.containerStyle.scale.goal).toBe(1.04)

		act(() => result.current.bind.onBlur())
		expect(result.current.containerStyle.x.goal).toBe(0)
	})

	it("stays at rest while disabled, even when hovered", () => {
		const { result } = renderHook(() => useSpringNudge({ disabled: true }))

		act(() => result.current.bind.onMouseEnter())
		expect(result.current.containerStyle.x.goal).toBe(0)
		expect(result.current.iconStyle.x.goal).toBe(0)
	})
})
