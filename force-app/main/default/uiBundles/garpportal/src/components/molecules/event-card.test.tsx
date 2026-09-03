import { screen } from "@testing-library/react"
import { describe, expect, it } from "vitest"

import type { MemberEvent } from "@/api/events"
import { EventCard } from "@/components/molecules/event-card"
import { renderWithRouterProviders } from "@/testing/router"

function memberEvent(overrides: Partial<MemberEvent> = {}): MemberEvent {
	return {
		eventId: "evt-1",
		eventType: "Webcast",
		eventName: "Climate Risk Outlook",
		eventStartDate: "2026-03-12",
		eventSlug: "climate-risk-outlook",
		eventURL: "https://www.garp.org/webcast/climate",
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

describe("what the card offers", () => {
	it("badges the date, links the event page, and offers Register when not attending", async () => {
		await renderWithRouterProviders(<EventCard event={memberEvent()} />)

		expect(screen.getByText("Mar")).toBeInTheDocument()
		expect(screen.getByText("12")).toBeInTheDocument()
		expect(screen.getByText("Climate Risk Outlook")).toBeInTheDocument()
		expect(screen.getByRole("link", { name: "View event" })).toHaveAttribute(
			"href",
			"https://www.garp.org/webcast/climate",
		)
		expect(screen.getByRole("link", { name: "Register" })).toBeInTheDocument()
		expect(screen.queryByText("Attending")).not.toBeInTheDocument()
	})

	it("marks an attending event and withdraws the Register CTA", async () => {
		await renderWithRouterProviders(
			<EventCard event={memberEvent()} isAttending />,
		)
		expect(screen.getByText("Attending")).toBeInTheDocument()
		expect(
			screen.queryByRole("link", { name: "Register" }),
		).not.toBeInTheDocument()
	})

	it("offers Manage Attendance only when granted", async () => {
		const { unmount } = await renderWithRouterProviders(
			<EventCard event={memberEvent({ canManageAttendance: true })} />,
		)
		expect(
			screen.getByRole("link", { name: "Manage Attendance" }),
		).toBeInTheDocument()
		unmount()

		await renderWithRouterProviders(<EventCard event={memberEvent()} />)
		expect(
			screen.queryByRole("link", { name: "Manage Attendance" }),
		).not.toBeInTheDocument()
	})

	it("falls back to the kind glyph and a promise when details are missing", async () => {
		await renderWithRouterProviders(
			<EventCard
				event={memberEvent({
					eventStartDate: null,
					eventURL: null,
					eventSlug: null,
				})}
			/>,
		)
		expect(screen.queryByText("Mar")).not.toBeInTheDocument()
		expect(
			screen.getByText("Details will be available closer to the date."),
		).toBeInTheDocument()
	})

	it("adds the calendar button only when the event carries calendar data", async () => {
		await renderWithRouterProviders(
			<EventCard
				event={memberEvent({
					addToCalStartDateTime: "2026-03-12 6:00 PM",
					addToCalTimeZone: "America/New_York",
				})}
			/>,
		)
		expect(
			screen.getByRole("button", { name: /Add to Calendar/ }),
		).toBeInTheDocument()
	})
})
