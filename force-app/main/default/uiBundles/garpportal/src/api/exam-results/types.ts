/**
 * Apex `GARP_Portal_ExamResultsService` DTOs for `examResults` /
 * `examResultViewed`.
 */

export type ExamOutcome =
	| "pass"
	| "fail"
	| "pending"
	| "deferred"
	| "violation"
	| "notGraded"
	| "noShow"
	| string

export type ExamQuartile = {
	/** 1-based topic index. */
	topic: number
	/** Category_N name — null on older attempts. */
	name: string | null
	/** 1 = top quartile. */
	rank: number
}

/** One exam attempt row from `GET /memberportal/examResults`. */
export type ExamResult = {
	id: string
	examLabel: string | null
	examType: string | null
	/** FRM / ERP / SCR / RiskAI as reported by the administration. */
	programType: string | null
	/** I, II, FULL, etc. */
	examPart: string | null
	/** ISO date. */
	examDate: string | null
	administrationName: string | null
	result: string | null
	outcome: ExamOutcome
	message: string | null
	showQuartiles: boolean
	quartiles: ExamQuartile[]
	/** ISO date — expected publish day while pending. */
	resultsReleaseDate: string | null
	/** Visualforce results letter URL once released. */
	resultsLetterUrl: string | null
	/** Performance-analysis PDF URL. */
	quartilesUrl: string | null
}

/** `POST /memberportal/examResultViewed` body result. */
export type ExamResultViewedResult = {
	statusMessage: string | null
	statusCode: number | null
}

export type { MemberPortalEnvelope } from "@/api/account/types"
