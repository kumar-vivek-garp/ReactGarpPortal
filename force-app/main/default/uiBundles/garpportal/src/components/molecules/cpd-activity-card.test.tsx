import { screen } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { describe, expect, it, vi } from "vitest"

import { CpdActivityCard } from "@/components/molecules/cpd-activity-card"
import { cpdActivity } from "@/testing/factories/cpd"
import { renderWithRouterProviders } from "@/testing/router"

async function renderCard(
	overrides: Parameters<typeof cpdActivity>[0] = {},
	props: Partial<{ showPermalink: boolean }> = {},
) {
	const onSubmitCredits = vi.fn()
	const rendered = await renderWithRouterProviders(
		<CpdActivityCard
			activity={cpdActivity(overrides)}
			onSubmitCredits={onSubmitCredits}
			{...props}
		/>,
	)
	return { ...rendered, onSubmitCredits }
}

const detailsToggle = () =>
	screen.queryByRole("button", { name: /View Details|Hide Details/ })

describe("the in-place details", () => {
	it("expands and collapses, and carries the link out", async () => {
		const user = userEvent.setup()
		await renderCard({
			description: "A two-hour session on transition risk.",
			url: "https://example.test/webinar",
		})

		const toggle = detailsToggle()!
		expect(toggle).toHaveTextContent("View Details")
		expect(toggle).toHaveAttribute("aria-expanded", "false")

		await user.click(toggle)
		expect(toggle).toHaveTextContent("Hide Details")
		expect(toggle).toHaveAttribute("aria-expanded", "true")
		expect(
			screen.getByText("A two-hour session on transition risk."),
		).toBeInTheDocument()
		expect(screen.getByRole("link", { name: /Visit Website/ })).toHaveAttribute(
			"href",
			"https://example.test/webinar",
		)

		await user.click(toggle)
		expect(toggle).toHaveTextContent("View Details")
	})

	it("offers no toggle when there is nothing to disclose", async () => {
		await renderCard({ description: null, url: null })
		expect(detailsToggle()).not.toBeInTheDocument()
	})
})

describe("the actions row", () => {
	it("hands the activity to Submit Credits", async () => {
		const user = userEvent.setup()
		const { onSubmitCredits } = await renderCard()

		await user.click(screen.getByRole("button", { name: "Submit Credits" }))
		expect(onSubmitCredits).toHaveBeenCalledTimes(1)
		expect(onSubmitCredits.mock.calls[0][0]).toMatchObject({ id: "act-1" })
	})

	it("links to the activity's own page, unless already scoped to it", async () => {
		const { unmount } = await renderCard()
		const link = screen.getByRole("link", { name: /Open/ })
		expect(link.getAttribute("href")).toContain("activityId=act-1")
		unmount()

		await renderCard({}, { showPermalink: false })
		expect(screen.queryByRole("link", { name: /Open/ })).not.toBeInTheDocument()
	})

	it("cannot link to an activity without an id", async () => {
		await renderCard({ id: null })
		expect(screen.queryByRole("link", { name: /Open/ })).not.toBeInTheDocument()
	})
})

describe("what the row says about itself", () => {
	it("formats credits, areas and the meta line from the presentation rules", async () => {
		await renderCard()
		expect(screen.getByText("2 credits")).toBeInTheDocument()
		expect(screen.getByText("Credit Risk, Market Risk")).toBeInTheDocument()
		expect(screen.getByText("1 February 2026 | GARP")).toBeInTheDocument()
	})

	it("falls back to the activity type when there is no title", async () => {
		await renderCard({ title: null })
		expect(
			screen.getByRole("heading", { name: "Webinar" }),
		).toBeInTheDocument()
	})
})
