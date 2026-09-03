import { fireEvent, render, screen } from "@testing-library/react"
import { describe, expect, it } from "vitest"

import type { Benefit } from "@/api/membership/types"

import { BenefitCard } from "./benefit-card"

function benefit(overrides: Partial<Benefit> = {}): Benefit {
	return {
		id: "ben-1",
		title: "GARP Risk Intelligence",
		section: "Insights",
		sortOrder: 1,
		paragraphs: ["Weekly analysis from GARP's editorial team."],
		bullets: [],
		imageUrl: null,
		ctaLabel: "Read now",
		ctaUrl: "https://www.garp.org/risk-intelligence",
		ctaIsExternal: true,
		opensInNewWindow: false,
		promoCode: null,
		locked: false,
		membershipRequired: false,
		...overrides,
	}
}

describe("BenefitCard", () => {
	it("lists visible bullets and counts the trimmed remainder honestly", () => {
		render(
			<BenefitCard
				benefit={benefit({
					paragraphs: [],
					bullets: ["One", "Two", "Three", "Four", "Five"],
				})}
			/>,
		)

		expect(screen.getAllByRole("listitem")).toHaveLength(3)
		for (const bullet of ["One", "Two", "Three"]) {
			expect(screen.getByText(bullet)).toBeInTheDocument()
		}
		expect(screen.queryByText("Four")).not.toBeInTheDocument()
		expect(screen.getByText("+2 more")).toBeInTheDocument()
	})

	it("hides a broken benefit image rather than showing the broken glyph", () => {
		const { container } = render(
			<BenefitCard benefit={benefit({ imageUrl: "https://cdn/broken.png" })} />,
		)

		const img = container.querySelector("img")
		expect(img).not.toBeNull()
		fireEvent.error(img as HTMLImageElement)

		expect((img as HTMLImageElement).style.display).toBe("none")
	})

	it("overlays the upgrade pitch on a locked benefit", () => {
		render(<BenefitCard benefit={benefit({ locked: true })} />)

		expect(screen.getByText("Individual Membership")).toBeInTheDocument()
		expect(screen.getByText("Upgrade to unlock this benefit")).toBeInTheDocument()
	})
})
