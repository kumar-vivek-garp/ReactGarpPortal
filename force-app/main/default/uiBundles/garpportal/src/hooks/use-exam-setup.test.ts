import { act, waitFor } from "@testing-library/react"
import { http, HttpResponse } from "msw"
import { describe, expect, it } from "vitest"

import { examSetupQueryKeys } from "@/api/exam-setup"
import type { ExamSetupView } from "@/api/exam-setup"
import { EXAM_SETUP_AUTHORIZE_ENABLED } from "@/config/exam-setup"
import {
	useAuthorizeExamSetup,
	useExamSetup,
	useSaveExamSetup,
} from "@/hooks/use-exam-setup"
import { memberPortalEnvelope } from "@/testing/factories/envelope"
import { server } from "@/testing/msw/server"
import { renderHookWithProviders } from "@/testing/render"

const FORM_PATH = "/services/apexrest/memberportal/examSetup"
const SAVE_PATH = "/services/apexrest/memberportal/examSetupId"
const AUTHORIZE_PATH = "/services/apexrest/memberportal/examSetupAuthorize"

function formView(overrides: Partial<ExamSetupView> = {}): ExamSetupView {
	return {
		statusMessage: null,
		statusCode: 200,
		allowAdminModPart1: true,
		allowAdminModPart2: true,
		examPart1SelectionInfo: [],
		examPart2SelectionInfo: [],
		idInfo: null,
		...overrides,
	}
}

describe("useExamSetup", () => {
	it("stays disabled with no programme — a disabled query must never be awaited", () => {
		const { result } = renderHookWithProviders(() => useExamSetup(null))
		// MSW's strict unhandled-request mode also proves no request was made.
		expect(result.current.fetchStatus).toBe("idle")
		expect(result.current.data).toBeUndefined()
	})

	it("honours the caller's enabled flag", () => {
		const { result } = renderHookWithProviders(() => useExamSetup("frm", false))
		expect(result.current.fetchStatus).toBe("idle")
	})

	it("loads the form for the programme, normalising absent part lists", async () => {
		let requestedProgram: string | null = null
		server.use(
			http.get(FORM_PATH, ({ request }) => {
				requestedProgram = new URL(request.url).searchParams.get("programType")
				return HttpResponse.json(
					memberPortalEnvelope(
						formView({
							examPart1SelectionInfo: null,
							examPart2SelectionInfo: null,
						}),
					),
				)
			}),
		)

		const { result } = renderHookWithProviders(() => useExamSetup("scr"))
		await waitFor(() => expect(result.current.isSuccess).toBe(true))
		expect(requestedProgram).toBe("scr")
		expect(result.current.data?.examPart1SelectionInfo).toEqual([])
		expect(result.current.data?.examPart2SelectionInfo).toEqual([])
	})
})

describe("useSaveExamSetup", () => {
	it("posts both halves and invalidates the form so the sittings refetch", async () => {
		let saveBody: Record<string, unknown> | null = null
		server.use(
			http.post(SAVE_PATH, async ({ request }) => {
				saveBody = (await request.json()) as Record<string, unknown>
				return HttpResponse.json(
					memberPortalEnvelope({
						statusMessage: null,
						statusCode: 200,
						nextScreen: "Setup Complete",
						paymentRequired: false,
						schedulingRequired: false,
						examModificationId: null,
					}),
				)
			}),
		)

		const { result, queryClient } = renderHookWithProviders(() =>
			useSaveExamSetup("frm"),
		)
		queryClient.setQueryData(examSetupQueryKeys.form("frm"), formView())

		const selection = {
			selectedAdminPart1: "adm-1",
			selectedSitePart1: "site-1",
			selectedAdminPart2: null,
			selectedSitePart2: null,
		}
		act(() => {
			result.current.mutate({ id: { idName: "Ada Lovelace" }, selection })
		})

		await waitFor(() => expect(result.current.isSuccess).toBe(true))
		expect(saveBody).toEqual({
			programType: "frm",
			id: { idName: "Ada Lovelace" },
			selection,
		})
		expect(
			queryClient.getQueryState(examSetupQueryKeys.form("frm"))?.isInvalidated,
		).toBe(true)
	})
})

/**
 * The DISABLED branch, against the real config. The flag ships `false` until
 * the backend team clears the sandbox path, because `examSetupAuthorize`
 * reaches Pearson / PSI / ATA for real — so with the shipped config the hook
 * must never touch the wire. The enabled path (the exactly-N-attempts
 * contract) lives in `use-exam-setup.authorize.test.ts` behind a config mock.
 */
describe("useAuthorizeExamSetup — feature flag off", () => {
	it("makes authorize and retry no-ops while the flag is off", async () => {
		// Guard the guard: this suite is only meaningful while the flag ships off.
		expect(EXAM_SETUP_AUTHORIZE_ENABLED).toBe(false)

		let providerHits = 0
		server.use(
			http.post(AUTHORIZE_PATH, () => {
				providerHits += 1
				return HttpResponse.json(memberPortalEnvelope({}))
			}),
		)

		const { result } = renderHookWithProviders(() =>
			useAuthorizeExamSetup("frm"),
		)
		expect(result.current.isEnabled).toBe(false)

		act(() => {
			result.current.authorize()
		})
		act(() => {
			result.current.retry()
		})

		expect(result.current.attempts).toBe(0)
		expect(result.current.isPending).toBe(false)
		expect(result.current.result).toBeNull()
		expect(result.current.isExhausted).toBe(false)
		// Flush any stray microtasks before counting: nothing may have fired.
		await Promise.resolve()
		expect(providerHits).toBe(0)
	})
})
