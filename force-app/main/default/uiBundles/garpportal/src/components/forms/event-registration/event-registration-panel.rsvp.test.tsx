import { screen, waitFor } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { http, HttpResponse } from "msw"
import { describe, expect, it } from "vitest"

import { EventRegistrationPanel } from "@/components/forms/event-registration/event-registration-panel"
import { memberPortalError } from "@/testing/factories/envelope"
import { eventContact, eventLoad, eventView } from "@/testing/factories/event"
import { examregGet, examregPost } from "@/testing/msw/handlers/examreg"
import { server } from "@/testing/msw/server"
import { renderWithRouterProviders } from "@/testing/router"

const DECLINE_PATH = "/services/apexrest/examreg/event/rsvpDecline"

type DeclineBody = { eventId: string; userEmail: string }

function inviteOnlyLoad(overrides: Parameters<typeof eventLoad>[0] = {}) {
	return eventLoad({
		event_x: eventView({
			isInviteOnly: true,
			rsvpCopy: "Join us for the annual dinner.",
		}),
		...overrides,
	})
}

function renderPanel() {
	return renderWithRouterProviders(
		<EventRegistrationPanel
			variant="event"
			eventId="evt-1"
			paymentReturn={null}
			checkoutCancelled={null}
		/>,
		{ user: null },
	)
}

describe("EventRegistrationPanel — RSVP gate", () => {
	it("keeps an invite-only event's form behind the gate, with the event's own copy", async () => {
		server.use(examregGet("event/info", () => inviteOnlyLoad()).handler)
		await renderPanel()

		expect(await screen.findByText("You're invited")).toBeInTheDocument()
		expect(
			screen.getByText("Join us for the annual dinner."),
		).toBeInTheDocument()
		expect(screen.getByRole("button", { name: "Accept" })).toBeInTheDocument()
		expect(
			screen.queryByRole("button", { name: "Complete Registration" }),
		).not.toBeInTheDocument()
	})

	it("turns Accept into a waitlist join when capacity is met", async () => {
		server.use(
			examregGet("event/info", () =>
				eventLoad({
					event_x: eventView({
						isInviteOnly: true,
						maxCapacityMet: true,
						rsvpWaitlistCopy: "We are full, but the waitlist is open.",
					}),
				}),
			).handler,
		)
		await renderPanel()

		expect(
			await screen.findByRole("button", { name: "Join the Waitlist" }),
		).toBeInTheDocument()
		expect(
			screen.getByText("We are full, but the waitlist is open."),
		).toBeInTheDocument()
	})

	it("reveals the form on Accept without writing anything to the server", async () => {
		const decline = examregPost<DeclineBody>("event/rsvpDecline", () => ({}))
		server.use(examregGet("event/info", () => inviteOnlyLoad()).handler, decline.handler)
		await renderPanel()

		await userEvent.click(await screen.findByRole("button", { name: "Accept" }))

		expect(
			await screen.findByRole("button", { name: "Complete Registration" }),
		).toBeInTheDocument()
		expect(screen.queryByText("You're invited")).not.toBeInTheDocument()
		expect(decline.spy.hits).toBe(0)
	})

	it("records a decline — an empty email for a guest — and shows the declined screen", async () => {
		const decline = examregPost<DeclineBody>("event/rsvpDecline", () => ({}))
		server.use(examregGet("event/info", () => inviteOnlyLoad()).handler, decline.handler)
		await renderPanel()

		await userEvent.click(await screen.findByRole("button", { name: "Decline" }))

		expect(
			await screen.findByRole("heading", { name: "Thanks for letting us know" }),
		).toBeInTheDocument()
		expect(
			screen.getByText("We've recorded that you won't be attending."),
		).toBeInTheDocument()
		expect(decline.spy.bodies).toEqual([{ eventId: "evt-1", userEmail: "" }])
	})

	it("declines with the load's contact email when the server knows who is replying", async () => {
		const decline = examregPost<DeclineBody>("event/rsvpDecline", () => ({}))
		server.use(
			examregGet("event/info", () =>
				inviteOnlyLoad({
					contact: eventContact({ email: "ada@example.test" }),
				}),
			).handler,
			decline.handler,
		)
		await renderPanel()

		await userEvent.click(await screen.findByRole("button", { name: "Decline" }))

		await waitFor(() =>
			expect(decline.spy.bodies).toEqual([
				{ eventId: "evt-1", userEmail: "ada@example.test" },
			]),
		)
	})

	it("keeps the gate up with an inline error when the decline fails", async () => {
		server.use(
			examregGet("event/info", () => inviteOnlyLoad()).handler,
			http.post(DECLINE_PATH, () =>
				HttpResponse.json(memberPortalError(500, "Reply not recorded."), {
					status: 500,
				}),
			),
		)
		await renderPanel()

		await userEvent.click(await screen.findByRole("button", { name: "Decline" }))

		expect(await screen.findByRole("alert")).toHaveTextContent(
			"Reply not recorded.",
		)
		expect(screen.getByText("You're invited")).toBeInTheDocument()
		// The buttons come back — declining is over, the person can try again.
		expect(screen.getByRole("button", { name: "Decline" })).toBeEnabled()
	})
})
