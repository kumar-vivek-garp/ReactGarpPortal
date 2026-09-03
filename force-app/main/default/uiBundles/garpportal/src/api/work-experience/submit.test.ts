import { http, HttpResponse } from "msw"
import { describe, expect, it } from "vitest"

import { submitCv } from "@/api/work-experience/submit"
import { memberPortalEnvelope } from "@/testing/factories/envelope"
import { server } from "@/testing/msw/server"

const CV_SUBMIT_PATH = "/services/apexrest/memberportal/cvSubmit"

/**
 * Apex re-checks the months against `totalTimeAllotted`, which is computed
 * differently from the button gate — so a refusal can hide inside an HTTP
 * 200 envelope and must still surface its own sentence.
 */
describe("submitCv 200-with-error defence", () => {
	it("surfaces the inner refusal from an HTTP 200 envelope", async () => {
		server.use(
			http.post(CV_SUBMIT_PATH, () =>
				HttpResponse.json(
					memberPortalEnvelope({
						statusCode: 501,
						statusMessage:
							"Work Experience is not more than the required 24 months",
					}),
				),
			),
		)

		await expect(submitCv("FRM")).rejects.toMatchObject({
			status: 501,
			messages: ["Work Experience is not more than the required 24 months"],
		})
	})

	it("falls back to its own sentence when the refusal is silent", async () => {
		server.use(
			http.post(CV_SUBMIT_PATH, () =>
				HttpResponse.json(
					memberPortalEnvelope({ statusCode: 500, statusMessage: "  " }),
				),
			),
		)

		await expect(submitCv("FRM")).rejects.toMatchObject({
			messages: ["Your work experience could not be submitted."],
		})
	})
})
