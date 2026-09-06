import { expect, test, type Route } from "@playwright/test"

import type { AlertBarView } from "@/api/alert-bar"
import type { CpdActivity } from "@/api/cpd"
import { cpdActivity, cpdActivityView } from "@/testing/factories/cpd"
import { memberPortalEnvelope } from "@/testing/factories/envelope"
import { installMockOrg } from "../support/mock-org"
import { dashboardActionSet } from "../support/payloads"

/**
 * Browse Credit Opportunities (/cpd/activities): the server-paged catalogue
 * renders, facet toggles travel as query params (and reset paging), Next
 * keeps the previous page on screen while the next loads (placeholderData),
 * and `?activityId=` collapses to a single-activity GET with every other
 * param dropped — Apex ignores them all when an id is present.
 */

const NO_ALERT = {
	statusMessage: null,
	statusCode: 200,
	examType: null,
	examPart: null,
	alertStatus: null,
	deadline: null,
	orderId: null,
	route: null,
} satisfies AlertBarView

const TOTAL = 45
const PAGE_SIZE = 20

function activityRow(n: number): CpdActivity {
	return cpdActivity({
		id: `act-${n}`,
		title: `Activity ${String(n).padStart(2, "0")}`,
	})
}

/** Rows for one 1-based server page: 1–20, 21–40, 41–45. */
function pageRows(pageCurrent: number): CpdActivity[] {
	const from = (pageCurrent - 1) * PAGE_SIZE + 1
	const to = Math.min(pageCurrent * PAGE_SIZE, TOTAL)
	return Array.from({ length: Math.max(0, to - from + 1) }, (_, index) =>
		activityRow(from + index),
	)
}

function catalogueView(rows: CpdActivity[], totalCount = TOTAL) {
	return cpdActivityView({ cpdActivities: rows, totalCount })
}

/**
 * A server that reads the query string the way Apex does: an `activityId`
 * overrides everything, otherwise `pageCurrent` picks the slice. `gate`
 * holds the given page's response until the test releases it.
 */
function catalogueResponder(options: { gatePage?: number; gate?: Promise<void> } = {}) {
	return async (route: Route) => {
		const params = new URL(route.request().url()).searchParams
		const singleId = params.get("activityId")
		if (singleId) {
			const rows =
				singleId === "act-7"
					? [cpdActivity({ id: "act-7", title: "Scoped Activity" })]
					: []
			await route.fulfill({
				json: memberPortalEnvelope(catalogueView(rows, rows.length)),
			})
			return
		}
		const pageCurrent = Number(params.get("pageCurrent") ?? "1")
		if (options.gatePage === pageCurrent && options.gate) await options.gate
		await route.fulfill({
			json: memberPortalEnvelope(catalogueView(pageRows(pageCurrent))),
		})
	}
}

function activitiesActions(
	responder = catalogueResponder(),
): Record<string, unknown> {
	return {
		...dashboardActionSet(),
		alertBar: NO_ALERT,
		cpdActivities: responder,
	}
}

test.describe("browse credit opportunities", () => {
	test("the catalogue renders a page of rows with facets, sort and count", async ({
		page,
	}) => {
		const org = await installMockOrg(page, { actions: activitiesActions() })
		await page.goto("/cpd/activities")

		await expect(
			page.getByRole("heading", { name: "Browse CPD Activities", level: 1 }),
		).toBeVisible()
		await expect(page.getByText("Activity 01")).toBeVisible()
		await expect(page.getByText("Showing 1–20 of 45")).toBeVisible()
		await expect(page.getByRole("checkbox", { name: "Webinar" })).toBeVisible()
		await expect(
			page.getByRole("combobox", { name: "Sort activities" }),
		).toContainText("Date most recent to oldest")

		// The first GET carries the defaults and no facet params at all.
		const params = new URL(org.of("cpdActivities")[0].url).searchParams
		expect(params.get("sortOrder")).toBe("Date most recent to oldest")
		expect(params.get("pageSize")).toBe("20")
		expect(params.get("pageCurrent")).toBe("1")
		expect(params.get("activityTypes")).toBeNull()
		expect(params.get("activityId")).toBeNull()

		// Audit surface: every memberportal action answered by a typed payload.
		expect(
			org.unhandled
				.filter((call) => call.kind === "action")
				.map((call) => call.key),
		).toEqual([])
	})

	test("toggling facets re-queries with the facet params and resets to page 1", async ({
		page,
	}) => {
		const org = await installMockOrg(page, { actions: activitiesActions() })
		await page.goto("/cpd/activities?page=2")
		await expect(page.getByText("Activity 21")).toBeVisible()

		await page.getByRole("checkbox", { name: "Webinar" }).click()
		await expect.poll(() => org.hits("cpdActivities")).toBe(2)

		// The facet travels, and page 2 of the old result set is dropped.
		let params = new URL(org.of("cpdActivities")[1].url).searchParams
		expect(params.get("activityTypes")).toBe("Webinar")
		expect(params.get("pageCurrent")).toBe("1")
		// The router serializes array params as JSON: ?type=["Webinar"], encoded.
		expect(decodeURIComponent(page.url())).toContain('type=["Webinar"]')
		expect(page.url()).not.toContain("page=2")

		// A second value joins Apex's ";" wire format inside ONE param.
		await page.getByRole("checkbox", { name: "Reading" }).click()
		await expect.poll(() => org.hits("cpdActivities")).toBe(3)
		params = new URL(org.of("cpdActivities")[2].url).searchParams
		expect(params.get("activityTypes")).toBe("Webinar;Reading")
	})

	test("Next holds the previous rows on screen while page 2 loads", async ({
		page,
	}) => {
		let release!: () => void
		const gate = new Promise<void>((resolve) => {
			release = resolve
		})
		const org = await installMockOrg(page, {
			actions: activitiesActions(catalogueResponder({ gatePage: 2, gate })),
		})
		await page.goto("/cpd/activities")
		await expect(page.getByText("Activity 01")).toBeVisible()

		const next = page.getByRole("button", { name: "Next" })
		await next.click()

		// Page 2 is gated: the URL has moved but the previous rows are held
		// (placeholderData) and the paginator is busy rather than blanking.
		await expect(page).toHaveURL(/page=2/)
		await expect(page.getByText("Activity 01")).toBeVisible()
		await expect(next).toBeDisabled()

		release()
		await expect(page.getByText("Activity 21")).toBeVisible()
		await expect(page.getByText("Activity 01")).toBeHidden()
		await expect(page.getByText("Showing 21–40 of 45")).toBeVisible()

		const calls = org.of("cpdActivities")
		const params = new URL(calls[calls.length - 1].url).searchParams
		expect(params.get("pageCurrent")).toBe("2")
	})

	test("?activityId= collapses to the single-activity view and drops every other param", async ({
		page,
	}) => {
		const org = await installMockOrg(page, { actions: activitiesActions() })
		// `type` must arrive in the router's own array-as-JSON serialization —
		// a bare ?type=Webinar fails the zod array parse and is dropped.
		await page.goto(
			`/cpd/activities?activityId=act-7&type=${encodeURIComponent('["Webinar"]')}&page=3`,
		)

		await expect(page.getByText("Scoped Activity")).toBeVisible()
		await expect(
			page.getByRole("button", { name: "View all activities" }),
		).toBeVisible()

		// Scoped: no sort card, no facet sidebar, no self-linking permalink.
		await expect(page.getByText("Sort by")).toBeHidden()
		await expect(page.getByRole("checkbox", { name: "Webinar" })).toBeHidden()
		await expect(page.getByRole("link", { name: "Open" })).toBeHidden()

		// One GET, carrying the id and NOTHING else — Apex ignores the rest.
		expect(org.hits("cpdActivities")).toBe(1)
		const params = new URL(org.of("cpdActivities")[0].url).searchParams
		expect(params.get("activityId")).toBe("act-7")
		for (const key of [
			"activityTypes",
			"areasOfStudy",
			"providers",
			"sortOrder",
			"pageSize",
			"pageCurrent",
		]) {
			expect(params.get(key)).toBeNull()
		}

		// Dropping the scope restores the full query — the URL's other params
		// (type=Webinar, page=3) come back into play on the next GET.
		await page.getByRole("button", { name: "View all activities" }).click()
		await expect(page.getByText("Activity 41")).toBeVisible()
		await expect(page).not.toHaveURL(/activityId/)
		const listParams = new URL(
			org.of("cpdActivities")[1].url,
		).searchParams
		expect(listParams.get("activityTypes")).toBe("Webinar")
		expect(listParams.get("pageCurrent")).toBe("3")
	})
})
