import { screen } from "@testing-library/react"
import { delay, http, HttpResponse } from "msw"
import { describe, expect, it } from "vitest"

import type { CurrentUser } from "@/api/auth/current-user"
import { EventRegistrationPanel } from "@/components/forms/event-registration/event-registration-panel"
import { memberPortalEnvelope, memberPortalError } from "@/testing/factories/envelope"
import { eventEligibility, eventLoad, eventView } from "@/testing/factories/event"
import { examregGet } from "@/testing/msw/handlers/examreg"
import { server } from "@/testing/msw/server"
import { renderWithRouterProviders } from "@/testing/router"

const INFO_PATH = "/services/apexrest/examreg/event/info"

/** contactId null on purpose — the profile query must stay off the wire. */
const MEMBER: CurrentUser = {
	id: "005-member",
	name: "Ada Lovelace",
	garpId: "G-1",
	contactId: null,
	photoUrl: null,
}

function renderPanel({
	user = null,
	variant = "event" as const,
}: { user?: CurrentUser | null; variant?: "event" | "webcast" } = {}) {
	return renderWithRouterProviders(
		<EventRegistrationPanel
			variant={variant}
			eventId="evt-1"
			paymentReturn={null}
			checkoutCancelled={null}
		/>,
		{ user },
	)
}

describe("EventRegistrationPanel — screen dispatch", () => {
	it("shows the skeleton while the load is pending, even for a guest", async () => {
		server.use(
			http.get(INFO_PATH, async () => {
				await delay("infinite")
				return HttpResponse.json(memberPortalEnvelope(eventLoad()))
			}),
		)
		await renderPanel()

		expect(screen.getByLabelText("Loading")).toBeInTheDocument()
		expect(screen.queryByRole("heading")).not.toBeInTheDocument()
	})

	it("shows the error screen when the load itself fails", async () => {
		server.use(
			http.get(INFO_PATH, () =>
				HttpResponse.json(memberPortalError(500, "Boom"), { status: 500 }),
			),
		)
		await renderPanel()

		expect(
			await screen.findByRole("heading", {
				name: "We couldn't open this registration",
			}),
		).toBeInTheDocument()
	})

	it("shows not-found for an unknown event id, with the server's own message and the variant's title", async () => {
		server.use(
			examregGet("event/info", () =>
				eventLoad({
					event_x: null,
					eligibility: eventEligibility({
						message: "This event has been removed.",
					}),
				}),
			).handler,
		)
		await renderPanel({ variant: "webcast" })

		expect(
			await screen.findByRole("heading", { name: "We couldn't find that event" }),
		).toBeInTheDocument()
		expect(screen.getByText("This event has been removed.")).toBeInTheDocument()
		// No event title to show — the h1 falls back to the variant's own.
		expect(
			screen.getByRole("heading", { level: 1, name: "Webcast Registration" }),
		).toBeInTheDocument()
	})

	it("shows already-registered ahead of the form", async () => {
		server.use(
			examregGet("event/info", () =>
				eventLoad({ alreadyRegistered: true }),
			).handler,
		)
		await renderPanel({ user: MEMBER })

		expect(
			await screen.findByRole("heading", { name: "You're already registered" }),
		).toBeInTheDocument()
		expect(
			screen.queryByRole("button", { name: /complete registration/i }),
		).not.toBeInTheDocument()
	})

	it("offers a guest Sign In on a refusal that signing in would fix", async () => {
		server.use(
			examregGet("event/info", () =>
				eventLoad({
					eligibility: eventEligibility({
						isEligible: false,
						message: "This event is for GARP members.",
						signInWouldHelp: true,
					}),
				}),
			).handler,
		)
		await renderPanel()

		expect(
			await screen.findByRole("heading", { name: "Registration isn't available" }),
		).toBeInTheDocument()
		expect(
			screen.getByText("This event is for GARP members."),
		).toBeInTheDocument()
		expect(screen.getByRole("link", { name: "Sign In" })).toBeInTheDocument()
	})

	it("never offers Sign In to someone already signed in — but keeps the back link", async () => {
		server.use(
			examregGet("event/info", () =>
				eventLoad({
					eligibility: eventEligibility({
						isEligible: false,
						signInWouldHelp: true,
					}),
				}),
			).handler,
		)
		await renderPanel({ user: MEMBER })

		await screen.findByRole("heading", { name: "Registration isn't available" })
		expect(
			screen.queryByRole("link", { name: "Sign In" }),
		).not.toBeInTheDocument()
		expect(screen.getByRole("link", { name: "Events" })).toBeInTheDocument()
	})

	it("renders the form for an eligible guest — event title as the h1, submit disabled on the empty form", async () => {
		server.use(
			examregGet("event/info", () =>
				eventLoad({ event_x: eventView({ title: "Risk Summit 2026" }) }),
			).handler,
		)
		await renderPanel()

		expect(
			await screen.findByRole("heading", { level: 1, name: "Risk Summit 2026" }),
		).toBeInTheDocument()
		expect(screen.getByText("Your details")).toBeInTheDocument()
		expect(
			screen.getByRole("button", { name: "Complete Registration" }),
		).toBeDisabled()
		// A guest gets no back link — every in-app parent is behind the guard.
		expect(screen.queryByRole("link", { name: "Events" })).not.toBeInTheDocument()
	})

	it("shows the org's rich-text copy as plain text — the activity details once rendered a literal <p>", async () => {
		server.use(
			examregGet("event/info", () =>
				eventLoad({
					event_x: eventView({
						rsvpActivityName: "Networking Dinner",
						rsvpActivityDetails: "<p>Drinks &amp; canapés</p>",
					}),
				}),
			).handler,
		)
		await renderPanel()

		expect(await screen.findByText("Drinks & canapés")).toBeInTheDocument()
		expect(screen.queryByText(/<p>/)).not.toBeInTheDocument()
	})
})
