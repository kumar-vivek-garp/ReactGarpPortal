import { http, HttpResponse } from "msw"
import { describe, expect, it } from "vitest"

import { saveExamSetupId } from "@/api/exam-setup/save-id-info"
import type { ExamSetupSelectionInput } from "@/api/exam-setup/types"
import {
	memberPortalEnvelope,
	memberPortalError,
} from "@/testing/factories/envelope"
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

describe("saveExamSetupId", () => {
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

	// Every deferral rule arrives this way — "You can only defer your exam
	// registration once", "Part II cannot be taken before Part I". Thrown, they
	// would become a toast over a form the member can no longer see the fault
	// in; returned, the wizard prints them against the step that caused them.
	it("returns an inner refusal rather than throwing", async () => {
		server.use(
			http.post(EXAM_SETUP_ID_PATH, () =>
				HttpResponse.json(
					memberPortalEnvelope({
						statusCode: 501,
						statusMessage:
							"You can only defer your exam registration once.",
					}),
				),
			),
		)

		await expect(saveExamSetupId(args)).resolves.toMatchObject({
			statusCode: 501,
			statusMessage: "You can only defer your exam registration once.",
		})
	})

	it("returns a refusal that arrives with a non-200 HTTP status too", async () => {
		server.use(
			http.post(EXAM_SETUP_ID_PATH, () =>
				HttpResponse.json(
					memberPortalEnvelope({
						statusCode: 505,
						statusMessage: "Part II cannot be taken before Part I",
					}),
					{ status: 505 },
				),
			),
		)

		await expect(saveExamSetupId(args)).resolves.toMatchObject({
			statusCode: 505,
			statusMessage: "Part II cannot be taken before Part I",
		})
	})

	// A request that never ran carries no payload, and that still throws — the
	// discriminator is the payload, not the status.
	it("throws when the failure carries no payload", async () => {
		server.use(
			http.post(EXAM_SETUP_ID_PATH, () =>
				HttpResponse.json(memberPortalError(500, "Apex blew up"), {
					status: 500,
				}),
			),
		)

		await expect(saveExamSetupId(args)).rejects.toMatchObject({
			messages: ["Apex blew up"],
		})
	})
})
