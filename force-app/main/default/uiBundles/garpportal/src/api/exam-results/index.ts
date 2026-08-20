export type {
	ExamOutcome,
	ExamQuartile,
	ExamResult,
	ExamResultViewedResult,
	MemberPortalEnvelope,
} from "@/api/exam-results/types"
export { fetchExamResults } from "@/api/exam-results/exam-results"
export { markExamResultViewed } from "@/api/exam-results/mark-viewed"
export {
	examResultsQueryKeys,
	examResultsQueryOptions,
} from "@/api/exam-results/query-options"
