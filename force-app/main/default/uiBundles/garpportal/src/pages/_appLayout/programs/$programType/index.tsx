import { createFileRoute } from "@tanstack/react-router"

import { PAGE_PENDING_MIN_MS, PAGE_PENDING_MS, ProgramDetailPending } from "@/components/molecules/page-pending"
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
	pendingMs: PAGE_PENDING_MS,
	pendingMinMs: PAGE_PENDING_MIN_MS,
	pendingComponent: ProgramDetailPending,
	component: ProgramDetailPage,
})

function ProgramDetailPage() {
	const { programType } = Route.useParams()
	return <ProgramDetailPanel programType={programType} />
}
