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

	/*
	 * View event leaves the portal for garp.org in a new tab, so it carries the
	 * new-tab glyph rather than the forward arrow every in-app CTA uses. The
	 * hero and the cards must not disagree about that — one link, one icon.
	 */
	test("View event opens garp.org in a new tab, with the new-tab glyph", async ({
		page,
	}) => {
		await installMockOrg(page, {
			actions: baseActions({
				...eventsListData(),
				upcomingOtherEvents: [
					memberEvent({
						eventId: "W-URL",
						eventType: "Webcast",
						eventName: "Model Risk Briefing",
						eventStartDate: "2026-12-05",
						eventURL: "https://www.garp.org/events/model-risk",
					}),
				],
			}),
		})
		await page.goto("/events")

		const card = page.getByRole("link", { name: "View event", exact: true })
		await expect(card).toHaveAttribute(
			"href",
			"https://www.garp.org/events/model-risk",
		)
		await expect(card).toHaveAttribute("target", "_blank")
		await expect(card).toHaveAttribute("rel", /noopener/)
		// The glyph itself: an icon rides with the label, not a bare text link.
		await expect(card.locator("svg")).toBeVisible()
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
