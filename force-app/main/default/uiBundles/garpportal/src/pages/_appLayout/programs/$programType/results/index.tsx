import { createFileRoute } from "@tanstack/react-router"

import {
	ExamResultsPending,
	PAGE_PENDING_MIN_MS,
	PAGE_PENDING_MS,
} from "@/components/molecules/page-pending"
import { ExamResultsPanel } from "@/components/organisms/exam-results-panel"
import { pageTitle } from "@/lib/document-title"
import { examResultsRouteSlug } from "@/lib/exam-results-presentation"

export const Route = createFileRoute(
	"/_appLayout/programs/$programType/results/",
)({
	head: ({ params }) => ({
		meta: [
			{
				title: pageTitle(
					`${examResultsRouteSlug(params.programType).toUpperCase() || "Program"} Exam Results`,
				),
			},
		],
	}),
	pendingMs: PAGE_PENDING_MS,
	pendingMinMs: PAGE_PENDING_MIN_MS,
	pendingComponent: ExamResultsPending,
	component: ExamResultsPage,
})

function ExamResultsPage() {
	const { programType } = Route.useParams()
	return <ExamResultsPanel programType={programType} />
}
