import { fireEvent, screen } from "@testing-library/react"
import { describe, expect, it } from "vitest"

import type { EnrolledProgram } from "@/api/programs"
import { ProgramCard } from "@/components/molecules/program-card"
import { renderWithRouterProviders } from "@/testing/router"

function enrolled(overrides: Partial<EnrolledProgram> = {}): EnrolledProgram {
	return {
		programType: "frm",
		adminPartIName: null,
		adminPartIIName: null,
		programInformation: {
			programCode: "FRM",
			abbrevName: "FRM",
			formalName: "Financial Risk Manager",
			informalName: null,
			policyURL: null,
			regLogoURL: null,
			myProgramsLogoURL: "https://hub.garp.org/logos/frm.png",
			description: null,
			registrationPath: null,
		},
		...overrides,
	}
}

describe("ProgramCard", () => {
	it("hides the logo once it fails to load instead of showing a broken image", async () => {
		await renderWithRouterProviders(
			<ProgramCard variant="inProgress" program={enrolled()} priority />,
		)

		const logo = document.querySelector("img") as HTMLImageElement
		expect(logo).toHaveAttribute("loading", "eager")
		fireEvent.error(logo)
		expect(logo).not.toBeVisible()
	})

	it("renders no logo tile content when the program carries no artwork", async () => {
		await renderWithRouterProviders(
			<ProgramCard
				variant="inProgress"
				program={enrolled({ programInformation: null })}
			/>,
		)

		expect(document.querySelector("img")).toBeNull()
	})

	it("adds the Results chip when the member has results for it", async () => {
		await renderWithRouterProviders(
			<ProgramCard variant="inProgress" program={enrolled()} hasResults />,
		)

		expect(
			screen.getByRole("link", { name: "View exam results for frm" }),
		).toBeInTheDocument()
	})

	it("offers no Results chip by default", async () => {
		await renderWithRouterProviders(
			<ProgramCard variant="inProgress" program={enrolled()} />,
		)

		expect(
			screen.queryByRole("link", { name: "View exam results for frm" }),
		).not.toBeInTheDocument()
	})
})
