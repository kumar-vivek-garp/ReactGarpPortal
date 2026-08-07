import { createFileRoute } from "@tanstack/react-router";

import { pageTitle } from "@/lib/document-title";

export const Route = createFileRoute("/_appLayout/help-center/")({
	head: () => ({
		meta: [{ title: pageTitle("Help Center") }],
	}),
	component: HelpCenter,
});

function HelpCenter() {
	return <div>Help Center</div>;
}
