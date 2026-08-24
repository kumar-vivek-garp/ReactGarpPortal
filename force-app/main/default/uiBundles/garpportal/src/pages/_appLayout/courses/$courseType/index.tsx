import { createFileRoute } from "@tanstack/react-router"

import {
	PAGE_PENDING_MIN_MS,
	PAGE_PENDING_MS,
	ProgramDetailPending,
} from "@/components/molecules/page-pending"
import { CourseDetailPanel } from "@/components/organisms/course-detail-panel"
import { pageTitle } from "@/lib/document-title"

export const Route = createFileRoute("/_appLayout/courses/$courseType/")({
	head: ({ params }) => ({
		meta: [
			{ title: pageTitle(params.courseType.toUpperCase() || "Course") },
		],
	}),
	pendingMs: PAGE_PENDING_MS,
	pendingMinMs: PAGE_PENDING_MIN_MS,
	pendingComponent: ProgramDetailPending,
	component: CoursePage,
})

function CoursePage() {
	const { courseType } = Route.useParams()
	return <CourseDetailPanel courseType={courseType} />
}
