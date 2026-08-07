import { createFileRoute } from "@tanstack/react-router";

import { pageTitle } from "@/lib/document-title";

export const Route = createFileRoute("/_appLayout/dashboard/")({
	head: () => ({
		meta: [{ title: pageTitle("Home") }],
	}),
	component: Dashboard,
});

function Dashboard() {
	return <div>Dashboard</div>;
}
