import { screen, waitFor } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { http, HttpResponse } from "msw"
import { describe, expect, it } from "vitest"

import type { CpdActivitiesSearch } from "@/config/cpd"
import { CpdActivitiesPanel } from "@/components/organisms/cpd-activities-panel"
import { cpdActivity, cpdActivityView } from "@/testing/factories/cpd"
import { memberPortalError } from "@/testing/factories/envelope"
import {
	CPD_ACTIVITIES_PATH,
	cpdActivitiesOrg,
} from "@/testing/msw/handlers/cpd"
import { server } from "@/testing/msw/server"
import { renderWithRouterProviders } from "@/testing/router"

async function renderPanel(
	search: CpdActivitiesSearch = {},
	org: ReturnType<typeof cpdActivitiesOrg> = cpdActivitiesOrg(),
) {
	server.use(...org.handlers)
	const rendered = await renderWithRouterProviders(
		<CpdActivitiesPanel {...search} />,
		{ path: "/cpd/activities" },
	)
	return { ...rendered, spy: org.spy }
}

const card = (name: string | RegExp) => screen.findByRole("heading", { name })

describe("loading the catalogue", () => {
	it("shows the rows once they land, with filters and no scoped back-link", async () => {
		await renderPanel()

		expect(await card("Climate Risk Webinar")).toBeInTheDocument()
		expect(
			screen.getByRole("combobox", { name: "Sort activities" }),
		).toBeInTheDocument()
		expect(
			screen.queryByRole("button", { name: /View all activities/ }),
		).not.toBeInTheDocument()
	})

	it("sends only the paging defaults, never a stray activity id", async () => {
		const { spy } = await renderPanel()

		await card("Climate Risk Webinar")
		expect(spy.hits).toBe(1)
		expect(spy.params[0].get("activityId")).toBeNull()
		expect(spy.params[0].get("pageSize")).toBe("20")
		expect(spy.params[0].get("pageCurrent")).toBe("1")
		expect(spy.params[0].get("sortOrder")).toBe("Date most recent to oldest")
	})

	it("admits failure in words when the service refuses", async () => {
		server.use(...cpdActivitiesOrg().handlers)
		server.use(
			http.get(CPD_ACTIVITIES_PATH, () =>
				HttpResponse.json(memberPortalError(500, "boom"), { status: 500 }),
			),
		)
		await renderWithRouterProviders(<CpdActivitiesPanel />, {
			path: "/cpd/activities",
		})

		expect(
			await screen.findByText(/couldn.t load credit opportunities/),
		).toBeInTheDocument()
	})

	it("shows the zero state for an empty, unscoped result", async () => {
		await renderPanel(
			{},
			cpdActivitiesOrg({
				respond: () => cpdActivityView({ cpdActivities: [], totalCount: 0 }),
			}),
		)

		expect(
			await screen.findByText(/no credit opportunities|no activities/i),
		).toBeInTheDocument()
	})
})

describe("a shared link to one activity", () => {
	it("sends the id as the whole query and hides filters and paging", async () => {
		const { spy } = await renderPanel(
			{ activityId: "act-9" },
			cpdActivitiesOrg({
				respond: () =>
					cpdActivityView({
						cpdActivities: [cpdActivity({ id: "act-9", title: "Scoped Row" })],
						totalCount: 1,
					}),
			}),
		)

		expect(await card("Scoped Row")).toBeInTheDocument()
		expect(spy.params[0].get("activityId")).toBe("act-9")
		expect([...spy.params[0].keys()]).toEqual(["activityId"])
		expect(
			screen.queryByRole("combobox", { name: "Sort activities" }),
		).not.toBeInTheDocument()
		expect(
			screen.queryByRole("navigation", { name: "Credit opportunities pages" }),
		).not.toBeInTheDocument()
		// The scoped row must not link to itself.
		expect(screen.queryByRole("link", { name: /Open/ })).not.toBeInTheDocument()
	})

	it("treats an id that matches nothing as a state, not an error", async () => {
		const user = userEvent.setup()
		const { router } = await renderPanel(
			{ activityId: "act-stale" },
			cpdActivitiesOrg({
				respond: () => cpdActivityView({ cpdActivities: [], totalCount: 0 }),
			}),
		)

		expect(
			await screen.findByText("This activity is no longer listed"),
		).toBeInTheDocument()

		// Browsing all drops the scope AND the stale address.
		await user.click(
			screen.getByRole("button", { name: "Browse all activities" }),
		)
		await waitFor(() => {
			expect(
				(router.state.location.search as CpdActivitiesSearch).activityId,
			).toBeUndefined()
		})
	})

	it("keeps the View-all escape hatch above scoped results too", async () => {
		const user = userEvent.setup()
		const { router } = await renderPanel(
			{ activityId: "act-9" },
			cpdActivitiesOrg({
				respond: () =>
					cpdActivityView({
						cpdActivities: [cpdActivity({ id: "act-9", title: "Scoped Row" })],
						totalCount: 1,
					}),
			}),
		)

		await card("Scoped Row")
		await user.click(
			screen.getByRole("button", { name: /View all activities/ }),
		)
		await waitFor(() => {
			expect(
				(router.state.location.search as CpdActivitiesSearch).activityId,
			).toBeUndefined()
		})
	})
})
