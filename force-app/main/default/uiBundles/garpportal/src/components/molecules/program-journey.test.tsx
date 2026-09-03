import { screen } from "@testing-library/react"
import { describe, expect, it } from "vitest"

import { ProgramJourney } from "@/components/molecules/program-journey"
import type { JourneyMilestone } from "@/lib/program-detail-presentation"
import { renderWithProviders } from "@/testing/render"

const MILESTONES: JourneyMilestone[] = [
	{ id: "registration", label: "Registered", status: "complete", detail: null },
	{
		id: "scheduling",
		label: "Schedule your exam",
		status: "current",
		detail: "Setup closes 20 April 2027.",
	},
	{ id: "results", label: "Results", status: "upcoming", detail: null },
]

describe("the journey rail", () => {
	it("names each milestone with its status for assistive tech", () => {
		renderWithProviders(<ProgramJourney milestones={MILESTONES} />)

		expect(
			screen.getByRole("region", { name: "Program journey" }),
		).toBeInTheDocument()
		const items = screen.getAllByRole("listitem")
		expect(items).toHaveLength(3)
		expect(items[0].textContent).toContain("Registered")
		expect(items[0].textContent).toContain("complete")
		expect(items[1].textContent).toContain("current")
		// The detail line renders only when a milestone carries one.
		expect(
			screen.getByText("Setup closes 20 April 2027."),
		).toBeInTheDocument()
	})

	it("renders nothing for an empty journey", () => {
		const { container } = renderWithProviders(<ProgramJourney milestones={[]} />)
		expect(container).toBeEmptyDOMElement()
	})
})
