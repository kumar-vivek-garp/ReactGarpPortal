import { createFileRoute } from "@tanstack/react-router";

import { pageTitle } from "@/lib/document-title";

export const Route = createFileRoute("/_appLayout/events/")({
	head: () => ({
		meta: [{ title: pageTitle("My Events") }],
	}),
	component: Events,
});

function Events() {
	return <div>Events</div>;
}
