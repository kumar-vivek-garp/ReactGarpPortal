import { createFileRoute } from "@tanstack/react-router"

import { eventsQueryOptions } from "@/api/events"
import { EventsPending, PAGE_PENDING_MIN_MS, PAGE_PENDING_MS } from "@/components/molecules/page-pending"
import { EventsPanel } from "@/components/organisms/events-panel"
import { eventsSearchSchema } from "@/config/events"
import { pageTitle } from "@/lib/document-title"

export const Route = createFileRoute("/_appLayout/events/")({
	validateSearch: eventsSearchSchema,
	loader: ({ context }) => {
		void context.queryClient.prefetchQuery(eventsQueryOptions)
	},
	head: () => ({
		meta: [{ title: pageTitle("My Events") }],
	}),
	pendingMs: PAGE_PENDING_MS,
	pendingMinMs: PAGE_PENDING_MIN_MS,
	pendingComponent: EventsPending,
	component: Events,
})

function Events() {
	const { type } = Route.useSearch()
	return <EventsPanel type={type} />
}
