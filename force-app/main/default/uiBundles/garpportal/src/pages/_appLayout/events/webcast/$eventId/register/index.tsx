import { createFileRoute } from "@tanstack/react-router"

import { EventRegistrationPanel } from "@/components/forms/event-registration/event-registration-panel"
import {
	EVENT_REGISTRATION_TITLES,
	eventRegistrationSearchSchema,
} from "@/config/event-registration"
import { pageTitle } from "@/lib/document-title"

/**
 * In-portal webcast registration — the member twin of
 * `/registration/webcast/<id>`. See the event twin for the guard note.
 */
export const Route = createFileRoute(
	"/_appLayout/events/webcast/$eventId/register/",
)({
	validateSearch: eventRegistrationSearchSchema,
	head: () => ({
		meta: [{ title: pageTitle(EVENT_REGISTRATION_TITLES.webcast) }],
	}),
	component: MemberWebcastRegistrationPage,
})

function MemberWebcastRegistrationPage() {
	const { eventId } = Route.useParams()
	const search = Route.useSearch()

	return (
		<EventRegistrationPanel
			variant="webcast"
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
