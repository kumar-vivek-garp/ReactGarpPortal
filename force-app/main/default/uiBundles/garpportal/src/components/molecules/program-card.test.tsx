import { fireEvent, screen, waitFor } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { describe, expect, it } from "vitest"

import type { EnrolledProgram, OtherProgram } from "@/api/programs"
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

function other(overrides: Partial<OtherProgram> = {}): OtherProgram {
	return {
		programType: "erp",
		isRegistrationOpen: true,
		nextRegistrationOpenDate: null,
		nextRegistrationOpenAdminName: null,
		isMicroCourse: false,
		programInformation: {
			programCode: "ERP",
			abbrevName: "ERP",
			formalName: "Energy Risk Professional",
			informalName: null,
			policyURL: null,
			regLogoURL: null,
			myProgramsLogoURL: null,
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

/*
 * A card whose only destination is View Details IS that link: the whole
 * surface activates and the CTA is dropped, because a lone CTA beside a fully
 * clickable card is a second target for one job. A card with two different
 * destinations keeps its buttons and stays flat.
 */
describe("ProgramCard — the card as its own link", () => {
	it("activates as a link to the programme, with no Details CTA left over", async () => {
		const user = userEvent.setup()
		const { router } = await renderWithRouterProviders(
			<ProgramCard variant="inProgress" program={enrolled()} />,
		)

		expect(
			screen.queryByRole("link", { name: /View Details/ }),
		).not.toBeInTheDocument()

		const card = screen.getByRole("link", {
			name: "View details for Financial Risk Manager",
		})
		await user.click(card)

		// The Card defers activation until its press spring settles.
		await waitFor(() => {
			expect(router.state.location.pathname).toBe("/programs/frm")
		})
	})

	it("leaves an Explore card flat — two destinations, so no card-level click", async () => {
		await renderWithRouterProviders(
			<ProgramCard variant="other" program={other()} />,
		)

		expect(
			screen.queryByRole("link", {
				name: /View details for/,
			}),
		).not.toBeInTheDocument()
		expect(screen.getByRole("link", { name: "Register Now" })).toBeInTheDocument()
		expect(screen.getByRole("link", { name: /Learn more/ })).toBeInTheDocument()
	})

	it("does not fire the card's destination when the Results chip is clicked", async () => {
		const user = userEvent.setup()
		const { router } = await renderWithRouterProviders(
			<ProgramCard variant="inProgress" program={enrolled()} hasResults />,
		)

		await user.click(
			screen.getByRole("link", { name: "View exam results for frm" }),
		)

		/*
		 * Both destinations used to fire — the chip's immediately, the card's
		 * once its press spring settled — landing the member on the programme
		 * they did not click. The chip stops its own click from bubbling.
		 */
		await waitFor(() => {
			expect(router.state.location.pathname).toBe("/programs/frm/results")
		})
		await new Promise((resolve) => setTimeout(resolve, 250))
		expect(router.state.location.pathname).toBe("/programs/frm/results")
	})
})
