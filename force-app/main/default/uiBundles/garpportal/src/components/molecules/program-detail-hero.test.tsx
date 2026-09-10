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
		nextStepTone: "info",
		notes: [],
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

describe("ProgramDetailHero — the next-step card", () => {
	it("turns into an alert when the tone is danger", async () => {
		await renderWithRouterProviders(
			<ProgramDetailHero
				presentation={presentation({
					nextStepTone: "danger",
					nextStepTitle: "You have an unpaid exam change",
					nextStepBody: "You must pay before April 20, 2027 to complete this request.",
				})}
			/>,
		)
		expect(screen.getByRole("alert")).toHaveTextContent(
			"You have an unpaid exam change",
		)
		expect(screen.getByText("Action required")).toBeInTheDocument()
		expect(screen.queryByText("Next step")).not.toBeInTheDocument()
	})

	it("prints the notes under the body, muted", async () => {
		await renderWithRouterProviders(
			<ProgramDetailHero
				presentation={presentation({
					notes: ["Select 'Take Exam' to check in 30 minutes prior."],
				})}
			/>,
		)
		expect(
			screen.getByText("Select 'Take Exam' to check in 30 minutes prior."),
		).toBeInTheDocument()
		expect(screen.queryByRole("alert")).not.toBeInTheDocument()
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

	/*
	 * The detail page and the Register page name the same programme, so they must
	 * not do it in two different typefaces. `base.css` gives every h1 Klinic Slab,
	 * so the sans family has to be stated explicitly here.
	 */
	it("names the programme in the same family the registration bar uses", async () => {
		await renderWithRouterProviders(<ProgramDetailHero presentation={presentation()} />)

		const heading = screen.getByRole("heading", { level: 1 })
		expect(heading).toHaveClass("font-sans", "font-extrabold")
		expect(heading).not.toHaveClass("font-heading")
	})

	describe("the logo tile", () => {
		const CHROME = {
			wordmark: "/wordmark.png",
			label: "FRM",
			seal: "/seal.png",
			bannerArt: "/banner.jpg",
			canvas: "canvas-frm",
			barWash: "bg-linear-to-b from-garp-cyan/12 to-transparent",
		}

		it("sits the API logo on the programme's own hue", async () => {
			const { container } = await renderWithRouterProviders(
				<ProgramDetailHero
					presentation={presentation()}
					logoUrl="/api-logo.png"
					chrome={CHROME}
				/>,
			)

			const img = container.querySelector("img")
			expect(img).toHaveAttribute("src", "/api-logo.png")
			expect(img?.parentElement?.className).toContain("from-garp-cyan/12")
		})

		/*
		 * The API has no logo for every programme, and an empty tile reads as a
		 * failed load. The seal is the same asset the registration bar shows.
		 */
		it("falls back to the seal when the API has no logo", async () => {
			const { container } = await renderWithRouterProviders(
				<ProgramDetailHero presentation={presentation()} chrome={CHROME} />,
			)

			expect(container.querySelector("img")).toHaveAttribute("src", "/seal.png")
		})

		/* No chrome, no logo — the tile stays away rather than showing an empty box. */
		it("renders no tile at all for a programme with neither", async () => {
			const { container } = await renderWithRouterProviders(
				<ProgramDetailHero presentation={presentation()} />,
			)

			expect(container.querySelector("img")).toBeNull()
		})

		it("keeps the neutral tile when the programme has no chrome", async () => {
			const { container } = await renderWithRouterProviders(
				<ProgramDetailHero presentation={presentation()} logoUrl="/api-logo.png" />,
			)

			expect(container.querySelector("img")?.parentElement?.className).toContain(
				"bg-muted/40",
			)
		})
	})
})
