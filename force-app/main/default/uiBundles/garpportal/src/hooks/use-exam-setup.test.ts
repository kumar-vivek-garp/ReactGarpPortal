import { waitFor } from "@testing-library/react"
import { http, HttpResponse } from "msw"
import { describe, expect, it } from "vitest"

import {
	useExamSetup,
	useExamSetupFees,
	useSaveExamSetup,
} from "@/hooks/use-exam-setup"
import { memberPortalEnvelope } from "@/testing/factories/envelope"
import {
	examSetupSaveResult,
	examSetupView,
} from "@/testing/factories/exam-setup"
import { server } from "@/testing/msw/server"
import { renderHookWithProviders } from "@/testing/render"

const FORM_PATH = "/services/apexrest/memberportal/examSetup"
const SAVE_PATH = "/services/apexrest/memberportal/examSetupId"
const FEES_PATH = "/services/apexrest/memberportal/examSetupFees"

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

	it("loads the form for the programme", async () => {
		let requestedProgram: string | null = null
		server.use(
			http.get(FORM_PATH, ({ request }) => {
				requestedProgram = new URL(request.url).searchParams.get("programType")
				return HttpResponse.json(memberPortalEnvelope(examSetupView()))
			}),
		)

		const { result } = renderHookWithProviders(() => useExamSetup("scr"))
		await waitFor(() => expect(result.current.isSuccess).toBe(true))
		expect(requestedProgram).toBe("scr")
	})

	// A refusal is data, so the query succeeds and the panel reads the code.
	it("resolves a refusal rather than erroring", async () => {
		server.use(
			http.get(FORM_PATH, () =>
				HttpResponse.json(
					memberPortalEnvelope(examSetupView({ statusCode: 502 })),
					{ status: 502 },
				),
			),
		)

		const { result } = renderHookWithProviders(() => useExamSetup("frm"))
		await waitFor(() => expect(result.current.isSuccess).toBe(true))
		expect(result.current.data?.statusCode).toBe(502)
	})
})

describe("useSaveExamSetup", () => {
	it("posts the programme alongside both halves", async () => {
		let body: unknown
		server.use(
			http.post(SAVE_PATH, async ({ request }) => {
				body = await request.json()
				return HttpResponse.json(memberPortalEnvelope(examSetupSaveResult()))
			}),
		)

		const { result } = renderHookWithProviders(() => useSaveExamSetup("frm"))
		const id = { idName: "Ada Lovelace" }
		const selection = {
			selectedAdminPart1: "admin-may",
			selectedSitePart1: "site-london",
			selectedAdminPart2: null,
			selectedSitePart2: null,
		}

		await result.current.mutateAsync({ id, selection })

		expect(body).toEqual({ programType: "frm", id, selection })
	})

	// The write raises an Exam_Registration_Modification__c on every call with
	// no dedupe, so nothing here may re-run it. A refetch of the form would
	// also only race the unmount that the outcome step causes.
	it("makes exactly one request per submit and refetches nothing", async () => {
		let saves = 0
		let loads = 0
		server.use(
			http.get(FORM_PATH, () => {
				loads += 1
				return HttpResponse.json(memberPortalEnvelope(examSetupView()))
			}),
			http.post(SAVE_PATH, () => {
				saves += 1
				return HttpResponse.json(memberPortalEnvelope(examSetupSaveResult()))
			}),
		)

		const { result } = renderHookWithProviders(() => ({
			form: useExamSetup("frm"),
			save: useSaveExamSetup("frm"),
		}))
		await waitFor(() => expect(result.current.form.isSuccess).toBe(true))

		await result.current.save.mutateAsync({
			id: {},
			selection: {
				selectedAdminPart1: null,
				selectedSitePart1: null,
				selectedAdminPart2: null,
				selectedSitePart2: null,
			},
		})

		expect(saves).toBe(1)
		expect(loads).toBe(1)
	})

	it("resolves a refusal so the wizard can print it against the step", async () => {
		server.use(
			http.post(SAVE_PATH, () =>
				HttpResponse.json(
					memberPortalEnvelope(
						examSetupSaveResult({
							statusCode: 505,
							statusMessage: "Part II cannot be taken before Part I",
						}),
					),
					{ status: 505 },
				),
			),
		)

		const { result } = renderHookWithProviders(() => useSaveExamSetup("frm"))
		const saved = await result.current.mutateAsync({
			id: {},
			selection: {
				selectedAdminPart1: null,
				selectedSitePart1: null,
				selectedAdminPart2: null,
				selectedSitePart2: null,
			},
		})

		expect(saved.statusCode).toBe(505)
	})
})

describe("useExamSetupFees", () => {
	it("posts the modification id", async () => {
		let body: unknown
		server.use(
			http.post(FEES_PATH, async ({ request }) => {
				body = await request.json()
				return HttpResponse.json(
					memberPortalEnvelope({
						statusMessage: null,
						statusCode: 200,
						examType: "FRM",
						fees: [],
						examEmailParts: null,
						deferralSubType: "Deferral Standard",
						transactionType: "Salesforce - Deferral",
					}),
				)
			}),
		)

		const { result } = renderHookWithProviders(() => useExamSetupFees())
		await result.current.mutateAsync("a0M123")

		expect(body).toEqual({ modificationId: "a0M123" })
	})
})
