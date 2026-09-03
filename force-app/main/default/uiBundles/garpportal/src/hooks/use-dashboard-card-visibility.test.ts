import { act, waitFor } from "@testing-library/react"
import { http, HttpResponse } from "msw"
import { beforeEach, describe, expect, it, vi } from "vitest"
import { toast } from "sonner"

import { dashboardQueryKeys } from "@/api/dashboard"
import { DASHBOARD_CARD_VISIBILITY } from "@/config/dashboard"
import { useDashboardCardVisibility } from "@/hooks/use-dashboard-card-visibility"
import {
	memberPortalEnvelope,
	memberPortalError,
} from "@/testing/factories/envelope"
import { server } from "@/testing/msw/server"
import { renderHookWithProviders } from "@/testing/render"

const DISMISS_PATH = "/services/apexrest/memberportal/dismissCard"
const RESTORE_PATH = "/services/apexrest/memberportal/restoreCard"

type UndoToastOptions = { action?: { label: string; onClick: () => void } }

function okDismiss() {
	return http.post(DISMISS_PATH, () =>
		HttpResponse.json(memberPortalEnvelope({ dismissed: "cpd" })),
	)
}

function okRestore() {
	return http.post(RESTORE_PATH, () =>
		HttpResponse.json(memberPortalEnvelope({ restored: "cpd" })),
	)
}

describe("useDashboardCardVisibility", () => {
	beforeEach(() => {
		vi.mocked(toast).mockClear()
	})

	it("hides optimistically, then offers undo only once the server confirmed", async () => {
		let release!: () => void
		const gate = new Promise<void>((resolve) => {
			release = resolve
		})
		let dismissBody: Record<string, string> | null = null
		server.use(
			http.post(DISMISS_PATH, async ({ request }) => {
				dismissBody = (await request.json()) as Record<string, string>
				await gate
				return HttpResponse.json(memberPortalEnvelope({ dismissed: "cpd" }))
			}),
		)

		const { result, queryClient } = renderHookWithProviders(() =>
			useDashboardCardVisibility(),
		)
		queryClient.setQueryData(dashboardQueryKeys.view, { seeded: true })

		act(() => {
			result.current.dismiss("cpd")
		})
		// Optimistic: hidden before the server has answered — and no undo yet.
		expect(result.current.hiddenKeys).toEqual(["cpd"])
		expect(vi.mocked(toast)).not.toHaveBeenCalled()

		release()
		await waitFor(() => expect(vi.mocked(toast)).toHaveBeenCalledTimes(1))
		expect(vi.mocked(toast)).toHaveBeenCalledWith(
			DASHBOARD_CARD_VISIBILITY.dismissedMessage,
			expect.objectContaining({
				action: expect.objectContaining({
					label: DASHBOARD_CARD_VISIBILITY.undoLabel,
				}),
			}),
		)
		expect(dismissBody).toEqual({ key: "cpd" })
		expect(result.current.hiddenKeys).toEqual(["cpd"])
		// The dashboard manifest is refetched, not patched.
		expect(
			queryClient.getQueryState(dashboardQueryKeys.view)?.isInvalidated,
		).toBe(true)
	})

	it("rolls the optimistic hide back on error, with no undo toast", async () => {
		server.use(
			// 500, not 4xx: the SDK transport retries once on 400/401/403.
			http.post(DISMISS_PATH, () =>
				HttpResponse.json(memberPortalError(500, "dismiss failed"), {
					status: 500,
				}),
			),
		)

		const { result } = renderHookWithProviders(() =>
			useDashboardCardVisibility(),
		)
		act(() => {
			result.current.dismiss("cpd")
		})
		expect(result.current.hiddenKeys).toEqual(["cpd"])

		await waitFor(() => expect(result.current.hiddenKeys).toEqual([]))
		expect(vi.mocked(toast)).not.toHaveBeenCalled()
	})

	it("restore clears the key immediately and posts to the restore endpoint", async () => {
		let restoreBody: Record<string, string> | null = null
		server.use(
			okDismiss(),
			http.post(RESTORE_PATH, async ({ request }) => {
				restoreBody = (await request.json()) as Record<string, string>
				return HttpResponse.json(memberPortalEnvelope({ restored: "cpd" }))
			}),
		)

		const { result } = renderHookWithProviders(() =>
			useDashboardCardVisibility(),
		)
		act(() => {
			result.current.dismiss("cpd")
		})
		await waitFor(() => expect(vi.mocked(toast)).toHaveBeenCalledTimes(1))

		act(() => {
			result.current.restore("cpd")
		})
		// Cleared synchronously so the refetched card is not filtered back out.
		expect(result.current.hiddenKeys).toEqual([])

		await waitFor(() => expect(restoreBody).toEqual({ key: "cpd" }))
		expect(result.current.hiddenKeys).toEqual([])
	})

	it("re-hides the key when the restore fails — the server still has it muted", async () => {
		server.use(
			okDismiss(),
			http.post(RESTORE_PATH, () =>
				HttpResponse.json(memberPortalError(500, "restore failed"), {
					status: 500,
				}),
			),
		)

		const { result } = renderHookWithProviders(() =>
			useDashboardCardVisibility(),
		)
		act(() => {
			result.current.dismiss("cpd")
		})
		await waitFor(() => expect(vi.mocked(toast)).toHaveBeenCalledTimes(1))

		act(() => {
			result.current.restore("cpd")
		})
		expect(result.current.hiddenKeys).toEqual([])

		await waitFor(() => expect(result.current.hiddenKeys).toEqual(["cpd"]))
	})

	it("wires the undo toast's action to the restore flow", async () => {
		let restoreHits = 0
		server.use(
			okDismiss(),
			http.post(RESTORE_PATH, () => {
				restoreHits += 1
				return HttpResponse.json(memberPortalEnvelope({ restored: "cpd" }))
			}),
		)

		const { result } = renderHookWithProviders(() =>
			useDashboardCardVisibility(),
		)
		act(() => {
			result.current.dismiss("cpd")
		})
		await waitFor(() => expect(vi.mocked(toast)).toHaveBeenCalledTimes(1))

		const options = vi.mocked(toast).mock.calls[0]?.[1] as UndoToastOptions
		act(() => {
			options.action?.onClick()
		})

		expect(result.current.hiddenKeys).toEqual([])
		await waitFor(() => expect(restoreHits).toBe(1))
	})

	it("shares one hiddenKeys list across both directions", async () => {
		server.use(okDismiss(), okRestore())

		const { result } = renderHookWithProviders(() =>
			useDashboardCardVisibility(),
		)
		// Sequential on purpose: both directions share ONE useMutation each, and
		// mutate-level callbacks only fire for the latest mutate call — a second
		// dismiss in flight would swallow the first one's onSuccess/onError.
		act(() => {
			result.current.dismiss("cpd")
		})
		await waitFor(() => expect(vi.mocked(toast)).toHaveBeenCalledTimes(1))
		act(() => {
			result.current.dismiss("events")
		})
		expect(result.current.hiddenKeys).toEqual(["cpd", "events"])
		await waitFor(() => expect(vi.mocked(toast)).toHaveBeenCalledTimes(2))

		// Dismissing an already-hidden key must not duplicate it.
		act(() => {
			result.current.dismiss("cpd")
		})
		expect(result.current.hiddenKeys).toEqual(["cpd", "events"])
		await waitFor(() => expect(vi.mocked(toast)).toHaveBeenCalledTimes(3))

		act(() => {
			result.current.restore("cpd")
		})
		expect(result.current.hiddenKeys).toEqual(["events"])
	})
})
