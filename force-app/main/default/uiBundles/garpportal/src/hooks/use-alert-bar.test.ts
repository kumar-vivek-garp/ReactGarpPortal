import { act } from "@testing-library/react"
import { beforeEach, describe, expect, it } from "vitest"

import { alertBarQueryKeys } from "@/api/alert-bar"
import type { AlertBarView } from "@/api/alert-bar"
import { useAlertBar } from "@/hooks/use-alert-bar"
import { useAlertBarStore } from "@/store/alert-bar-store"
import { createTestQueryClient } from "@/testing/query-client"
import { renderHookWithProviders } from "@/testing/render"

/**
 * Only this hook's KEYING and wiring — the store's phase mechanics and the
 * presentation rules have their own tests. The alert is seeded straight into
 * the query cache (fresh under the options' staleTime, so nothing refetches),
 * and swapped there to model Apex moving from one deadline to the next.
 */

function alertView(alertStatus: string): AlertBarView {
	return {
		statusMessage: null,
		statusCode: 200,
		examType: "FRM",
		examPart: "II",
		alertStatus,
		deadline: null,
		orderId: null,
		route: null,
	}
}

function renderAlertBar(view: AlertBarView | null) {
	const queryClient = createTestQueryClient()
	queryClient.setQueryData(alertBarQueryKeys.view, view)
	const rendered = renderHookWithProviders(() => useAlertBar(), { queryClient })

	// Async, with a macrotask flush: React Query v5's notifyManager batches
	// cache notifications onto the timer queue, so a synchronous act() — or even
	// an awaited microtask — would assert against the render BEFORE the swap
	// landed. One 0ms sleep inside act() makes the swap deterministic.
	const swapAlert = async (next: AlertBarView | null) => {
		await act(async () => {
			queryClient.setQueryData(alertBarQueryKeys.view, next)
			await new Promise((resolve) => setTimeout(resolve, 0))
		})
	}
	return { ...rendered, swapAlert }
}

describe("useAlertBar", () => {
	beforeEach(() => {
		useAlertBarStore.setState({
			phase: "expanded",
			phaseFor: null,
			anchors: { desktop: null, mobile: null },
		})
	})

	it("starts expanded and exposes the alert's model", () => {
		const { result } = renderAlertBar(alertView("Scheduling Incomplete"))
		expect(result.current.phase).toBe("expanded")
		expect(result.current.model?.programme).toBe("FRM Part II")
	})

	it("walks the minimise cycle: minimising, minimised, restoring, expanded", () => {
		const { result } = renderAlertBar(alertView("Scheduling Incomplete"))

		act(() => result.current.minimise())
		expect(result.current.phase).toBe("minimising")

		act(() => result.current.settleMinimised())
		expect(result.current.phase).toBe("minimised")

		act(() => result.current.restore())
		expect(result.current.phase).toBe("restoring")

		act(() => result.current.settleExpanded())
		expect(result.current.phase).toBe("expanded")
	})

	it("stays minimised when the SAME alert arrives again as a fresh payload", async () => {
		const { result, rerender, swapAlert } = renderAlertBar(
			alertView("Scheduling Incomplete"),
		)
		act(() => result.current.minimise())
		act(() => result.current.settleMinimised())

		rerender()
		expect(result.current.phase).toBe("minimised")

		// A refetch hands back a NEW object — identity is the status, not the ref.
		await swapAlert(alertView("Scheduling Incomplete"))
		expect(result.current.phase).toBe("minimised")
	})

	it("re-expands when a DIFFERENT alert replaces the minimised one", async () => {
		const { result, swapAlert } = renderAlertBar(
			alertView("Scheduling Incomplete"),
		)
		act(() => result.current.minimise())
		act(() => result.current.settleMinimised())

		// The booking deadline was resolved; an unpaid order took its place.
		await swapAlert(alertView("Exam Unpaid"))
		expect(result.current.phase).toBe("expanded")
		expect(result.current.model?.message).toBeTruthy()
	})

	it("keys a new minimise to the new alert, not the old one", async () => {
		const { result, swapAlert } = renderAlertBar(
			alertView("Scheduling Incomplete"),
		)
		act(() => result.current.minimise())
		act(() => result.current.settleMinimised())

		await swapAlert(alertView("Exam Unpaid"))
		act(() => result.current.minimise())
		expect(result.current.phase).toBe("minimising")

		// Were the first alert ever to return, the stored phase no longer applies.
		await swapAlert(alertView("Scheduling Incomplete"))
		expect(result.current.phase).toBe("expanded")
	})

	it("reads as expanded with no alert to key on, even after a minimise", () => {
		const { result } = renderAlertBar(null)
		expect(result.current.model).toBeNull()
		expect(result.current.phase).toBe("expanded")

		// With a null key the stored phase can never match — nothing to minimise.
		act(() => result.current.minimise())
		expect(result.current.phase).toBe("expanded")
	})

	it("keeps the phase across the alert disappearing and coming back", async () => {
		const { result, swapAlert } = renderAlertBar(
			alertView("Scheduling Incomplete"),
		)
		act(() => result.current.minimise())
		act(() => result.current.settleMinimised())

		await swapAlert(null)
		expect(result.current.phase).toBe("expanded")

		// The same deadline reappears: the stored key still matches it.
		await swapAlert(alertView("Scheduling Incomplete"))
		expect(result.current.phase).toBe("minimised")
	})
})
