import { createFileRoute, Outlet } from "@tanstack/react-router";

export const Route = createFileRoute("/_appLayout")({
	component: AppLayout,
});

function AppLayout() {
	return <Outlet />;
}
