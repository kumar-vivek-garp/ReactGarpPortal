import { createFileRoute } from "@tanstack/react-router"

import { redirectMemberToEventForm } from "@/auth/registration-guard"
import { EventRegistrationPanel } from "@/components/forms/event-registration/event-registration-panel"
import {
	EVENT_REGISTRATION_TITLES,
	eventRegistrationSearchSchema,
} from "@/config/event-registration"
import { pageTitle } from "@/lib/document-title"

/**
 * Public event registration — `/registration/event/<id>`, the legacy address
 * already in circulation in GARP marketing email.
 *
 * A static sibling chain that outranks `/registration/$programType/$regCode`;
 * without that ranking the event id would be swallowed as a reg code on the
 * exam form. Also a payment-return address: the checkout success and cancel
 * URLs are built from wherever the form was served.
 */
export const Route = createFileRoute(
	"/_publicFormLayout/registration/event/$eventId/",
)({
	validateSearch: eventRegistrationSearchSchema,
	beforeLoad: redirectMemberToEventForm("event"),
	head: () => ({
		meta: [{ title: pageTitle(EVENT_REGISTRATION_TITLES.event) }],
	}),
	component: PublicEventRegistrationPage,
})

function PublicEventRegistrationPage() {
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
