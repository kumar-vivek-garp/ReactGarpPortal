import { createFileRoute } from "@tanstack/react-router"

import { EventRegistrationPanel } from "@/components/forms/event-registration/event-registration-panel"
import {
	EVENT_REGISTRATION_TITLES,
	eventRegistrationSearchSchema,
} from "@/config/event-registration"
import { pageTitle } from "@/lib/document-title"

/**
 * In-portal event registration — the member twin of
 * `/registration/event/<id>`, prefilled from their contact record.
 *
 * No guard of its own: `_appLayout`'s guard hands a guest to the public twin
 * via `publicRegistrationFallback`, carrying the whole query string.
 */
export const Route = createFileRoute(
	"/_appLayout/events/event/$eventId/register/",
)({
	validateSearch: eventRegistrationSearchSchema,
	head: () => ({
		meta: [{ title: pageTitle(EVENT_REGISTRATION_TITLES.event) }],
	}),
	component: MemberEventRegistrationPage,
})

function MemberEventRegistrationPage() {
	const { eventId } = Route.useParams()
	const search = Route.useSearch()

	return (
		<EventRegistrationPanel
			variant="event"
			eventId={eventId}
			paymentReturn={
				search.stripe_return === "1" ? { orderNumber: search.on } : null
			}
			checkoutCancelled={
				search.checkout_cancelled === "1" ? { orderId: search.oid } : null
			}
		/>
	)
}
