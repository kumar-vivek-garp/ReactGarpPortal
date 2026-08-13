import { createFileRoute } from "@tanstack/react-router"

import { ProgramsPanel } from "@/components/organisms/programs-panel"
import { programsSearchSchema } from "@/config/programs"
import { pageTitle } from "@/lib/document-title"

export const Route = createFileRoute("/_appLayout/programs/")({
	validateSearch: programsSearchSchema,
	head: () => ({
		meta: [{ title: pageTitle("Programs") }],
	}),
	component: Programs,
})

function Programs() {
	const { tab } = Route.useSearch()
	return <ProgramsPanel tab={tab} />
}
