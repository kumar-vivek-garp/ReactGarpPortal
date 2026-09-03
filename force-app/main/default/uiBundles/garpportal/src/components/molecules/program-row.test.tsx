import { fireEvent, screen } from "@testing-library/react"
import { describe, expect, it } from "vitest"

import type { EnrolledProgram, ProgramInformation } from "@/api/programs/types"
import { renderWithRouterProviders } from "@/testing/router"

import { ProgramRow } from "./program-row"

function info(overrides: Partial<ProgramInformation> = {}): ProgramInformation {
	return {
		programCode: "FRM",
		abbrevName: "FRM",
		formalName: "Financial Risk Manager (FRM<sup>&reg;</sup>)",
		informalName: "Financial Risk Manager",
		policyURL: null,
		regLogoURL: null,
		myProgramsLogoURL: "https://www.garp.org/logos/frm.png",
		description: "The global standard for financial risk professionals.",
		registrationPath: null,
		...overrides,
	}
}

function enrolled(overrides: Partial<EnrolledProgram> = {}): EnrolledProgram {
	return {
		programType: "FRM",
		adminPartIName: "November 2026",
		adminPartIIName: null,
		programInformation: info(),
		...overrides,
	}
}

describe("ProgramRow", () => {
	it("renders the code chip, name and status for an enrolled program", async () => {
		await renderWithRouterProviders(
			<ProgramRow variant="inProgress" program={enrolled()} />,
		)

		expect(screen.getByText("FRM")).toBeInTheDocument()
		expect(
			screen.getByRole("heading", { name: /Financial Risk Manager/ }),
		).toBeInTheDocument()
	})

	it("hides a broken program logo rather than showing the broken glyph", async () => {
		const { container } = await renderWithRouterProviders(
			<ProgramRow variant="inProgress" program={enrolled()} />,
		)

		const img = container.querySelector("img")
		expect(img).not.toBeNull()
		fireEvent.error(img as HTMLImageElement)

		expect((img as HTMLImageElement).style.display).toBe("none")
	})
})
