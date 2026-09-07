import { act, waitFor } from "@testing-library/react"
import { http, HttpResponse } from "msw"
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest"

import { EXAM_SETUP_AUTHORIZE_ENABLED } from "@/config/exam-setup"
import { useAuthorizeExamSetup } from "@/hooks/use-exam-setup"
import { memberPortalEnvelope } from "@/testing/factories/envelope"
import { examSetupAuthorizeResult } from "@/testing/factories/exam-setup"
import { server } from "@/testing/msw/server"
import { renderHookWithProviders } from "@/testing/render"

const AUTHORIZE_PATH = "/services/apexrest/memberportal/examSetupAuthorize"

// Everything below runs the real config. If the flag is ever turned back off
// these fail as a set, which is the right signal — turning it off changes what
// members see, and should not slip through green.
it("is enabled, so the provider is actually asked", () => {
	expect(EXAM_SETUP_AUTHORIZE_ENABLED).toBe(true)
})

/** The single retry waits 20s; a real timer here would be 20s of dead suite. */
beforeEach(() => {
	vi.useFakeTimers({ shouldAdvanceTime: true })
})

afterEach(() => {
	vi.useRealTimers()
})

/** Records the `isRetry` flag of each attempt, which is what the retry means. */
function authorizeHandler(
	answers: { isAuthorized: boolean }[],
	seen: unknown[],
) {
	let call = 0
	return http.post(AUTHORIZE_PATH, async ({ request }) => {
		const body = (await request.json()) as {
			programType: string
			isRetry: unknown
		}
		expect(body.programType).toBe("frm")
		seen.push(body.isRetry)
		const answer = answers[Math.min(call, answers.length - 1)]
		call += 1
		return HttpResponse.json(
			memberPortalEnvelope(
				examSetupAuthorizeResult({
					isAuthorized: answer.isAuthorized,
					examScheduleExamURLPart1: answer.isAuthorized
						? "https://provider.example/schedule/1"
						: null,
				}),
			),
		)
	})
}

describe("useAuthorizeExamSetup", () => {
	it("asks once and stops when the provider accepts straight away", async () => {
		const seen: unknown[] = []
		server.use(authorizeHandler([{ isAuthorized: true }], seen))

		const { result } = renderHookWithProviders(() =>
			useAuthorizeExamSetup("frm"),
		)
		act(() => result.current.run())

		await waitFor(() => expect(result.current.hasRun).toBe(true))
		expect(seen).toEqual([false])
		expect(result.current.result?.isAuthorized).toBe(true)
		expect(result.current.isAuthorising).toBe(false)
	})

	// Authorisation is not instant. One retry, flagged as such, then stop —
	// polling a third-party integration from a browser turns one slow vendor
	// into a stampede.
	it("retries exactly once, after the wait, when the answer is 'not yet'", async () => {
		const seen: unknown[] = []
		server.use(
			authorizeHandler(
				[{ isAuthorized: false }, { isAuthorized: true }],
				seen,
			),
		)

		const { result } = renderHookWithProviders(() =>
			useAuthorizeExamSetup("frm"),
		)
		act(() => result.current.run())

		await waitFor(() => expect(seen).toHaveLength(1))
		expect(result.current.isAuthorising).toBe(true)

		await act(async () => {
			await vi.advanceTimersByTimeAsync(20000)
		})

		await waitFor(() => expect(result.current.hasRun).toBe(true))
		expect(seen).toEqual([false, true])
		expect(result.current.result?.isAuthorized).toBe(true)
	})

	it("gives up after the retry rather than asking a third time", async () => {
		const seen: unknown[] = []
		server.use(authorizeHandler([{ isAuthorized: false }], seen))

		const { result } = renderHookWithProviders(() =>
			useAuthorizeExamSetup("frm"),
		)
		act(() => result.current.run())

		await waitFor(() => expect(seen).toHaveLength(1))
		await act(async () => {
			await vi.advanceTimersByTimeAsync(20000)
		})
		await waitFor(() => expect(result.current.hasRun).toBe(true))

		await act(async () => {
			await vi.advanceTimersByTimeAsync(60000)
		})
		expect(seen).toHaveLength(2)
		expect(result.current.result?.isAuthorized).toBe(false)
	})

	// We genuinely do not know whether the provider took it, so the outcome
	// screen must say "not completed" rather than claim either way.
	it("reports a failure as no result", async () => {
		server.use(
			http.post(AUTHORIZE_PATH, () =>
				HttpResponse.json(
					{
						status: "Error",
						statusCode: 500,
						errorMessage: "Provider unreachable",
						data: {},
					},
					{ status: 500 },
				),
			),
		)

		const { result } = renderHookWithProviders(() =>
			useAuthorizeExamSetup("frm"),
		)
		act(() => result.current.run())

		await waitFor(() => expect(result.current.hasRun).toBe(true))
		expect(result.current.result).toBeNull()
	})

	it("does not leave a retry running after the screen goes away", async () => {
		const seen: unknown[] = []
		server.use(authorizeHandler([{ isAuthorized: false }], seen))

		const { result, unmount } = renderHookWithProviders(() =>
			useAuthorizeExamSetup("frm"),
		)
		act(() => result.current.run())
		await waitFor(() => expect(seen).toHaveLength(1))

		unmount()
		await act(async () => {
			await vi.advanceTimersByTimeAsync(20000)
		})

		expect(seen).toHaveLength(1)
	})
})
