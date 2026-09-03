/**
 * No router mock needed here: the hook deliberately takes the navigation as a
 * callback (`exit(run)`) rather than calling `useNavigate` itself, so the
 * tests hand it a recorded `vi.fn()` and the router never enters the picture.
 */
import { Globals } from "@react-spring/web"
import { act, waitFor } from "@testing-library/react"
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest"

import { useSubpageTransition } from "@/hooks/use-subpage-transition"
import { renderHookWithProviders } from "@/testing/render"

beforeEach(() => {
	vi.useFakeTimers({ toFake: ["setTimeout", "clearTimeout"] })
})

afterEach(() => {
	// Reset the reduced-motion switch some tests flip.
	Globals.assign({ skipAnimation: false })
	vi.clearAllTimers()
	vi.useRealTimers()
})

async function advance(ms: number) {
	await act(async () => {
		await vi.advanceTimersByTimeAsync(ms)
	})
}

describe("useSubpageTransition", () => {
	it("mounts not exiting, offscreen, ready to animate in", () => {
		const { result } = renderHookWithProviders(() => useSubpageTransition())

		expect(result.current.isExiting).toBe(false)
		// The entrance spring starts at its `from` values.
		expect(result.current.style.opacity.get()).toBe(0)
		expect(result.current.style.transform.get()).toBe("translateX(18px)")
	})

	it("defers the navigation until the 400ms fallback, then runs it once", async () => {
		const run = vi.fn()
		const { result } = renderHookWithProviders(() => useSubpageTransition())

		act(() => {
			result.current.exit(run)
		})
		expect(result.current.isExiting).toBe(true)
		expect(run).not.toHaveBeenCalled()

		await advance(399)
		expect(run).not.toHaveBeenCalled()

		await advance(1)
		expect(run).toHaveBeenCalledTimes(1)

		// A long-settled page must not re-run the navigation.
		await advance(1000)
		expect(run).toHaveBeenCalledTimes(1)
	})

	it("ignores a second exit while one is already pending", async () => {
		const first = vi.fn()
		const second = vi.fn()
		const { result } = renderHookWithProviders(() => useSubpageTransition())

		act(() => {
			result.current.exit(first)
		})
		act(() => {
			result.current.exit(second)
		})

		await advance(400)
		expect(first).toHaveBeenCalledTimes(1)
		// The re-entrancy guard dropped the second navigation entirely.
		expect(second).not.toHaveBeenCalled()

		await advance(400)
		expect(second).not.toHaveBeenCalled()
	})

	it("re-arms once the pending navigation has run", async () => {
		const first = vi.fn()
		const second = vi.fn()
		const { result } = renderHookWithProviders(() => useSubpageTransition())

		act(() => {
			result.current.exit(first)
		})
		await advance(400)
		expect(first).toHaveBeenCalledTimes(1)

		// In production the page has navigated away by now, but the guard's
		// contract is still worth pinning: a run that completed releases the slot.
		act(() => {
			result.current.exit(second)
		})
		await advance(400)
		expect(second).toHaveBeenCalledTimes(1)
	})

	it("navigates via onRest — before the fallback — when springs settle instantly", async () => {
		// Reduced-motion path: `useReducedMotion()` in __root.tsx makes every
		// spring jump to its goal, which is what skipAnimation reproduces here.
		// react-spring still delivers onRest on the next animation frame, so
		// this one test runs on real timers and proves the navigation landed
		// well before the 400ms fallback could have fired.
		vi.useRealTimers()
		Globals.assign({ skipAnimation: true })
		const run = vi.fn()
		const { result } = renderHookWithProviders(() => useSubpageTransition())

		act(() => {
			result.current.exit(run)
		})
		await waitFor(() => expect(run).toHaveBeenCalledTimes(1), {
			timeout: 300,
		})
		expect(run).toHaveBeenCalledTimes(1)
	})
})
