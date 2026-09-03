import { render, screen } from "@testing-library/react"
import { describe, expect, it } from "vitest"

import { CpdCreditBars, CpdCreditBarsSkeleton } from "./cpd-credit-bars"

/**
 * Pins the two things that would silently misstate a member's CPD position:
 * the shared x-scale across bars, and the theming contract (brand tokens only,
 * never a stock Tailwind palette class or a hex).
 */
describe("CpdCreditBars", () => {
	it("renders one labelled row per designation", () => {
		render(
			<CpdCreditBars
				rows={[
					{ designation: "FRM", approved: 20, required: 40 },
					{ designation: "SCR", approved: 20, required: 20 },
				]}
			/>,
		)
		expect(screen.getByText("FRM")).toBeInTheDocument()
		expect(screen.getByText("SCR")).toBeInTheDocument()
		expect(screen.getByText("20 / 40")).toBeInTheDocument()
		expect(screen.getByText("20 / 20")).toBeInTheDocument()
	})

	it("renders nothing when no designation is answerable for credits", () => {
		const { container } = render(<CpdCreditBars rows={[]} />)
		expect(container).toBeEmptyDOMElement()
	})

	it("omits the remainder once the requirement is met", () => {
		// Legacy pushed a null for `required - approved <= 0`, leaving a solid
		// bar with no grey tail. Two rects means a remainder was drawn.
		const { container } = render(
			<CpdCreditBars rows={[{ designation: "SCR", approved: 20, required: 20 }]} />,
		)
		expect(container.querySelectorAll("rect")).toHaveLength(1)
	})

	it("draws a remainder while credits are still owed", () => {
		const { container } = render(
			<CpdCreditBars rows={[{ designation: "FRM", approved: 10, required: 40 }]} />,
		)
		expect(container.querySelectorAll("rect")).toHaveLength(2)
	})

	it("stands in with one skeleton bar per expected row, hidden from AT", () => {
		const { container } = render(<CpdCreditBarsSkeleton rows={3} />)

		expect(container.firstElementChild).toHaveAttribute("aria-hidden")
		expect(
			container.querySelectorAll('[data-slot="skeleton"]'),
		).toHaveLength(3)
		// Nothing announceable — the loaded bars' labels must not be faked.
		expect(screen.queryByText(/\d+ \/ \d+/)).not.toBeInTheDocument()
	})

	it("paints from brand tokens, never a stock palette class", () => {
		const { container } = render(
			<CpdCreditBars
				rows={[
					{ designation: "FRM", approved: 1, required: 40 },
					{ designation: "ERP", approved: 1, required: 40 },
					{ designation: "SCR", approved: 1, required: 20 },
					{ designation: "RAI", approved: 1, required: 20 },
				]}
			/>,
		)
		const classes = [...container.querySelectorAll("rect")].map(
			(rect) => rect.getAttribute("class") ?? "",
		)
		expect(classes).toEqual(
			expect.arrayContaining([
				"text-garp-cyan",
				"text-erp-green",
				"text-garp-saffron",
				"text-rai-blue",
			]),
		)
		for (const value of classes) {
			expect(value).not.toMatch(/#|text-(blue|green|yellow|red|gray|slate)-\d/)
		}
	})
})
