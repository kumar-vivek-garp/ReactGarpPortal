import { createFileRoute } from "@tanstack/react-router"

import {
	PAGE_PENDING_MIN_MS,
	PAGE_PENDING_MS,
} from "@/components/molecules/page-pending"
import { ErrataPanel } from "@/components/organisms/errata-panel"
import { pageTitle } from "@/lib/document-title"

export const Route = createFileRoute(
	"/_appLayout/programs/$programType/errata/",
)({
	head: ({ params }) => ({
		meta: [
			{
				title: pageTitle(
					`${params.programType.toUpperCase() || "Program"} Curriculum Errata`,
				),
			},
		],
	}),
	pendingMs: PAGE_PENDING_MS,
	pendingMinMs: PAGE_PENDING_MIN_MS,
	component: ErrataPage,
})

function ErrataPage() {
	const { programType } = Route.useParams()
	return <ErrataPanel programType={programType} />
}
