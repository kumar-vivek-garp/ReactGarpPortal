import { expect, test } from "@playwright/test"

import type { AlertBarView } from "@/api/alert-bar"
import type { ExamResult, ExamResultViewedResult } from "@/api/exam-results"
import { installMockOrg } from "../support/mock-org"
import { dashboardActionSet } from "../support/payloads"

/**
 * Exam results journeys: the page filters the member-wide list to the
 * programme in the route, renders released and pending attempts, and stamps
 * released ones viewed through the real `examResultViewed` action — safe to
 * assert here because the write is mocked.
 */

/** No floating alert over the page (see programs.spec.ts). */
const NO_ALERT = {
	statusMessage: null,
	statusCode: 200,
	examType: null,
	examPart: null,
	alertStatus: null,
	deadline: null,
	orderId: null,
	route: null,
} satisfies AlertBarView

function examResult(overrides: Partial<ExamResult>): ExamResult {
	return {
		id: "att-1",
		examLabel: "FRM Part I",
		examType: "FRM",
		programType: "FRM",
		examPart: "I",
		examDate: "2026-05-16",
		administrationName: "May 2026",
		result: null,
		outcome: "pending",
		message: null,
		showQuartiles: false,
		quartiles: [],
		resultsReleaseDate: null,
		resultsLetterUrl: null,
		quartilesUrl: null,
		...overrides,
	}
}

/** One released pass with quartiles, one still awaiting release. */
const EXAM_RESULTS: ExamResult[] = [
	examResult({
		id: "att-pass",
		result: "Pass",
		outcome: "pass",
		showQuartiles: true,
		quartiles: [
			{ topic: 1, name: "Foundations of Risk Management", rank: 1 },
			{ topic: 2, name: "Quantitative Analysis", rank: 2 },
		],
	}),
	examResult({
		id: "att-pending",
		examLabel: "FRM Part II",
		examPart: "II",
		examDate: "2026-11-21",
		administrationName: "November 2026",
		resultsReleaseDate: "2027-01-02",
	}),
]

const VIEWED_RESULT = {
	statusMessage: null,
	statusCode: 200,
} satisfies ExamResultViewedResult

test.describe("exam results", () => {
	test("the FRM results render and the released attempt is stamped viewed", async ({
		page,
	}) => {
		const org = await installMockOrg(page, {
			actions: {
				...dashboardActionSet(),
				alertBar: NO_ALERT,
				examResults: EXAM_RESULTS,
				examResultViewed: VIEWED_RESULT,
			},
		})
		await page.goto("/programs/frm/results")

		await expect(
			page.getByRole("heading", { name: "FRM Exam Results", level: 1 }),
		).toBeVisible()

		// Both attempts, with their outcomes.
		await expect(page.getByText("FRM Part I", { exact: true })).toBeVisible()
		await expect(page.getByText("Pass", { exact: true })).toBeVisible()
		await expect(page.getByText("FRM Part II", { exact: true })).toBeVisible()
		await expect(page.getByText(/Results are expected on/)).toBeVisible()

		// Summary strip counts the filtered set. `exact` keeps the chip apart
		// from the pending card's own "Awaiting results" badge.
		await expect(page.getByText("Total", { exact: true })).toBeVisible()
		await expect(page.getByText("Passed", { exact: true })).toBeVisible()
		await expect(page.getByText("Awaiting", { exact: true })).toBeVisible()

		// The auto-fired viewed stamp: only the RELEASED attempt is marked —
		// the pending one has no result to clear a "new" marker for.
		await expect
			.poll(() => org.hits("examResultViewed"))
			.toBeGreaterThanOrEqual(1)
		const call = org.of("examResultViewed")[0]
		expect(call.method).toBe("POST")
		expect(JSON.parse(call.postData ?? "{}")).toEqual({
			examAttemptId: "att-pass",
		})
		expect(
			org
				.of("examResultViewed")
				.some((c) => c.postData?.includes("att-pending")),
		).toBe(false)
	})
})
