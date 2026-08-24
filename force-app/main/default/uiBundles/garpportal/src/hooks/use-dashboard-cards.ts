import { useMemo } from "react"

import { useAd } from "@/hooks/use-ad"
import { useCpd } from "@/hooks/use-cpd"
import { useDashboard } from "@/hooks/use-dashboard"
import { useEvents } from "@/hooks/use-events"
import { useExamNotifications } from "@/hooks/use-exam-notifications"
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
	/*
	 * Both are secondary: their cards are dropped when the data is absent, so
	 * the dashboard renders without waiting on either. Neither is included in
	 * `waitingOnListings` for that reason.
	 */
	const ad = useAd()
	const notifications = useExamNotifications()

	const waitingOnListings =
		(programs.isLoading && !programs.isError) ||
		(events.isLoading && !events.isError) ||
		(cpd.isLoading && !cpd.isError)

	const cards = useMemo(
		() =>
			composeDashboardCards({
				components: dashboard.data?.dashboardComponents ?? [],
				enrolledPrograms: programs.data?.enrolledPrograms ?? [],
				registeredEvents: events.data?.registeredEvents ?? [],
				cpd: cpd.data ?? null,
				completeness: dashboard.data?.completeness,
				ad: ad.data ?? null,
				examNotifications: notifications.data?.notifications ?? [],
			}),
		[
			dashboard.data?.dashboardComponents,
			dashboard.data?.completeness,
			programs.data?.enrolledPrograms,
			events.data?.registeredEvents,
			cpd.data,
			ad.data,
			notifications.data?.notifications,
		],
	)

	return {
		cards,
		isLoading: dashboard.isLoading || waitingOnListings,
		isError: dashboard.isError,
	}
}
