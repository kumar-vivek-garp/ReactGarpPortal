import { createFileRoute } from "@tanstack/react-router"

import {
	PAGE_PENDING_MIN_MS,
	PAGE_PENDING_MS,
	WorkExperiencePending,
} from "@/components/molecules/page-pending"
import { WorkExperiencePanel } from "@/components/organisms/work-experience-panel"
import { WORK_EXPERIENCE_TITLE } from "@/config/work-experience"
import { pageTitle } from "@/lib/document-title"

export const Route = createFileRoute(
	"/_appLayout/programs/$programType/work-experience/",
)({
	head: ({ params }) => ({
		meta: [
			{
				title: pageTitle(
					`${params.programType.toUpperCase()} ${WORK_EXPERIENCE_TITLE}`,
				),
			},
		],
	}),
	pendingMs: PAGE_PENDING_MS,
	pendingMinMs: PAGE_PENDING_MIN_MS,
	pendingComponent: WorkExperiencePending,
	component: WorkExperience,
})

function WorkExperience() {
	const { programType } = Route.useParams()
	return <WorkExperiencePanel programType={programType} />
}
