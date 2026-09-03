import { http, HttpResponse } from "msw"
import { describe, expect, it } from "vitest"

import { fetchExamSetupFees } from "@/api/exam-setup/fees"
import type { ExamSetupFee } from "@/api/exam-setup/types"
import {
	memberPortalEnvelope,
	memberPortalError,
} from "@/testing/factories/envelope"
import { server } from "@/testing/msw/server"

const FEES_PATH = "/services/apexrest/memberportal/examSetupFees"

const changeFee: ExamSetupFee = {
	name: "Standard exam administration change fee",
	type: "fee",
	amount: 250,
	description: null,
	productCode: "FRM-CHG",
	glCode: null,
	accountingCode: null,
	examRegId: null,
	examSiteId: null,
}

describe("fetchExamSetupFees", () => {
	it("refuses a blank modification id before it reaches the network", async () => {
		await expect(fetchExamSetupFees("   ")).rejects.toMatchObject({
			messages: ["A modification id is required."],
		})
	})

	it("posts the trimmed id and returns the priced lines", async () => {
		let body: unknown
		const view = {
			statusMessage: null,
			statusCode: 200,
			examType: "FRM",
			fees: [changeFee],
			examEmailParts: null,
			deferralSubType: "Deferral Standard",
			transactionType: null,
		}
		server.use(
			http.post(FEES_PATH, async ({ request }) => {
				body = await request.json()
				return HttpResponse.json(memberPortalEnvelope(view))
			}),
		)

		await expect(fetchExamSetupFees(" a0Mxx1 ")).resolves.toEqual(view)
		expect(body).toEqual({ modificationId: "a0Mxx1" })
	})

	it("normalizes null fees to an empty list", async () => {
		server.use(
			http.post(FEES_PATH, () =>
				HttpResponse.json(
					memberPortalEnvelope({
						statusMessage: null,
						statusCode: 200,
						examType: "FRM",
						fees: null,
						examEmailParts: null,
						deferralSubType: null,
						transactionType: null,
					}),
				),
			),
		)

		await expect(fetchExamSetupFees("a0Mxx1")).resolves.toMatchObject({
			fees: [],
		})
	})

	it("throws the inner refusal even on an HTTP 200", async () => {
		server.use(
			http.post(FEES_PATH, () =>
				HttpResponse.json(
					memberPortalEnvelope({
						statusMessage: "Modification not found",
						statusCode: 404,
						examType: null,
						fees: null,
						examEmailParts: null,
						deferralSubType: null,
						transactionType: null,
					}),
				),
			),
		)

		await expect(fetchExamSetupFees("a0Mxx1")).rejects.toMatchObject({
			messages: ["Modification not found"],
			status: 404,
		})
	})

	it("surfaces the server's error message on a transport failure", async () => {
		server.use(
			http.post(FEES_PATH, () =>
				HttpResponse.json(memberPortalError(500, "Pricing down"), { status: 500 }),
			),
		)

		await expect(fetchExamSetupFees("a0Mxx1")).rejects.toMatchObject({
			messages: ["Pricing down"],
		})
	})
})
