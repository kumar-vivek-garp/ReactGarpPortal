import { createFileRoute } from "@tanstack/react-router"

import {
	CpdActivitiesPending,
	PAGE_PENDING_MIN_MS,
	PAGE_PENDING_MS,
} from "@/components/molecules/page-pending"
import { CpdActivitiesPanel } from "@/components/organisms/cpd-activities-panel"
import {
	CPD_ACTIVITIES_TITLE,
	cpdActivitiesSearchSchema,
} from "@/config/cpd"
import { pageTitle } from "@/lib/document-title"

export const Route = createFileRoute("/_appLayout/cpd/activities/")({
	validateSearch: cpdActivitiesSearchSchema,
	head: () => ({
		meta: [{ title: pageTitle(CPD_ACTIVITIES_TITLE) }],
	}),
	pendingMs: PAGE_PENDING_MS,
	pendingMinMs: PAGE_PENDING_MIN_MS,
	pendingComponent: CpdActivitiesPending,
	component: CpdActivities,
})

function CpdActivities() {
	const search = Route.useSearch()
	return <CpdActivitiesPanel {...search} />
}
