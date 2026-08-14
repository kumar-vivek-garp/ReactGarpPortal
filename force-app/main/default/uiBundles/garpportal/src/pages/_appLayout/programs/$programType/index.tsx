import { createFileRoute } from "@tanstack/react-router"

import { ProgramDetailPanel } from "@/components/organisms/program-detail-panel"
import { pageTitle } from "@/lib/document-title"
import { programTypeSlug } from "@/lib/program-card-links"

export const Route = createFileRoute("/_appLayout/programs/$programType/")({
	head: ({ params }) => ({
		meta: [
			{
				title: pageTitle(
					programTypeSlug(params.programType).toUpperCase() ||
						"Program",
				),
			},
		],
	}),
	component: ProgramDetailPage,
})

function ProgramDetailPage() {
	const { programType } = Route.useParams()
	return <ProgramDetailPanel programType={programType} />
}
