import { act } from "@testing-library/react"
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest"

import { useDebouncedValue } from "@/hooks/use-debounced-value"
import { renderHookWithProviders } from "@/testing/render"

/**
 * Proving ground for the phase's fake-timer recipe: fake ONLY setTimeout /
 * clearTimeout (leaving intervals, Date and microtasks real keeps Testing
 * Library and MSW alive), advance with the async variant inside act().
 */
beforeEach(() => {
	vi.useFakeTimers({ toFake: ["setTimeout", "clearTimeout"] })
})

afterEach(() => {
	vi.clearAllTimers()
	vi.useRealTimers()
})

async function advance(ms: number) {
	await act(async () => {
		await vi.advanceTimersByTimeAsync(ms)
	})
}

describe("useDebouncedValue", () => {
	it("returns the initial value immediately", () => {
		const { result } = renderHookWithProviders(
			({ value }) => useDebouncedValue(value, 400),
			{ initialProps: { value: "first" } },
		)
		expect(result.current).toBe("first")
	})

	it("holds the old value until the full delay has elapsed", async () => {
		const { result, rerender } = renderHookWithProviders(
			({ value }) => useDebouncedValue(value, 400),
			{ initialProps: { value: "first" } },
		)

		rerender({ value: "second" })
		expect(result.current).toBe("first")

		await advance(399)
		expect(result.current).toBe("first")

		await advance(1)
		expect(result.current).toBe("second")
	})

	it("resets the timer on every change so only the last value lands", async () => {
		const { result, rerender } = renderHookWithProviders(
			({ value }) => useDebouncedValue(value, 400),
			{ initialProps: { value: "a" } },
		)

		rerender({ value: "b" })
		await advance(200)
		rerender({ value: "c" })

		// 399ms after the LAST change: still the original — "b" must never land.
		await advance(399)
		expect(result.current).toBe("a")

		await advance(1)
		expect(result.current).toBe("c")
	})

	it("applies a shortened delay from the latest render", async () => {
		const { result, rerender } = renderHookWithProviders(
			({ value, delay }) => useDebouncedValue(value, delay),
			{ initialProps: { value: "slow", delay: 400 } },
		)

		rerender({ value: "fast", delay: 50 })
		await advance(50)
		expect(result.current).toBe("fast")
	})
})
