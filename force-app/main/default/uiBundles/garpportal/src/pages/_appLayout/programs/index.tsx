import { createFileRoute } from "@tanstack/react-router";

import { pageTitle } from "@/lib/document-title";

export const Route = createFileRoute("/_appLayout/programs/")({
	head: () => ({
		meta: [{ title: pageTitle("Programs") }],
	}),
	component: Programs,
});

function Programs() {
	return <div>Programs</div>;
}
