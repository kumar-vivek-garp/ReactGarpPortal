import { useQuery } from "@tanstack/react-query"

import { eventsQueryOptions } from "@/api/events"

/** Event listing buckets from `GET /memberportal/events`. */
export function useEvents() {
	return useQuery(eventsQueryOptions)
}
