import { screen } from "@testing-library/react"
import { describe, expect, it } from "vitest"

import type { ProgramChrome } from "@/config/program-chrome"
import { renderWithProviders } from "@/testing/render"

import { ProgramBarIdentity } from "./program-bar-identity"

const CHROME: ProgramChrome = {
	wordmark: "/wordmark.png",
	label: "FRM",
	seal: "/seal.png",
	bannerArt: "/banner.jpg",
	canvas: "canvas-frm",
	barWash: "bg-linear-to-b from-garp-cyan/12 to-transparent",
}

const HEADING = {
	prefix: "Financial Risk Manager (",
	highlight: "FRM",
	highlightToken: "garp-cyan",
	symbol: "®",
	suffix: ") Exam Registration",
} as const

describe("ProgramBarIdentity", () => {
	it("names the certification in full as the bar's h1", () => {
		renderWithProviders(
			<ProgramBarIdentity chrome={CHROME} heading={HEADING} />,
		)

		expect(screen.getByRole("heading", { level: 1 })).toHaveTextContent(
			"Financial Risk Manager (FRM®) Exam Registration",
		)
	})

	/*
	 * The seal repeats what the heading beside it already says, so announcing it
	 * would say the programme twice.
	 */
	it("shows the seal as decoration, with no accessible name", () => {
		const { container } = renderWithProviders(
			<ProgramBarIdentity chrome={CHROME} heading={HEADING} />,
		)

		expect(screen.queryAllByRole("img")).toHaveLength(0)
		expect(container.querySelector("img")).toHaveAttribute("src", "/seal.png")
	})

	/*
	 * The fallback that keeps every un-redesigned programme on the plain bar —
	 * the same contract the guest pages use.
	 */
	it("renders the title alone when the programme has no chrome", () => {
		const { container } = renderWithProviders(
			<ProgramBarIdentity heading={HEADING} />,
		)

		expect(container.querySelector("img")).toBeNull()
		expect(screen.getByRole("heading", { level: 1 })).toBeInTheDocument()
	})

	/*
	 * The bar is 5.5rem and `REGISTRATION_RAIL_COLUMN`'s `lg:top-28` is derived
	 * from that height, so a seal that grew the row would silently unpin the
	 * order rail on every registration page.
	 */
	it("keeps the seal at a fixed 36px box", () => {
		const { container } = renderWithProviders(
			<ProgramBarIdentity chrome={CHROME} heading={HEADING} />,
		)

		expect(container.querySelector("img")).toHaveClass("size-9", "shrink-0")
	})

	/*
	 * Same words, same typeface as the guest banner. The bar previously used the
	 * heading font, so one programme was named in two typefaces depending on
	 * which route you were on.
	 */
	it("titles in the sans family, not the heading font", () => {
		renderWithProviders(
			<ProgramBarIdentity chrome={CHROME} heading={HEADING} />,
		)

		const heading = screen.getByRole("heading", { level: 1 })
		expect(heading).toHaveClass("font-sans", "font-extrabold")
		expect(heading).not.toHaveClass("font-heading")
	})
})
