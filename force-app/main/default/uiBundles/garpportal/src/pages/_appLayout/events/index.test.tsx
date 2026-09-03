import { screen } from "@testing-library/react"
import { http, HttpResponse } from "msw"
import { describe, expect, it } from "vitest"

import {
	memberPortalEnvelope,
	memberPortalError,
} from "@/testing/factories/envelope"
import { renderFileRoute } from "@/testing/file-route"
import { server } from "@/testing/msw/server"

import { Route } from "./index"

const EVENTS_PATH = "/services/apexrest/memberportal/events"

function portalEvent(overrides: Record<string, unknown> = {}) {
	return {
		eventId: "e1",
		eventType: "Event",
		eventName: "Risk Convention",
		eventStartDate: "2099-05-12",
		eventURL: "https://garp.org/e1",
		eventSlug: null,
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

function serveEvents(overrides: Record<string, unknown> = {}) {
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

const mount = (entry = "/events") =>
	renderFileRoute(Route, {
		id: "/_appLayout/events/",
		path: "/events/",
		initialEntries: [entry],
	})

describe("/events page", () => {
	it("renders the heading and the registered event with data", async () => {
		serveEvents({ registeredEvents: [portalEvent()] })
		await mount()

		expect(
			screen.getByRole("heading", { level: 1, name: "My Events" }),
		).toBeInTheDocument()
		expect(await screen.findByText("Risk Convention")).toBeInTheDocument()
	})

	it("filters the grid by ?type= and offers the way back out", async () => {
		serveEvents({
			registeredEvents: [portalEvent()],
			upcomingOtherEvents: [
				portalEvent({ eventId: "e2", eventName: "Risk Forum" }),
			],
		})
		await mount("/events?type=webcast")

		expect(await screen.findByText("No webcasts here")).toBeInTheDocument()
		expect(
			screen.getByRole("button", { name: "Show all types" }),
		).toBeInTheDocument()
	})

	it("shows the empty state when there are no events at all", async () => {
		serveEvents()
		await mount()

		expect(
			await screen.findByText("No events to show"),
		).toBeInTheDocument()
	})

	it("shows the error state when the listing fails", async () => {
		server.use(
			http.get(EVENTS_PATH, () =>
				HttpResponse.json(memberPortalError(500, "boom"), { status: 500 }),
			),
		)
		await mount()

		expect(
			await screen.findByText("We couldn't load your events"),
		).toBeInTheDocument()
	})
})
