import { createFileRoute } from "@tanstack/react-router"

import {
	ExamSetupPending,
	PAGE_PENDING_MIN_MS,
	PAGE_PENDING_MS,
} from "@/components/molecules/page-pending"
import { ExamSetupPanel } from "@/components/organisms/exam-setup-panel"
import { EXAM_SETUP_TITLE } from "@/config/exam-setup"
import { pageTitle } from "@/lib/document-title"

export const Route = createFileRoute(
	"/_appLayout/programs/$programType/exam-setup/",
)({
	head: ({ params }) => ({
		meta: [
			{
				title: pageTitle(
					`${params.programType.toUpperCase()} ${EXAM_SETUP_TITLE}`,
				),
			},
		],
	}),
	pendingMs: PAGE_PENDING_MS,
	pendingMinMs: PAGE_PENDING_MIN_MS,
	pendingComponent: ExamSetupPending,
	component: ExamSetup,
})

function ExamSetup() {
	const { programType } = Route.useParams()
	return <ExamSetupPanel programType={programType} />
}
