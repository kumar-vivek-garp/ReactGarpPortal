import { http, HttpResponse } from "msw"
import { describe, expect, it } from "vitest"

import { fetchExamSetupForm } from "@/api/exam-setup/exam-setup"
import {
	memberPortalEnvelope,
	memberPortalError,
} from "@/testing/factories/envelope"
import { examSetupView } from "@/testing/factories/exam-setup"
import { server } from "@/testing/msw/server"

const EXAM_SETUP_PATH = "/services/apexrest/memberportal/examSetup"

describe("fetchExamSetupForm", () => {
	it("sends the programme as a query param and returns the view", async () => {
		let url = ""
		server.use(
			http.get(EXAM_SETUP_PATH, ({ request }) => {
				url = request.url
				return HttpResponse.json(memberPortalEnvelope(examSetupView()))
			}),
		)

		await expect(fetchExamSetupForm("frm")).resolves.toMatchObject({
			statusCode: 200,
		})
		expect(url).toContain("programType=frm")
	})

	it("coerces absent part lists to arrays", async () => {
		server.use(
			http.get(EXAM_SETUP_PATH, () =>
				HttpResponse.json(
					memberPortalEnvelope(
						examSetupView({
							examPart1SelectionInfo: null,
							examPart2SelectionInfo: null,
						}),
					),
				),
			),
		)

		await expect(fetchExamSetupForm("frm")).resolves.toMatchObject({
			examPart1SelectionInfo: [],
			examPart2SelectionInfo: [],
		})
	})

	// The regression this replaced: a 502 used to throw, so the panel fell
	// through to its generic "unavailable" copy and the pending-reschedule
	// screen — the one that tells the member there is an unpaid order to settle
	// — was unreachable. The payload is what makes a refusal a refusal.
	it("returns a 502 pending-reschedule refusal instead of throwing", async () => {
		server.use(
			http.get(EXAM_SETUP_PATH, () =>
				HttpResponse.json(
					memberPortalEnvelope(
						examSetupView({
							statusCode: 502,
							statusMessage: "Pending Exam Reschedule already exists",
						}),
					),
					{ status: 502 },
				),
			),
		)

		await expect(fetchExamSetupForm("frm")).resolves.toMatchObject({
			statusCode: 502,
			statusMessage: "Pending Exam Reschedule already exists",
		})
	})

	it("returns a 501 unsupported-programme refusal", async () => {
		server.use(
			http.get(EXAM_SETUP_PATH, () =>
				HttpResponse.json(
					memberPortalEnvelope(
						examSetupView({
							statusCode: 501,
							statusMessage: "Invalid Program Type",
						}),
					),
					{ status: 501 },
				),
			),
		)

		await expect(fetchExamSetupForm("frm")).resolves.toMatchObject({
			statusCode: 501,
		})
	})

	// No payload means the request never ran — an expired session, an unhandled
	// exception. That is not a refusal and must still surface as an error.
	it("throws when the failure carries no payload", async () => {
		server.use(
			http.get(EXAM_SETUP_PATH, () =>
				HttpResponse.json(memberPortalError(401, "Session expired"), {
					status: 401,
				}),
			),
		)

		await expect(fetchExamSetupForm("frm")).rejects.toMatchObject({
			messages: ["Session expired"],
		})
	})
})
