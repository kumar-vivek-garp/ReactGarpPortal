import { http, HttpResponse } from "msw"
import { describe, expect, it } from "vitest"

import { AppError } from "@/api/client"
import { markExamResultViewed } from "@/api/exam-results/mark-viewed"
import type { ExamResultViewedResult } from "@/api/exam-results/types"
import {
	memberPortalEnvelope,
	memberPortalError,
} from "@/testing/factories/envelope"
import { server } from "@/testing/msw/server"

const VIEWED_PATH = "/services/apexrest/memberportal/examResultViewed"

describe("markExamResultViewed", () => {
	it("refuses a blank id before it reaches the network", async () => {
		await expect(markExamResultViewed("   ")).rejects.toMatchObject({
			messages: ["An exam attempt id is required."],
			status: 400,
		})
	})

	it("posts the trimmed id and returns the stamp result", async () => {
		let body: unknown
		const result: ExamResultViewedResult = {
			statusMessage: "Marked",
			statusCode: 200,
		}
		server.use(
			http.post(VIEWED_PATH, async ({ request }) => {
				body = await request.json()
				return HttpResponse.json(memberPortalEnvelope(result))
			}),
		)

		await expect(markExamResultViewed("  a0A1  ")).resolves.toEqual(result)
		expect(body).toEqual({ examAttemptId: "a0A1" })
	})

	it("throws the inner refusal even on an HTTP 200", async () => {
		server.use(
			http.post(VIEWED_PATH, () =>
				HttpResponse.json(
					memberPortalEnvelope({
						statusMessage: "Attempt not found",
						statusCode: 404,
					}),
				),
			),
		)

		await expect(markExamResultViewed("a0A1")).rejects.toMatchObject({
			messages: ["Attempt not found"],
			status: 404,
		})
	})

	it("falls back to readable wording when the refusal is silent", async () => {
		server.use(
			http.post(VIEWED_PATH, () =>
				HttpResponse.json(
					memberPortalEnvelope({ statusMessage: "  ", statusCode: 500 }),
				),
			),
		)

		await expect(markExamResultViewed("a0A1")).rejects.toMatchObject({
			messages: ["Unable to mark this exam result as viewed."],
		})
	})

	it("maps a transport failure to AppError with the server message", async () => {
		server.use(
			http.post(VIEWED_PATH, () =>
				HttpResponse.json(memberPortalError(500, "Stamp service down"), {
					status: 500,
				}),
			),
		)

		const failure = markExamResultViewed("a0A1")
		await expect(failure).rejects.toBeInstanceOf(AppError)
		await expect(failure).rejects.toMatchObject({
			messages: ["Stamp service down"],
		})
	})
})
