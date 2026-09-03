import { http, HttpResponse } from "msw"
import { describe, expect, it } from "vitest"

import { saveExamSetupId } from "@/api/exam-setup/save-id-info"
import type { ExamSetupSelectionInput } from "@/api/exam-setup/types"
import { memberPortalEnvelope } from "@/testing/factories/envelope"
import { server } from "@/testing/msw/server"

const EXAM_SETUP_ID_PATH = "/services/apexrest/memberportal/examSetupId"

const selection: ExamSetupSelectionInput = {
	selectedAdminPart1: "a0A1",
	selectedSitePart1: "a0S1",
	selectedAdminPart2: null,
	selectedSitePart2: null,
}

const args = {
	programType: "frm" as const,
	id: { idType: "Passport", idNumber: "X1234567" },
	selection,
}

describe("saveExamSetupId 200-with-error defence", () => {
	it("posts both halves in one body and returns the save result", async () => {
		let body: unknown
		server.use(
			http.post(EXAM_SETUP_ID_PATH, async ({ request }) => {
				body = await request.json()
				return HttpResponse.json(
					memberPortalEnvelope({
						statusCode: 200,
						statusMessage: null,
						nextScreen: "Setup Complete",
						paymentRequired: false,
						schedulingRequired: false,
						examModificationId: null,
					}),
				)
			}),
		)

		await expect(saveExamSetupId(args)).resolves.toMatchObject({
			nextScreen: "Setup Complete",
		})
		expect(body).toEqual({
			programType: "frm",
			id: args.id,
			selection: args.selection,
		})
	})

	it("surfaces an inner refusal hidden inside an HTTP 200", async () => {
		server.use(
			http.post(EXAM_SETUP_ID_PATH, () =>
				HttpResponse.json(
					memberPortalEnvelope({
						statusCode: 500,
						statusMessage: "ID information could not be saved",
					}),
				),
			),
		)

		await expect(saveExamSetupId(args)).rejects.toMatchObject({
			status: 500,
			messages: ["ID information could not be saved"],
		})
	})

	it("falls back to its own sentence when the refusal is silent", async () => {
		server.use(
			http.post(EXAM_SETUP_ID_PATH, () =>
				HttpResponse.json(
					memberPortalEnvelope({ statusCode: 500, statusMessage: null }),
				),
			),
		)

		await expect(saveExamSetupId(args)).rejects.toMatchObject({
			messages: ["Unable to save your exam setup."],
		})
	})
})
