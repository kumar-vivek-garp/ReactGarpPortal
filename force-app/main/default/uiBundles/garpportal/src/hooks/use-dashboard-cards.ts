import { useMemo } from "react"

import { useCpd } from "@/hooks/use-cpd"
import { useDashboard } from "@/hooks/use-dashboard"
import { useEvents } from "@/hooks/use-events"
import { usePrograms } from "@/hooks/use-programs"
import { composeDashboardCards } from "@/lib/compose-dashboard-cards"

/**
 * Dashboard API cards plus Enrolled Programs / My Events from the listing
 * endpoints, using the legacy show/hide rules.
 */
export function useDashboardCards() {
	const dashboard = useDashboard()
	const programs = usePrograms()
	const events = useEvents()
	const cpd = useCpd()

	const waitingOnListings =
		(programs.isLoading && !programs.isError) ||
		(events.isLoading && !events.isError) ||
		(cpd.isLoading && !cpd.isError)

	const cards = useMemo(
		() =>
			composeDashboardCards({
				serverCards: dashboard.data?.cards ?? [],
				enrolledPrograms: programs.data?.enrolledPrograms ?? [],
				registeredEvents: events.data?.registeredEvents ?? [],
				cpd: cpd.data ?? null,
				completeness: dashboard.data?.completeness,
			}),
		[
			dashboard.data?.cards,
			dashboard.data?.completeness,
			programs.data?.enrolledPrograms,
			events.data?.registeredEvents,
			cpd.data,
		],
	)

	return {
		cards,
		isLoading: dashboard.isLoading || waitingOnListings,
		isError: dashboard.isError,
	}
}
