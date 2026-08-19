import { createFileRoute } from "@tanstack/react-router"

import { DashboardPending, PAGE_PENDING_MIN_MS, PAGE_PENDING_MS } from "@/components/molecules/page-pending"
import { dashboardQueryOptions } from "@/api/dashboard"
import { eventsQueryOptions } from "@/api/events"
import { programsQueryOptions } from "@/api/programs"
import { DashboardPanel } from "@/components/organisms/dashboard-panel"
import { pageTitle } from "@/lib/document-title"

export const Route = createFileRoute("/_appLayout/dashboard/")({
	// Prefetch only — awaiting here delays first paint and hurts LCP (text
	// can't paint until memberportal APIs return). Dashboard composes programs + events.
	loader: ({ context }) => {
		void context.queryClient.prefetchQuery(dashboardQueryOptions)
		void context.queryClient.prefetchQuery(programsQueryOptions)
		void context.queryClient.prefetchQuery(eventsQueryOptions)
	},
	head: () => ({
		meta: [
			{ title: pageTitle("Home") },
			{
				name: "description",
				content:
					"GARP Member Portal home — enrolled programs, upcoming events, and member directory.",
			},
		],
	}),
	pendingMs: PAGE_PENDING_MS,
	pendingMinMs: PAGE_PENDING_MIN_MS,
	pendingComponent: DashboardPending,
	component: Dashboard,
})

function Dashboard() {
	return <DashboardPanel />
}
