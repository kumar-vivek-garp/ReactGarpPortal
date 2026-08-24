import { createFileRoute, redirect } from "@tanstack/react-router"

/**
 * The legacy single-activity path, kept as a redirect.
 *
 * MyGarp served `/cpd-activities-detail/{id}` from the same component as the
 * browse page, scoped to one row — so this is a search param on the real page
 * rather than a route of its own. Existing links keep resolving, and unlike
 * the legacy's own "View All Activities" the scope can then be dropped
 * without the address bar going stale.
 */
export const Route = createFileRoute(
	"/_appLayout/cpd-activities-detail/$activityId/",
)({
	beforeLoad: ({ params }) => {
		throw redirect({
			to: "/cpd/activities",
			search: { activityId: params.activityId.trim() || undefined },
			replace: true,
		})
	},
})
