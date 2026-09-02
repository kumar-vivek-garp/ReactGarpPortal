import { createFileRoute } from "@tanstack/react-router"

import { EventRegistrationPanel } from "@/components/forms/event-registration/event-registration-panel"
import {
	EVENT_REGISTRATION_TITLES,
	eventRegistrationSearchSchema,
} from "@/config/event-registration"
import { pageTitle } from "@/lib/document-title"

/**
 * In-portal chapter-meeting registration — the member twin of
 * `/registration/chaptermeeting/<id>`. See the event twin for the guard note.
 */
export const Route = createFileRoute(
	"/_appLayout/events/chaptermeeting/$eventId/register/",
)({
	validateSearch: eventRegistrationSearchSchema,
	head: () => ({
		meta: [{ title: pageTitle(EVENT_REGISTRATION_TITLES.chaptermeeting) }],
	}),
	component: MemberChapterMeetingRegistrationPage,
})

function MemberChapterMeetingRegistrationPage() {
	const { eventId } = Route.useParams()
	const search = Route.useSearch()

	return (
		<EventRegistrationPanel
			variant="chaptermeeting"
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
