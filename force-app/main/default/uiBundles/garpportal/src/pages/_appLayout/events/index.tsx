import { createFileRoute } from "@tanstack/react-router"

import { EventsPanel } from "@/components/organisms/events-panel"
import { eventsSearchSchema } from "@/config/events"
import { pageTitle } from "@/lib/document-title"

export const Route = createFileRoute("/_appLayout/events/")({
	validateSearch: eventsSearchSchema,
	head: () => ({
		meta: [{ title: pageTitle("My Events") }],
	}),
	component: Events,
})

function Events() {
	const { tab } = Route.useSearch()
	return <EventsPanel tab={tab} />
}
