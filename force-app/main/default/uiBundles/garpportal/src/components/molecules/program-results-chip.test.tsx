import { screen } from "@testing-library/react"
import { describe, expect, it } from "vitest"

import { ProgramResultsChip } from "@/components/molecules/program-results-chip"
import { renderWithRouterProviders } from "@/testing/router"

describe("ProgramResultsChip", () => {
	it("links to the program's results page, named for screen readers", async () => {
		await renderWithRouterProviders(<ProgramResultsChip programType="FRM" />)

		const link = screen.getByRole("link", {
			name: "View exam results for FRM",
		})
		expect(link).toHaveTextContent("Results")
		expect(link).toHaveAttribute("href", "/programs/frm/results")
	})

	it("normalises the rai reporting label onto the riskai results route", async () => {
		await renderWithRouterProviders(<ProgramResultsChip programType="rai" />)

		expect(
			screen.getByRole("link", { name: "View exam results for rai" }),
		).toHaveAttribute("href", "/programs/riskai/results")
	})

	it("renders nothing for a program the results route cannot serve", async () => {
		await renderWithRouterProviders(
			<ProgramResultsChip programType="Buy-Side Risk" />,
		)

		expect(screen.queryByRole("link")).not.toBeInTheDocument()
	})
})
