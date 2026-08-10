import { createFileRoute } from "@tanstack/react-router"

import { DashboardPanel } from "@/components/organisms/dashboard-panel"
import { pageTitle } from "@/lib/document-title"

export const Route = createFileRoute("/_appLayout/dashboard/")({
	head: () => ({
		meta: [{ title: pageTitle("Home") }],
	}),
	component: Dashboard,
})

function Dashboard() {
	return <DashboardPanel />
}
