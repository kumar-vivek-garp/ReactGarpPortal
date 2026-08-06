import { createFileRoute } from "@tanstack/react-router";

export const Route = createFileRoute("/_appLayout/events/")({
	component: Events,
});

function Events() {
	return <div>Events</div>;
}
