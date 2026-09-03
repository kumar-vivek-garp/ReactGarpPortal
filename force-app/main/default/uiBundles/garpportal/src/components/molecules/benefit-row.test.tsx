import { fireEvent, render, screen } from "@testing-library/react"
import { describe, expect, it } from "vitest"

import type { Benefit } from "@/api/membership/types"

import { BenefitRow } from "./benefit-row"

function benefit(overrides: Partial<Benefit> = {}): Benefit {
	return {
		id: "ben-1",
		title: "GARP Risk Intelligence",
		section: "Insights",
		sortOrder: 1,
		paragraphs: [],
		bullets: [],
		imageUrl: null,
		ctaLabel: null,
		ctaUrl: null,
		ctaIsExternal: false,
		opensInNewWindow: false,
		promoCode: null,
		locked: false,
		membershipRequired: false,
		...overrides,
	}
}

describe("BenefitRow", () => {
	it("summarises bullets on one line when there is no body copy", () => {
		render(
			<BenefitRow
				benefit={benefit({ bullets: ["Weekly digest", "Member webcasts"] })}
			/>,
		)

		expect(
			screen.getByRole("heading", { name: "GARP Risk Intelligence" }),
		).toBeInTheDocument()
		expect(
			screen.getByText("Weekly digest · Member webcasts"),
		).toBeInTheDocument()
	})

	it("hides a broken thumbnail rather than showing the broken glyph", () => {
		const { container } = render(
			<BenefitRow benefit={benefit({ imageUrl: "https://cdn/broken.png" })} />,
		)

		const img = container.querySelector("img")
		expect(img).not.toBeNull()
		fireEvent.error(img as HTMLImageElement)

		expect((img as HTMLImageElement).style.display).toBe("none")
	})
})
