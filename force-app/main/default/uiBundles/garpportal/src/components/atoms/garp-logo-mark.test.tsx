import { fireEvent, screen, waitFor } from "@testing-library/react"
import { describe, expect, it } from "vitest"

import { GarpLogoMark } from "@/components/atoms/garp-logo-mark"
import { stubMatchMedia } from "@/testing/match-media"
import { renderWithProviders } from "@/testing/render"
import { skipSpringAnimations } from "@/testing/springs"

// Safe here: the mark's spring is imperative (api.start), not per-render props.
skipSpringAnimations()

const media = stubMatchMedia()

function hurricane(svg: HTMLElement) {
	// The animated group is the first <g>; react-spring writes its transform.
	return svg.querySelector("g") as SVGGElement
}

describe("GarpLogoMark", () => {
	it("is an image named GARP by default, hidden when a parent names it", () => {
		const { unmount } = renderWithProviders(<GarpLogoMark />)
		expect(screen.getByRole("img", { name: "GARP" })).toBeInTheDocument()
		unmount()

		renderWithProviders(<GarpLogoMark label={null} data-testid="mark" />)
		expect(screen.getByTestId("mark")).toHaveAttribute("aria-hidden", "true")
	})

	it("winds up and spins one full accumulated turn per hover", async () => {
		renderWithProviders(<GarpLogoMark />)
		const svg = screen.getByRole("img", { name: "GARP" })

		fireEvent.pointerEnter(svg)
		await waitFor(() =>
			expect(hurricane(svg).style.transform).toBe("rotate(360deg)"),
		)

		// The next hover keeps accumulating — no snap back to zero.
		fireEvent.pointerEnter(svg)
		await waitFor(() =>
			expect(hurricane(svg).style.transform).toBe("rotate(720deg)"),
		)
	})

	it("ignores a second hover while a spin is still in flight", async () => {
		renderWithProviders(<GarpLogoMark />)
		const svg = screen.getByRole("img", { name: "GARP" })

		fireEvent.pointerEnter(svg)
		fireEvent.pointerEnter(svg)

		await waitFor(() =>
			expect(hurricane(svg).style.transform).toBe("rotate(360deg)"),
		)
	})

	it("stays still when spinning is turned off", () => {
		renderWithProviders(<GarpLogoMark spinOnHover={false} />)
		const svg = screen.getByRole("img", { name: "GARP" })

		fireEvent.pointerEnter(svg)
		expect(hurricane(svg).style.transform).toBe("rotate(0deg)")
	})

	it("respects the OS reduced-motion preference", () => {
		media.matches = true
		renderWithProviders(<GarpLogoMark />)
		const svg = screen.getByRole("img", { name: "GARP" })

		fireEvent.pointerEnter(svg)
		expect(hurricane(svg).style.transform).toBe("rotate(0deg)")
	})
})
