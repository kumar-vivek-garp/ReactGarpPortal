import { useQuery } from "@tanstack/react-query"

import { eventRegistrationQueryOptions } from "@/api/registration/query-options"
import type { EventVariant } from "@/api/registration/event-types"

/** One event's registration load — not-found and refusal arrive as data. */
export function useEventRegistrationLoad(
	variant: EventVariant,
	eventId: string,
) {
	return useQuery(eventRegistrationQueryOptions(variant, eventId))
}
