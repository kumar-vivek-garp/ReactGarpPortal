import { createFileRoute } from "@tanstack/react-router"

import { StudyMaterialsPanel } from "@/components/organisms/study-materials-panel"
import { studyMaterialsSearchSchema } from "@/config/study-materials"
import { pageTitle } from "@/lib/document-title"

export const Route = createFileRoute("/_appLayout/study-materials/")({
	validateSearch: studyMaterialsSearchSchema,
	head: () => ({
		meta: [{ title: pageTitle("Study Materials") }],
	}),
	component: StudyMaterials,
})

function StudyMaterials() {
	const { tab } = Route.useSearch()
	return <StudyMaterialsPanel tab={tab} />
}
