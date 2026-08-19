import { createFileRoute } from "@tanstack/react-router"

import { PAGE_PENDING_MIN_MS, PAGE_PENDING_MS, StudyMaterialsPending } from "@/components/molecules/page-pending"
import { StudyMaterialsPanel } from "@/components/organisms/study-materials-panel"
import { studyMaterialsSearchSchema } from "@/config/study-materials"
import { pageTitle } from "@/lib/document-title"

export const Route = createFileRoute("/_appLayout/study-materials/")({
	validateSearch: studyMaterialsSearchSchema,
	head: () => ({
		meta: [{ title: pageTitle("Study Materials") }],
	}),
	pendingMs: PAGE_PENDING_MS,
	pendingMinMs: PAGE_PENDING_MIN_MS,
	pendingComponent: StudyMaterialsPending,
	component: StudyMaterials,
})

function StudyMaterials() {
	const { tab, view } = Route.useSearch()
	return <StudyMaterialsPanel tab={tab} view={view} />
}
