import { queryOptions } from "@tanstack/react-query"

import { fetchEvents } from "@/api/events/events"

export const eventsQueryKeys = {
	all: ["events"] as const,
	view: ["events", "view"] as const,
}

export const eventsQueryOptions = queryOptions({
	queryKey: eventsQueryKeys.view,
	queryFn: fetchEvents,
	staleTime: 60_000,
	retry: false,
	meta: {
		toastError: true,
		errorTitle: "Unable to load events",
	},
})
