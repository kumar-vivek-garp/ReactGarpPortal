import { fireEvent, screen } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { describe, expect, it } from "vitest"

import type { Benefit } from "@/api/membership/types"
import { buildBenefitPresentation } from "@/lib/membership-presentation"
import { renderWithProviders } from "@/testing/render"

import { BenefitDetailsDialog } from "./benefit-details-dialog"

function benefit(overrides: Partial<Benefit> = {}): Benefit {
	return {
		id: "ben-1",
		title: "GARP Risk Intelligence",
		section: "Insights",
		sortOrder: 1,
		paragraphs: [
			"Weekly analysis from GARP's editorial team.",
			"Archives back to 2015 are included.",
		],
		bullets: ["Weekly digest", "Member webcasts", "Research library", "Podcasts"],
		imageUrl: "https://cdn/benefit.png",
		ctaLabel: "Read now",
		ctaUrl: "https://www.garp.org/risk-intelligence",
		ctaIsExternal: true,
		opensInNewWindow: false,
		promoCode: "GARP24",
		locked: false,
		membershipRequired: false,
		...overrides,
	}
}

async function openDialog(source = benefit()) {
	const user = userEvent.setup()
	const item = buildBenefitPresentation(source)
	const rendered = renderWithProviders(<BenefitDetailsDialog item={item} />)

	await user.click(
		screen.getByRole("button", { name: "About GARP Risk Intelligence" }),
	)
	return { user, item, ...rendered }
}

describe("BenefitDetailsDialog", () => {
	it("opens the full, untrimmed copy the card had to clamp", async () => {
		await openDialog()

		const dialog = await screen.findByRole("dialog")
		expect(dialog).toHaveTextContent("GARP Risk Intelligence")
		// Lede is the first paragraph; the rest follow in the body.
		expect(dialog).toHaveTextContent(
			"Weekly analysis from GARP's editorial team.",
		)
		expect(dialog).toHaveTextContent("Archives back to 2015 are included.")
		// Every bullet, including the ones the card trimmed past three.
		expect(screen.getAllByRole("listitem")).toHaveLength(4)
		expect(dialog).toHaveTextContent("GARP24")
		expect(screen.getByRole("link", { name: /Read now/ })).toHaveAttribute(
			"href",
			"https://www.garp.org/risk-intelligence",
		)
	})

	it("hides a broken dialog image rather than showing the broken glyph", async () => {
		await openDialog()

		const dialog = await screen.findByRole("dialog")
		const img = dialog.querySelector("img")
		expect(img).not.toBeNull()
		fireEvent.error(img as HTMLImageElement)

		expect((img as HTMLImageElement).style.display).toBe("none")
	})
})
