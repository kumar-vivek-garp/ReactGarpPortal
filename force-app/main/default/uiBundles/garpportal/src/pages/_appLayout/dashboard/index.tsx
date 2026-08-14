import { createFileRoute } from "@tanstack/react-router"

import { dashboardQueryOptions } from "@/api/dashboard"
import { eventsQueryOptions } from "@/api/events"
import { programsQueryOptions } from "@/api/programs"
import { DashboardPanel } from "@/components/organisms/dashboard-panel"
import { pageTitle } from "@/lib/document-title"

export const Route = createFileRoute("/_appLayout/dashboard/")({
	// Prefetch only — awaiting here delays first paint and hurts LCP (text
	// can't paint until memberportal APIs return). Layout already warms these.
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
	component: Dashboard,
})

function Dashboard() {
	return <DashboardPanel />
}
