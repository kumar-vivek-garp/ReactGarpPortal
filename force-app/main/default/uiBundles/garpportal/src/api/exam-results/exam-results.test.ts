import { http, HttpResponse } from "msw"
import { describe, expect, it } from "vitest"

import { AppError } from "@/api/client"
import { fetchExamResults } from "@/api/exam-results/exam-results"
import { examResultsQueryOptions } from "@/api/exam-results/query-options"
import type { ExamResult } from "@/api/exam-results/types"
import {
	memberPortalEnvelope,
	memberPortalError,
} from "@/testing/factories/envelope"
import { server } from "@/testing/msw/server"

const EXAM_RESULTS_PATH = "/services/apexrest/memberportal/examResults"

function examResult(overrides: Partial<ExamResult> = {}): ExamResult {
	return {
		id: "a0A1",
		examLabel: "FRM Part I",
		examType: "FRM_P1",
		programType: "FRM",
		examPart: "I",
		examDate: "2026-05-16",
		administrationName: "May 2026",
		result: "Pass",
		outcome: "pass",
		message: null,
		showQuartiles: true,
		quartiles: [{ topic: 1, name: "Foundations of Risk", rank: 1 }],
		resultsReleaseDate: null,
		resultsLetterUrl: "/apex/ResultsLetter?id=a0A1",
		quartilesUrl: null,
		...overrides,
	}
}

describe("fetchExamResults", () => {
	it("returns the attempt list from the envelope", async () => {
		const rows = [examResult(), examResult({ id: "a0A2", outcome: "pending" })]
		server.use(
			http.get(EXAM_RESULTS_PATH, () =>
				HttpResponse.json(memberPortalEnvelope(rows)),
			),
		)

		await expect(fetchExamResults()).resolves.toEqual(rows)
	})

	it("degrades a non-array payload to an empty list", async () => {
		server.use(
			http.get(EXAM_RESULTS_PATH, () =>
				HttpResponse.json(memberPortalEnvelope({ not: "a list" })),
			),
		)

		await expect(fetchExamResults()).resolves.toEqual([])
	})

	it("surfaces the server's error message as AppError", async () => {
		server.use(
			http.get(EXAM_RESULTS_PATH, () =>
				HttpResponse.json(memberPortalError(500, "Results backend down"), {
					status: 500,
				}),
			),
		)

		const failure = fetchExamResults()
		await expect(failure).rejects.toBeInstanceOf(AppError)
		await expect(failure).rejects.toMatchObject({
			messages: ["Results backend down"],
		})
	})
})

describe("examResultsQueryOptions", () => {
	it("keys the list query and opts into toasting failures", () => {
		expect(examResultsQueryOptions.queryKey).toEqual(["exam-results", "list"])
		expect(examResultsQueryOptions.meta).toMatchObject({ toastError: true })
	})
})
