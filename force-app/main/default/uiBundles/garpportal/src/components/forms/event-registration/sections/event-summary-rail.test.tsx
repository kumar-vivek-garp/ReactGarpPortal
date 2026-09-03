import { screen } from "@testing-library/react"
import { describe, expect, it } from "vitest"

import { EventSummaryRail } from "@/components/forms/event-registration/sections/event-summary-rail"
import { eventRates, eventView } from "@/testing/factories/event"
import { renderWithProviders } from "@/testing/render"

describe("the money", () => {
	it("prices a paid event and repeats the total", () => {
		renderWithProviders(
			<EventSummaryRail
				event={eventView()}
				rates={eventRates({ amountDue: 250 })}
			/>,
		)
		expect(screen.getAllByText("$250.00")).toHaveLength(2)
		expect(screen.queryByText("Free")).not.toBeInTheDocument()
	})

	it("reads Free for a zero amount and with no rates at all", () => {
		const { rerender } = renderWithProviders(
			<EventSummaryRail event={eventView()} rates={eventRates()} />,
		)
		expect(screen.getAllByText("Free")).toHaveLength(2)

		rerender(<EventSummaryRail event={eventView()} rates={null} />)
		expect(screen.getAllByText("Free")).toHaveLength(2)
	})

	it("shows the payment policy only when money is due", () => {
		const event = eventView({
			cancellationPolicy: "No refunds after 1 March.",
			paymentPolicy: "Payment is due at registration.",
		})

		const { rerender } = renderWithProviders(
			<EventSummaryRail event={event} rates={eventRates()} />,
		)
		// Cancellation applies either way; payment policy is meaningless when free.
		expect(screen.getByText("No refunds after 1 March.")).toBeInTheDocument()
		expect(
			screen.queryByText("Payment is due at registration."),
		).not.toBeInTheDocument()

		rerender(
			<EventSummaryRail event={event} rates={eventRates({ amountDue: 99 })} />,
		)
		expect(screen.getByText("Payment is due at registration.")).toBeInTheDocument()
	})
})

describe("the event facts", () => {
	it("joins venue and location into one where-line", () => {
		renderWithProviders(
			<EventSummaryRail
				event={eventView({ venue: "Hilton Midtown", location: "New York" })}
				rates={null}
			/>,
		)
		expect(screen.getByText("Hilton Midtown · New York")).toBeInTheDocument()
	})

	it("uses whichever half of the where-line exists", () => {
		renderWithProviders(
			<EventSummaryRail event={eventView({ location: "New York" })} rates={null} />,
		)
		expect(screen.getByText("New York")).toBeInTheDocument()
	})

	it("renders the rich-text description as plain text", () => {
		renderWithProviders(
			<EventSummaryRail
				event={eventView({
					description: "<p>Keynote &amp; panel</p><p>Doors at 6</p>",
				})}
				rates={null}
			/>,
		)
		const text = screen.getByText((content) =>
			content.includes("Keynote & panel"),
		)
		expect(text.textContent).toContain("Doors at 6")
		// The markup itself must never surface.
		expect(text.textContent).not.toContain("<p>")
	})

	it("shows the delivery mode and date only when known", () => {
		renderWithProviders(
			<EventSummaryRail
				event={eventView({
					deliveryMode: "  Virtual  ",
					startDate: "2026-03-12T18:00:00Z",
					timeZone: "America/New_York",
				})}
				rates={null}
			/>,
		)
		expect(screen.getByText("Virtual")).toBeInTheDocument()
		expect(screen.getByText(/March 12, 2026/)).toBeInTheDocument()
	})
})
