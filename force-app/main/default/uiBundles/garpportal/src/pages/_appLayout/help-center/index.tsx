import { createFileRoute } from "@tanstack/react-router";

export const Route = createFileRoute("/_appLayout/help-center/")({
	component: HelpCenter,
});

function HelpCenter() {
	return <div>Help Center</div>;
}
