import { act, waitFor } from "@testing-library/react"
import { http, HttpResponse } from "msw"
import { describe, expect, it, vi } from "vitest"

import type { ExamSetupAuthorizeResult } from "@/api/exam-setup"
import { EXAM_SETUP_AUTHORIZE_MAX_RETRIES } from "@/config/exam-setup"
import { useAuthorizeExamSetup } from "@/hooks/use-exam-setup"
import {
	memberPortalEnvelope,
	memberPortalError,
} from "@/testing/factories/envelope"
import { server } from "@/testing/msw/server"
import { renderHookWithProviders } from "@/testing/render"

/*
 * vi.mock exception (per testing.md): EXAM_SETUP_AUTHORIZE_ENABLED is a
 * build-time constant, not an HTTP boundary MSW could fake. It ships `false`
 * — the endpoint pushes to the REAL Pearson/PSI/ATA — so the enabled path,
 * whose exactly-N-attempts contract is the whole point of the hook, can only
 * be exercised by flipping the flag here. MAX_RETRIES stays the real value.
 */
vi.mock("@/config/exam-setup", async (importOriginal) => ({
	...(await importOriginal<typeof import("@/config/exam-setup")>()),
	EXAM_SETUP_AUTHORIZE_ENABLED: true,
}))

const AUTHORIZE_PATH = "/services/apexrest/memberportal/examSetupAuthorize"

function authorizeResult(
	overrides: Partial<ExamSetupAuthorizeResult> = {},
): ExamSetupAuthorizeResult {
	return {
		statusMessage: null,
		statusCode: 200,
		schedulingRequired: true,
		isAuthorized: false,
		examScheduleExamURLPart1: null,
		examScheduleExamURLPart2: null,
		...overrides,
	}
}

describe("useAuthorizeExamSetup — feature flag on", () => {
	it("counts every ask and exhausts at exactly MAX_RETRIES unprocessed answers", async () => {
		const bodies: Array<Record<string, unknown>> = []
		server.use(
			http.post(AUTHORIZE_PATH, async ({ request }) => {
				bodies.push((await request.json()) as Record<string, unknown>)
				return HttpResponse.json(memberPortalEnvelope(authorizeResult()))
			}),
		)

		const { result } = renderHookWithProviders(() =>
			useAuthorizeExamSetup("frm"),
		)
		expect(result.current.isEnabled).toBe(true)

		act(() => {
			result.current.authorize()
		})
		expect(result.current.attempts).toBe(1)
		await waitFor(() => expect(result.current.result).not.toBeNull())
		expect(result.current.result?.isAuthorized).toBe(false)
		expect(result.current.isExhausted).toBe(false)

		act(() => {
			result.current.retry()
		})
		expect(result.current.attempts).toBe(2)
		await waitFor(() => expect(result.current.isPending).toBe(false))
		// One attempt short of the cap: still allowed to ask again.
		expect(result.current.isExhausted).toBe(false)

		act(() => {
			result.current.retry()
		})
		expect(result.current.attempts).toBe(EXAM_SETUP_AUTHORIZE_MAX_RETRIES)
		await waitFor(() => expect(result.current.isPending).toBe(false))
		// The provider was asked exactly N times, then the hook stops offering.
		expect(result.current.isExhausted).toBe(true)
		expect(bodies).toHaveLength(EXAM_SETUP_AUTHORIZE_MAX_RETRIES)

		// authorize() sends isRetry false; every retry() sends true.
		expect(bodies.map((body) => body.isRetry)).toEqual([false, true, true])
		expect(bodies.every((body) => body.programType === "frm")).toBe(true)
	})

	it("never exhausts once the provider authorizes", async () => {
		server.use(
			http.post(AUTHORIZE_PATH, () =>
				HttpResponse.json(
					memberPortalEnvelope(
						authorizeResult({
							isAuthorized: true,
							schedulingRequired: true,
							examScheduleExamURLPart1: "https://provider.test/book",
						}),
					),
				),
			),
		)

		const { result } = renderHookWithProviders(() =>
			useAuthorizeExamSetup("frm"),
		)
		for (let i = 0; i < EXAM_SETUP_AUTHORIZE_MAX_RETRIES; i += 1) {
			act(() => {
				result.current.retry()
			})
			await waitFor(() => expect(result.current.isPending).toBe(false))
		}

		expect(result.current.attempts).toBe(EXAM_SETUP_AUTHORIZE_MAX_RETRIES)
		expect(result.current.result?.isAuthorized).toBe(true)
		expect(result.current.result?.examScheduleExamURLPart1).toBe(
			"https://provider.test/book",
		)
		// Attempts at the cap, but the answer is not "unprocessed".
		expect(result.current.isExhausted).toBe(false)
	})

	it("still counts a failed ask, but a thrown failure is not an unprocessed answer", async () => {
		server.use(
			// 500, not 4xx: the SDK transport retries once on 400/401/403.
			http.post(AUTHORIZE_PATH, () =>
				HttpResponse.json(memberPortalError(500, "provider unreachable"), {
					status: 500,
				}),
			),
		)

		const { result } = renderHookWithProviders(() =>
			useAuthorizeExamSetup("frm"),
		)
		act(() => {
			result.current.authorize()
		})
		expect(result.current.attempts).toBe(1)

		await waitFor(() => expect(result.current.isPending).toBe(false))
		expect(result.current.result).toBeNull()
		// Exhaustion is keyed on an unprocessed RESULT — errors leave it false.
		expect(result.current.isExhausted).toBe(false)
	})

	it("rejects an inner non-200 as an error rather than a result", async () => {
		server.use(
			http.post(AUTHORIZE_PATH, () =>
				HttpResponse.json(
					memberPortalEnvelope(
						authorizeResult({ statusCode: 409, statusMessage: "Not eligible" }),
					),
				),
			),
		)

		const { result } = renderHookWithProviders(() =>
			useAuthorizeExamSetup("frm"),
		)
		act(() => {
			result.current.authorize()
		})

		await waitFor(() => expect(result.current.isPending).toBe(false))
		expect(result.current.result).toBeNull()
		expect(result.current.attempts).toBe(1)
	})
})
