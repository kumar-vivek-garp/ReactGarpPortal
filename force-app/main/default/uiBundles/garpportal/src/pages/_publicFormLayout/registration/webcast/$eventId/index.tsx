import { createFileRoute } from "@tanstack/react-router"

import { redirectMemberToEventForm } from "@/auth/registration-guard"
import { EventRegistrationPanel } from "@/components/forms/event-registration/event-registration-panel"
import {
	EVENT_REGISTRATION_TITLES,
	eventRegistrationSearchSchema,
} from "@/config/event-registration"
import { pageTitle } from "@/lib/document-title"

/**
 * Public webcast registration — `/registration/webcast/<id>`, the legacy
 * address in GARP marketing email. See the event twin for why the static
 * segment matters and why payment returns land here.
 */
export const Route = createFileRoute(
	"/_publicFormLayout/registration/webcast/$eventId/",
)({
	validateSearch: eventRegistrationSearchSchema,
	beforeLoad: redirectMemberToEventForm("webcast"),
	head: () => ({
		meta: [{ title: pageTitle(EVENT_REGISTRATION_TITLES.webcast) }],
	}),
	component: PublicWebcastRegistrationPage,
})

function PublicWebcastRegistrationPage() {
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
