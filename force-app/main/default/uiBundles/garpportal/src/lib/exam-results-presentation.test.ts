import { describe, expect, it } from "vitest"

import type { ExamResult } from "@/api/exam-results"
import {
	buildExamResultsPagePresentation,
	buildExamResultsPreviewRows,
	examResultProgramSlugs,
	examResultMatchesProgramSlug,
	examResultsRouteSlug,
	outcomePresentation,
} from "@/lib/exam-results-presentation"
import { programResultsPath } from "@/lib/program-card-links"

function sample(overrides: Partial<ExamResult> = {}): ExamResult {
	return {
		id: "a1",
		examLabel: "FRM Exam Part I",
		examType: "FRM",
		programType: "FRM",
		examPart: "I",
		examDate: "2025-11-15",
		administrationName: "November 2025",
		result: "Pass",
		outcome: "pass",
		message: "Congratulations!",
		showQuartiles: true,
		quartiles: [
			{ topic: 1, name: "Foundations", rank: 1 },
			{ topic: 2, name: "Quant", rank: 2 },
		],
		resultsReleaseDate: "2025-12-01",
		resultsLetterUrl: "/apex/Exam_Results_Letter_November2025?id=a1",
		quartilesUrl: "/apex/PerformanceAnalysisAsPDF?id=a1",
		...overrides,
	}
}

describe("examResultsRouteSlug", () => {
	it("normalizes rai to riskai", () => {
		expect(examResultsRouteSlug("rai")).toBe("riskai")
		expect(examResultsRouteSlug("RiskAI")).toBe("riskai")
		expect(examResultsRouteSlug("FRM")).toBe("frm")
	})
})

describe("programResultsPath", () => {
	it("nests under program detail", () => {
		expect(programResultsPath("frm")).toBe("/programs/frm/results")
		expect(programResultsPath("rai")).toBe("/programs/riskai/results")
	})
})

describe("examResultMatchesProgramSlug", () => {
	it("matches FRM rows to frm", () => {
		expect(examResultMatchesProgramSlug(sample(), "frm")).toBe(true)
		expect(examResultMatchesProgramSlug(sample(), "scr")).toBe(false)
	})

	it("matches RiskAI / rai aliases", () => {
		const row = sample({
			programType: "RiskAI",
			examType: "RiskAI",
			examLabel: "RAI Exam",
		})
		expect(examResultMatchesProgramSlug(row, "riskai")).toBe(true)
		expect(examResultMatchesProgramSlug(row, "rai")).toBe(true)
	})
})

describe("outcomePresentation", () => {
	it("maps known outcomes", () => {
		expect(outcomePresentation("pass").tone).toBe("success")
		expect(outcomePresentation("fail").tone).toBe("danger")
		expect(outcomePresentation("pending").tone).toBe("info")
		expect(outcomePresentation("notGraded").label).toBe("Not graded")
	})
})

describe("buildExamResultsPagePresentation", () => {
	it("filters to the program and builds summary counts", () => {
		const view = buildExamResultsPagePresentation(
			[
				sample(),
				sample({
					id: "a2",
					programType: "SCR",
					examType: "SCR",
					examLabel: "SCR Exam",
					outcome: "fail",
					result: "Fail",
					showQuartiles: false,
					quartiles: [],
				}),
				sample({
					id: "a3",
					examPart: "II",
					examLabel: "FRM Exam Part II",
					outcome: "pending",
					result: null,
					showQuartiles: false,
					quartiles: [],
					resultsReleaseDate: "2026-01-15",
				}),
			],
			"frm",
		)

		expect(view.results).toHaveLength(2)
		expect(view.summary.passed).toBe(1)
		expect(view.summary.pending).toBe(1)
		expect(view.results[0].showQuartiles).toBe(true)
		expect(view.results[0].resultsLetterHref).toContain("/apex/")
		expect(view.results[1].pendingReleaseLabel).toMatch(/expected on/i)
	})
})

describe("buildExamResultsPreviewRows", () => {
	it("dedupes by program+part and returns route slugs", () => {
		const rows = buildExamResultsPreviewRows(
			[
				sample(),
				sample({ id: "a2", administrationName: "Older" }),
				sample({
					id: "a3",
					examPart: "II",
					examLabel: "FRM Exam Part II",
				}),
			],
			2,
		)
		expect(rows).toHaveLength(2)
		expect(rows[0].programSlug).toBe("frm")
		expect(rows[1].title).toBe("FRM Exam Part II")
	})
})

describe("examResultProgramSlugs", () => {
	it("collects one slug per program the member has a result for", () => {
		const slugs = examResultProgramSlugs([
			sample({ id: "1", programType: "FRM", examPart: "I" }),
			sample({ id: "2", programType: "FRM", examPart: "II" }),
			sample({ id: "3", programType: "SCR", examPart: "FULL" }),
		])
		expect([...slugs].sort()).toEqual(["frm", "scr"])
	})

	/**
	 * A chip must never point at a route that cannot serve it — the listing
	 * uses this set as its only gate.
	 */
	it("drops programs the results route cannot serve", () => {
		const slugs = examResultProgramSlugs([
			sample({ id: "1", programType: "FRM" }),
			sample({ id: "2", programType: "NotAProgram" }),
		])
		expect([...slugs]).toEqual(["frm"])
	})

	it("is empty for no results", () => {
		expect(examResultProgramSlugs([]).size).toBe(0)
		expect(examResultProgramSlugs(null).size).toBe(0)
	})
})
