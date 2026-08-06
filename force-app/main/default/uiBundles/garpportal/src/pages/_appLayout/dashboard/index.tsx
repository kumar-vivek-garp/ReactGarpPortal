import { createFileRoute } from "@tanstack/react-router";

export const Route = createFileRoute("/_appLayout/dashboard/")({
	component: Dashboard,
});

function Dashboard() {
	return <div>Dashboard</div>;
}
