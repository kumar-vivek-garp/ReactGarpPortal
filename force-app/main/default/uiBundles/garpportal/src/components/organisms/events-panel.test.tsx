import { screen, waitFor, within } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { http, HttpResponse } from "msw"
import { describe, expect, it } from "vitest"

import type { MemberEvent } from "@/api/events"
import { EventsPanel } from "@/components/organisms/events-panel"
import type { EventTypeFilter } from "@/config/events"
import { memberPortalEnvelope } from "@/testing/factories/envelope"
import { server } from "@/testing/msw/server"
import { renderWithRouterProviders } from "@/testing/router"

const EVENTS_PATH = "/services/apexrest/memberportal/events"

function memberEvent(overrides: Partial<MemberEvent> = {}): MemberEvent {
	return {
		eventId: "e1",
		eventType: "Event",
		eventName: "Risk Convention",
		eventStartDate: "2099-05-12",
		eventSlug: null,
		eventURL: "https://www.garp.org/risk-convention",
		chapterId: null,
		canManageAttendance: false,
		addToCalTitle: null,
		addToCalDescription: null,
		addToCalStartDateTime: null,
		addToCalEndDateTime: null,
		addToCalTimeZone: null,
		addToCalLocation: null,
		...overrides,
	}
}

/** A registration with the full calendar payload, so the hero has everything. */
const richRegistration = () =>
	memberEvent({
		eventId: "reg-1",
		eventName: "Climate Risk Summit",
		eventStartDate: "2099-03-02",
		addToCalTitle: "Climate Risk Summit",
		addToCalDescription: "<p>Two days of climate risk.</p>",
		// Apex ships `yyyy-MM-dd h:mm a`, not ISO — the calendar parser is strict.
		addToCalStartDateTime: "2099-03-02 9:00 AM",
		addToCalEndDateTime: "2099-03-02 5:00 PM",
		addToCalTimeZone: "America/New_York",
		addToCalLocation: "New York Hilton",
	})

function serveEvents(overrides: Partial<Record<string, MemberEvent[]>> = {}) {
	server.use(
		http.get(EVENTS_PATH, () =>
			HttpResponse.json(
				memberPortalEnvelope({
					statusCode: 200,
					statusMessage: null,
					registeredEvents: [],
					upcomingChapterMeetings: [],
					upcomingOtherEvents: [],
					...overrides,
				}),
			),
		),
	)
}

async function renderPanel(type?: EventTypeFilter, entry = "/events") {
	return renderWithRouterProviders(<EventsPanel type={type} />, {
		path: "/events",
		initialEntries: [entry],
	})
}

describe("EventsPanel — the Up Next hero", () => {
	it("elevates the soonest registration with its full calendar details", async () => {
		serveEvents({
			registeredEvents: [
				memberEvent({ eventId: "reg-later", eventStartDate: "2099-08-01" }),
				richRegistration(),
			],
		})
		await renderPanel()

		const hero = await screen.findByRole("region", { name: "Your next event" })
		expect(
			within(hero).getByRole("heading", { name: "Climate Risk Summit" }),
		).toBeInTheDocument()
		// HTML in the calendar description is stripped for the blurb.
		expect(
			within(hero).getByText("Two days of climate risk."),
		).toBeInTheDocument()
		expect(within(hero).getByText("New York Hilton")).toBeInTheDocument()
		// The date badge and its weekday come from the start date.
		expect(within(hero).getByText("Mar")).toBeInTheDocument()
		expect(within(hero).getByText("2")).toBeInTheDocument()
		expect(
			within(hero).getByRole("button", { name: /Add to Calendar/i }),
		).toBeInTheDocument()
		// The other registration flows into the grid below.
		expect(screen.getByText("Also happening")).toBeInTheDocument()
		expect(screen.getByText("Risk Convention")).toBeInTheDocument()
	})

	it("a bare registration renders the hero without blurb or calendar button", async () => {
		serveEvents({ registeredEvents: [memberEvent()] })
		await renderPanel()

		const hero = await screen.findByRole("region", { name: "Your next event" })
		expect(
			within(hero).queryByRole("button", { name: /Add to calendar/i }),
		).not.toBeInTheDocument()
		// Nothing else booked: the grid section does not render at all.
		expect(screen.queryByText("Also happening")).not.toBeInTheDocument()
		expect(screen.queryByText("Upcoming events")).not.toBeInTheDocument()
	})

	it("with no registrations the grid is headed Upcoming events instead", async () => {
		serveEvents({
			upcomingOtherEvents: [memberEvent({ eventId: "e2" })],
		})
		await renderPanel()

		expect(await screen.findByText("Upcoming events")).toBeInTheDocument()
		expect(
			screen.queryByRole("region", { name: "Your next event" }),
		).not.toBeInTheDocument()
	})
})

describe("EventsPanel — the type filter", () => {
	const mixedBag = () => ({
		registeredEvents: [richRegistration()],
		upcomingChapterMeetings: [
			memberEvent({
				eventId: "cm-1",
				eventType: "Chapter Meeting",
				eventName: "NY Chapter Meeting",
			}),
		],
		upcomingOtherEvents: [
			memberEvent({ eventId: "e2" }),
			memberEvent({
				eventId: "w-1",
				eventType: "Webcast",
				eventName: "Basel IV Webcast",
			}),
		],
	})

	it("counts each type in the dropdown and writes the pick into ?type=", async () => {
		const user = userEvent.setup()
		serveEvents(mixedBag())
		const { router } = await renderPanel()
		await screen.findByText("Also happening")

		await user.click(
			screen.getByRole("combobox", { name: "Filter events by type" }),
		)
		expect(
			await screen.findByRole("option", { name: /All types \(3\)/ }),
		).toBeInTheDocument()
		await user.click(screen.getByRole("option", { name: /Webcasts \(1\)/ }))

		await waitFor(() => {
			expect(router.state.location.search).toMatchObject({ type: "webcast" })
		})
	})

	it("scopes the grid to the filtered type", async () => {
		serveEvents(mixedBag())
		await renderPanel("webcast")

		expect(await screen.findByText("Basel IV Webcast")).toBeInTheDocument()
		expect(screen.queryByText("NY Chapter Meeting")).not.toBeInTheDocument()
		expect(screen.queryByText("Risk Convention")).not.toBeInTheDocument()
	})

	it("an empty filtered grid names the type and clears back to all", async () => {
		const user = userEvent.setup()
		serveEvents({
			registeredEvents: [richRegistration()],
			upcomingOtherEvents: [memberEvent({ eventId: "e2" })],
		})
		const { router } = await renderPanel(
			"chapter",
			"/events?type=chapter",
		)

		expect(
			await screen.findByText("No chapter meetings here"),
		).toBeInTheDocument()

		await user.click(screen.getByRole("button", { name: "Show all types" }))
		await waitFor(() => {
			expect(router.state.location.search).not.toMatchObject({
				type: "chapter",
			})
		})
	})
})
