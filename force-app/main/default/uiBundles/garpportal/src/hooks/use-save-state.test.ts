import { act } from "@testing-library/react"
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest"

import { useSaveState } from "@/hooks/use-save-state"
import { renderHookWithProviders } from "@/testing/render"

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

const idle = { isPending: false, isSuccess: false, submittedAt: 0 }

describe("useSaveState", () => {
	it("is idle before anything is submitted", () => {
		const { result } = renderHookWithProviders(
			({ mutation }) => useSaveState(mutation),
			{ initialProps: { mutation: idle } },
		)
		expect(result.current).toBe("idle")
	})

	it("shows saving while the mutation is pending", () => {
		const { result } = renderHookWithProviders(
			({ mutation }) => useSaveState(mutation),
			{
				initialProps: {
					mutation: { isPending: true, isSuccess: false, submittedAt: 1 },
				},
			},
		)
		expect(result.current).toBe("saving")
	})

	it("holds the saved confirmation for 2200ms, then fades to idle", async () => {
		const { result, rerender } = renderHookWithProviders(
			({ mutation }) => useSaveState(mutation),
			{ initialProps: { mutation: idle } },
		)

		rerender({
			mutation: { isPending: false, isSuccess: true, submittedAt: 1 },
		})
		expect(result.current).toBe("saved")

		await advance(2199)
		expect(result.current).toBe("saved")

		await advance(1)
		expect(result.current).toBe("idle")
	})

	it("re-arms for a repeated save of the same mutation", async () => {
		const { result, rerender } = renderHookWithProviders(
			({ mutation }) => useSaveState(mutation),
			{
				initialProps: {
					mutation: { isPending: false, isSuccess: true, submittedAt: 1 },
				},
			},
		)

		await advance(2200)
		expect(result.current).toBe("idle")

		// Same mutation succeeds again: submittedAt bumps, confirmation re-shows.
		rerender({
			mutation: { isPending: false, isSuccess: true, submittedAt: 2 },
		})
		expect(result.current).toBe("saved")

		await advance(2200)
		expect(result.current).toBe("idle")
	})

	it("shows saving (not saved) while a re-save is in flight", () => {
		const { result, rerender } = renderHookWithProviders(
			({ mutation }) => useSaveState(mutation),
			{
				initialProps: {
					mutation: { isPending: false, isSuccess: true, submittedAt: 1 },
				},
			},
		)

		rerender({
			mutation: { isPending: true, isSuccess: true, submittedAt: 1 },
		})
		expect(result.current).toBe("saving")
	})
})
