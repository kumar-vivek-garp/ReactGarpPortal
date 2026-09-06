import { expect, test } from "@playwright/test"

import type { AlertBarView } from "@/api/alert-bar"
import type { EventsView, MemberEvent } from "@/api/events"
import { installMockOrg } from "../support/mock-org"
import { eventsListData, programsListData } from "../support/payloads"

/**
 * /events listing: the soonest registration renders as the "up next" hero
 * with everything else in one grid, and the type dropdown narrows the grid
 * while writing `?type=` to the URL.
 */

/** The no-alerts answer — keeps the alert bar quiet on every member page. */
function alertBarIdle(): AlertBarView {
	return {
		statusMessage: "No alerts found",
		statusCode: 200,
		examType: null,
		examPart: null,
		alertStatus: null,
		deadline: null,
		orderId: null,
		route: null,
	}
}

function baseActions(events: EventsView): Record<string, unknown> {
	// `programs` feeds the sidebar's CPD gate on every _appLayout page and
	// `alertBar` mounts once in the shell; the mock's `{}` default fails both.
	return { events, programs: programsListData(), alertBar: alertBarIdle() }
}

function memberEvent(
	overrides: Partial<MemberEvent> &
		Pick<MemberEvent, "eventId" | "eventType" | "eventName">,
): MemberEvent {
	return {
		eventStartDate: null,
		eventSlug: null,
		eventURL: null,
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

/**
 * One event of every kind in the grid: the shared payload's registered pair
 * (webcast hero + one plain event) plus a chapter meeting and another webcast,
 * all dated AFTER the hero so it keeps its slot.
 */
function eventsWithAllTypes(): EventsView {
	return {
		...eventsListData(),
		upcomingChapterMeetings: [
			memberEvent({
				eventId: "CM-1",
				eventType: "Chapter Meeting",
				eventName: "London Chapter Meetup",
				eventStartDate: "2026-11-20",
			}),
		],
		upcomingOtherEvents: [
			memberEvent({
				eventId: "W-9",
				eventType: "Webcast",
				eventName: "AI Risk Webcast",
				eventStartDate: "2026-12-05",
			}),
		],
	}
}

test.describe("events listing", () => {
	test("the hero and grid render from the events payload with no load-error toast", async ({
		page,
	}) => {
		const org = await installMockOrg(page, {
			actions: baseActions(eventsListData()),
		})
		await page.goto("/events")

		await expect(
			page.getByRole("heading", { name: "My Events", level: 1 }),
		).toBeVisible()

		// The soonest registered event carries the hero…
		await expect(page.getByText("Up next — you're attending")).toBeVisible()
		await expect(page.getByText("Climate Risk Outlook 2026")).toBeVisible()
		// …and the other registration flows into the dated grid below it.
		await expect(page.getByText("Also happening")).toBeVisible()
		await expect(page.getByText("GARP Annual Risk Convention")).toBeVisible()

		await expect(page.getByText(/unable to load/i)).toHaveCount(0)
		// Every memberportal action the page fired was answered by a typed
		// payload, not the permissive-but-wrong `{}` default.
		expect(
			org.unhandled
				.filter((call) => call.kind === "action")
				.map((call) => call.key),
		).toEqual([])
	})

	test("the type filter narrows the grid, writes ?type=, and clears back to all", async ({
		page,
	}) => {
		await installMockOrg(page, { actions: baseActions(eventsWithAllTypes()) })
		await page.goto("/events")

		// All three kinds up before any filtering.
		await expect(page.getByText("GARP Annual Risk Convention")).toBeVisible()
		await expect(page.getByText("London Chapter Meetup")).toBeVisible()
		await expect(page.getByText("AI Risk Webcast")).toBeVisible()

		const filter = page.getByRole("combobox", {
			name: "Filter events by type",
		})
		await filter.click()
		await page.getByRole("option", { name: /Webcasts/ }).click()

		// The filter is a URL fact, not component state.
		await expect(page).toHaveURL(/\/events\?type=webcast/)
		await expect(page.getByText("AI Risk Webcast")).toBeVisible()
		await expect(page.getByText("GARP Annual Risk Convention")).toBeHidden()
		await expect(page.getByText("London Chapter Meetup")).toBeHidden()
		// The hero is outside the grid and never follows the filter out.
		await expect(page.getByText("Climate Risk Outlook 2026")).toBeVisible()

		await filter.click()
		await page.getByRole("option", { name: /All types/ }).click()

		// "all" is the bar-only sentinel — it never appears in the URL.
		await expect(page).toHaveURL(/\/events$/)
		await expect(page.getByText("GARP Annual Risk Convention")).toBeVisible()
		await expect(page.getByText("London Chapter Meetup")).toBeVisible()
		await expect(page.getByText("AI Risk Webcast")).toBeVisible()
	})
})
