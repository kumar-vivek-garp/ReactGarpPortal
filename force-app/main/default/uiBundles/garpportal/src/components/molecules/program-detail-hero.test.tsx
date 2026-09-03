import { fireEvent, screen } from "@testing-library/react"
import { describe, expect, it } from "vitest"

import { ProgramDetailHero } from "@/components/molecules/program-detail-hero"
import type { ProgramDetailPresentation } from "@/lib/program-detail-presentation"
import { renderWithRouterProviders } from "@/testing/router"

function presentation(
	overrides: Partial<ProgramDetailPresentation> = {},
): ProgramDetailPresentation {
	return {
		displayName: "Financial Risk Manager",
		examLabel: "FRM Exam Part I",
		description: "The global standard for financial risk.",
		administration: "May 2027",
		statusLabel: "In Progress",
		statusTone: "info",
		statusSummary: "You are registered for the May 2027 sitting.",
		nextStepTitle: "Schedule your exam",
		nextStepBody: "Pick a date and centre before the window closes.",
		primaryAction: null,
		secondaryActions: [],
		milestones: [],
		isTwoPart: true,
		...overrides,
	}
}

describe("ProgramDetailHero — identity block", () => {
	it("renders name, status, administration, description and both step lines", async () => {
		await renderWithRouterProviders(
			<ProgramDetailHero presentation={presentation()} />,
		)

		expect(
			screen.getByRole("heading", { level: 1, name: "Financial Risk Manager" }),
		).toBeInTheDocument()
		expect(screen.getByText("In Progress")).toBeInTheDocument()
		expect(screen.getByText("May 2027")).toBeInTheDocument()
		expect(
			screen.getByText("The global standard for financial risk."),
		).toBeInTheDocument()
		expect(
			screen.getByRole("heading", { level: 2, name: "Schedule your exam" }),
		).toBeInTheDocument()
		expect(
			screen.getByText("Pick a date and centre before the window closes."),
		).toBeInTheDocument()
	})

	it("drops administration and description lines when the payload has neither", async () => {
		await renderWithRouterProviders(
			<ProgramDetailHero
				presentation={presentation({ administration: null, description: null })}
			/>,
		)

		expect(screen.queryByText("May 2027")).not.toBeInTheDocument()
		expect(
			screen.queryByText("The global standard for financial risk."),
		).not.toBeInTheDocument()
	})

	it("shows the logo only when one is passed, and hides it if it fails to load", async () => {
		const { rerender } = await renderWithRouterProviders(
			<ProgramDetailHero
				presentation={presentation()}
				logoUrl="https://hub.garp.org/frm.png"
			/>,
		)

		const logo = document.querySelector("img") as HTMLImageElement
		expect(logo).toHaveAttribute("src", "https://hub.garp.org/frm.png")
		fireEvent.error(logo)
		expect(logo).not.toBeVisible()

		rerender(<ProgramDetailHero presentation={presentation()} logoUrl={null} />)
		expect(document.querySelector("img")).toBeNull()
	})
})

describe("ProgramDetailHero — actions", () => {
	it("renders an external primary action as a new-window anchor", async () => {
		await renderWithRouterProviders(
			<ProgramDetailHero
				presentation={presentation({
					primaryAction: {
						kind: "registerAgain",
						label: "Register again",
						url: "https://www.garp.org/frm/register",
						isExternal: true,
						newWindow: true,
					},
				})}
			/>,
		)

		const link = screen.getByRole("link", { name: "Register again" })
		expect(link).toHaveAttribute("href", "https://www.garp.org/frm/register")
		expect(link).toHaveAttribute("target", "_blank")
	})

	it("keeps an external action in the same window unless newWindow is set", async () => {
		await renderWithRouterProviders(
			<ProgramDetailHero
				presentation={presentation({
					primaryAction: {
						kind: "viewOrder",
						label: "Complete payment",
						url: "https://my.garp.org/pay",
						isExternal: true,
					},
				})}
			/>,
		)

		expect(
			screen.getByRole("link", { name: "Complete payment" }),
		).not.toHaveAttribute("target")
	})

	it("routes an internal action through the router, carrying its query string", async () => {
		await renderWithRouterProviders(
			<ProgramDetailHero
				presentation={presentation({
					primaryAction: {
						kind: "setup",
						label: "Schedule exam",
						url: "/programs/frm/exam-setup?attempt=a-1",
						isExternal: false,
					},
				})}
			/>,
		)

		expect(screen.getByRole("link", { name: "Schedule exam" })).toHaveAttribute(
			"href",
			"/programs/frm/exam-setup?attempt=a-1",
		)
	})

	it("routes a plain internal action without inventing a search object", async () => {
		await renderWithRouterProviders(
			<ProgramDetailHero
				presentation={presentation({
					primaryAction: {
						kind: "workExperience",
						label: "Submit CV",
						url: "/programs/frm/work-experience",
						isExternal: false,
					},
				})}
			/>,
		)

		expect(screen.getByRole("link", { name: "Submit CV" })).toHaveAttribute(
			"href",
			"/programs/frm/work-experience",
		)
	})

	it("lists secondary actions beside the primary, and no footer without either", async () => {
		const { rerender } = await renderWithRouterProviders(
			<ProgramDetailHero
				presentation={presentation({
					secondaryActions: [
						{
							kind: "digitalBadge",
							label: "View digital badge",
							url: "https://badges.garp.org/b1",
							isExternal: true,
							newWindow: true,
						},
					],
				})}
			/>,
		)

		expect(
			screen.getByRole("link", { name: /View digital badge/ }),
		).toHaveAttribute("href", "https://badges.garp.org/b1")

		rerender(<ProgramDetailHero presentation={presentation()} />)
		expect(screen.queryByRole("link")).not.toBeInTheDocument()
	})
})
