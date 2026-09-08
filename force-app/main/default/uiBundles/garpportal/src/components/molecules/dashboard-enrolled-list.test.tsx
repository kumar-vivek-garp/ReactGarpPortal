import { screen } from "@testing-library/react"
import { describe, expect, it } from "vitest"

import type { DashboardEnrolledPreview } from "@/api/dashboard"
import { DashboardEnrolledList } from "@/components/molecules/dashboard-enrolled-list"
import { renderWithRouterProviders } from "@/testing/router"

function program(
	overrides: Partial<DashboardEnrolledPreview> = {},
): DashboardEnrolledPreview {
	return {
		programType: "frm",
		name: "Financial Risk Manager",
		adminPartIName: "May 2026",
		adminPartIIName: null,
		...overrides,
	}
}

describe("DashboardEnrolledList", () => {
	it("links a two-part exam programme to its detail page", async () => {
		await renderWithRouterProviders(
			<DashboardEnrolledList programs={[program()]} />,
		)

		expect(
			screen.getByRole("link", { name: "Financial Risk Manager" }),
		).toHaveAttribute("href", "/programs/frm")
		expect(screen.getByText("May 2026")).toBeInTheDocument()
	})

	it("sends a course to its course page instead", async () => {
		await renderWithRouterProviders(
			<DashboardEnrolledList
				programs={[program({ programType: "frr", name: "FRR" })]}
			/>,
		)

		expect(screen.getByRole("link", { name: "FRR" })).toHaveAttribute(
			"href",
			"/courses/frr",
		)
	})

	/*
	 * The names are plain links, like the event names on the card beside this
	 * one. The nudging arrow belongs to the card's bottom CTA and nowhere else:
	 * when every name inside a card animates an arrow too, the one action the
	 * card is steering towards stops standing out.
	 */
	it("gives a programme name no CTA arrow of its own", async () => {
		const { container } = await renderWithRouterProviders(
			<DashboardEnrolledList programs={[program()]} />,
		)

		const link = screen.getByRole("link", { name: "Financial Risk Manager" })
		expect(link.querySelector("svg")).toBeNull()
		expect(container.querySelectorAll("svg")).toHaveLength(0)
	})

	it("renders nothing at all when there is nothing enrolled", async () => {
		const { container } = await renderWithRouterProviders(
			<DashboardEnrolledList programs={[]} />,
		)
		expect(container).toBeEmptyDOMElement()
	})
})
