import { screen } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { afterEach, describe, expect, it, vi } from "vitest"

import type { MemberEvent } from "@/api/events"
import { AddToCalendarButton } from "@/components/molecules/add-to-calendar-button"
import { renderWithProviders } from "@/testing/render"

function memberEvent(overrides: Partial<MemberEvent> = {}): MemberEvent {
	return {
		eventId: "evt-1",
		eventType: "Event",
		eventName: "Risk Summit 2026",
		eventStartDate: "2026-03-12",
		eventSlug: null,
		eventURL: null,
		chapterId: null,
		canManageAttendance: false,
		addToCalTitle: "GARP Risk Summit",
		addToCalDescription: "<p>Keynote &amp; panel</p>",
		addToCalStartDateTime: "2026-03-12 6:00 PM",
		addToCalEndDateTime: "2026-03-12 9:00 PM",
		addToCalTimeZone: "America/New_York",
		addToCalLocation: "New York",
		...overrides,
	}
}

afterEach(() => {
	vi.restoreAllMocks()
})

async function openMenu() {
	const user = userEvent.setup()
	renderWithProviders(<AddToCalendarButton event={memberEvent()} />)
	await user.click(screen.getByRole("button", { name: /Add to Calendar/ }))
	return user
}

describe("without calendar data", () => {
	it("renders nothing at all", () => {
		const { container } = renderWithProviders(
			<AddToCalendarButton
				event={memberEvent({ addToCalStartDateTime: null })}
			/>,
		)
		expect(container).toBeEmptyDOMElement()
	})
})

describe("the provider menu", () => {
	it("offers all four providers", async () => {
		await openMenu()
		for (const label of [
			"Google Calendar",
			"Apple Calendar",
			"Microsoft 365 / Outlook",
			"Download .ics",
		]) {
			expect(screen.getByRole("menuitem", { name: label })).toBeInTheDocument()
		}
	})

	it("opens Google Calendar with the event's own details", async () => {
		const open = vi.spyOn(window, "open").mockReturnValue(null)
		const user = await openMenu()

		await user.click(screen.getByRole("menuitem", { name: "Google Calendar" }))

		expect(open).toHaveBeenCalledTimes(1)
		const url = new URL(open.mock.calls[0][0] as string)
		expect(url.hostname).toBe("calendar.google.com")
		expect(url.searchParams.get("action")).toBe("TEMPLATE")
		expect(url.searchParams.get("text")).toBe("GARP Risk Summit")
		expect(url.searchParams.get("details")).toBe("Keynote & panel")
		expect(url.searchParams.get("location")).toBe("New York")
		expect(url.searchParams.get("ctz")).toBe("America/New_York")
		// 6pm New York on 12 March 2026 is 22:00 UTC.
		expect(url.searchParams.get("dates")).toBe("20260312T220000Z/20260313T010000Z")
		expect(open.mock.calls[0][2]).toBe("noopener,noreferrer")
	})

	it("opens a Microsoft 365 compose deeplink", async () => {
		const open = vi.spyOn(window, "open").mockReturnValue(null)
		const user = await openMenu()

		await user.click(
			screen.getByRole("menuitem", { name: "Microsoft 365 / Outlook" }),
		)

		const url = new URL(open.mock.calls[0][0] as string)
		expect(url.hostname).toBe("outlook.office.com")
		expect(url.searchParams.get("subject")).toBe("GARP Risk Summit")
		expect(url.searchParams.get("startdt")).toBe("2026-03-12T22:00:00.000Z")
	})

	it("downloads a well-formed .ics for Apple and the plain download", async () => {
		let blob: Blob | undefined
		vi.stubGlobal(
			"URL",
			class extends URL {
				static createObjectURL = vi.fn((value: Blob) => {
					blob = value
					return "blob:mock"
				})
				static revokeObjectURL = vi.fn()
			},
		)
		const anchorClick = vi
			.spyOn(HTMLAnchorElement.prototype, "click")
			.mockImplementation(() => undefined)

		const user = await openMenu()
		await user.click(screen.getByRole("menuitem", { name: "Download .ics" }))

		expect(anchorClick).toHaveBeenCalledTimes(1)
		// jsdom's Blob has no .text(); FileReader is the portable read.
		const ics = await new Promise<string>((resolve, reject) => {
			const reader = new FileReader()
			reader.onload = () => resolve(String(reader.result))
			reader.onerror = () => reject(reader.error)
			reader.readAsText(blob!)
		})
		expect(ics).toContain("BEGIN:VCALENDAR")
		expect(ics).toContain("SUMMARY:GARP Risk Summit")
		expect(ics).toContain("DTSTART:20260312T220000Z")
		expect(ics).toContain("DTEND:20260313T010000Z")
		expect(ics).toContain("LOCATION:New York")
		vi.unstubAllGlobals()
	})
})
