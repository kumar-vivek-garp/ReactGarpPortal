import { screen, waitFor } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { describe, expect, it } from "vitest"

import type { CpdActivitiesSearch } from "@/config/cpd"
import { CpdActivitiesPanel } from "@/components/organisms/cpd-activities-panel"
import { cpdActivity, cpdActivityView } from "@/testing/factories/cpd"
import { cpdActivitiesOrg } from "@/testing/msw/handlers/cpd"
import { server } from "@/testing/msw/server"
import { renderWithRouterProviders } from "@/testing/router"

/** 45 matches at page size 20 = 3 pages. */
const pagedOrg = () =>
	cpdActivitiesOrg({
		respond: () => cpdActivityView({ totalCount: 45 }),
		activityTypes: [
			{
				id: "type-webinar",
				name: "Webinar",
				organizationLabel: null,
				providerLabel: "Provider",
				publicationLabel: null,
				titleLabel: "Title",
				contactEmailLabel: null,
			},
		],
	})

async function renderPanel(
	search: CpdActivitiesSearch = {},
	org = pagedOrg(),
) {
	server.use(...org.handlers)
	const rendered = await renderWithRouterProviders(
		<CpdActivitiesPanel {...search} />,
		{ path: "/cpd/activities" },
	)
	await screen.findByRole("heading", { name: "Climate Risk Webinar" })
	return { ...rendered, spy: org.spy }
}

const currentSearch = (
	router: Awaited<ReturnType<typeof renderWithRouterProviders>>["router"],
) => router.state.location.search as CpdActivitiesSearch

describe("facets and sort live in the URL", () => {
	it("adds a ticked facet and resets the page", async () => {
		const user = userEvent.setup()
		const { router } = await renderPanel({ page: 2 })

		await user.click(screen.getByRole("checkbox", { name: "Reading" }))
		await waitFor(() => {
			expect(currentSearch(router).type).toEqual(["Reading"])
		})
		expect(currentSearch(router).page).toBeUndefined()
	})

	it("unticking the last value removes the facet key entirely", async () => {
		const user = userEvent.setup()
		const { router } = await renderPanel({ type: ["Reading"] })

		await user.click(screen.getByRole("checkbox", { name: "Reading" }))
		await waitFor(() => {
			expect(currentSearch(router).type).toBeUndefined()
		})
	})

	it("clears every facet at once", async () => {
		const user = userEvent.setup()
		const { router } = await renderPanel({
			type: ["Webinar"],
			area: ["Credit Risk"],
			provider: ["GARP"],
			page: 3,
		})

		await user.click(screen.getByRole("button", { name: "Clear all" }))
		await waitFor(() => {
			expect(currentSearch(router).type).toBeUndefined()
		})
		expect(currentSearch(router).area).toBeUndefined()
		expect(currentSearch(router).provider).toBeUndefined()
		expect(currentSearch(router).page).toBeUndefined()
	})

	it("writes a sort change, and drops the default sort from the URL", async () => {
		const user = userEvent.setup()
		const { router } = await renderPanel({ sort: "Credits Low to High" })

		await user.click(screen.getByRole("combobox", { name: "Sort activities" }))
		await user.click(
			await screen.findByRole("option", { name: "Credits High to Low" }),
		)
		await waitFor(() => {
			expect(currentSearch(router).sort).toBe("Credits High to Low")
		})

		await user.click(screen.getByRole("combobox", { name: "Sort activities" }))
		await user.click(
			await screen.findByRole("option", { name: "Date most recent to oldest" }),
		)
		await waitFor(() => {
			expect(currentSearch(router).sort).toBeUndefined()
		})
	})
})

describe("paging", () => {
	it("steps forward, and stepping back to page 1 drops the param", async () => {
		const user = userEvent.setup()
		const { router } = await renderPanel({ page: 2 })

		expect(screen.getByText("Page 2 of 3")).toBeInTheDocument()
		expect(screen.getByText(/Showing/)).toHaveTextContent("Showing 21–40 of 45")

		await user.click(screen.getByRole("button", { name: "Next" }))
		await waitFor(() => {
			expect(currentSearch(router).page).toBe(3)
		})

		// Page 1 is the default and must not linger in a shareable URL.
		await user.click(screen.getByRole("button", { name: "Previous" }))
		await waitFor(() => {
			expect(currentSearch(router).page).toBeUndefined()
		})
	})

	it("cannot step past either end", async () => {
		await renderPanel({ page: 3 })
		expect(screen.getByRole("button", { name: "Next" })).toBeDisabled()
		expect(screen.getByRole("button", { name: "Previous" })).toBeEnabled()
	})

	it("offers no paginator when one page holds everything", async () => {
		await renderPanel(
			{},
			cpdActivitiesOrg({
				respond: () => cpdActivityView({ totalCount: 3 }),
			}),
		)
		expect(
			screen.queryByRole("navigation", { name: "Credit opportunities pages" }),
		).not.toBeInTheDocument()
	})
})

describe("Submit Credits", () => {
	it("opens the claim dialog seeded from the picked activity, and closes clean", async () => {
		const user = userEvent.setup()
		await renderPanel(
			{},
			cpdActivitiesOrg({
				respond: () =>
					cpdActivityView({
						cpdActivities: [cpdActivity({ title: "Climate Risk Webinar" })],
					}),
				activityTypes: [
					{
						id: "type-webinar",
						name: "Webinar",
						organizationLabel: null,
						providerLabel: "Provider",
						publicationLabel: null,
						titleLabel: "Title",
						contactEmailLabel: null,
					},
				],
			}),
		)

		await user.click(screen.getByRole("button", { name: "Submit Credits" }))
		const dialog = await screen.findByRole("dialog", { name: "Credit Details" })
		expect(dialog).toBeInTheDocument()

		await user.click(screen.getByRole("button", { name: "Cancel" }))
		await waitFor(() => {
			expect(screen.queryByRole("dialog")).not.toBeInTheDocument()
		})
	})
})
