import { screen } from "@testing-library/react"
import { describe, expect, it } from "vitest"

import type { ProgramChrome } from "@/config/program-chrome"
import { renderWithProviders } from "@/testing/render"

import { RegistrationBanner } from "./registration-banner"

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

describe("RegistrationBanner", () => {
	/*
	 * The banner carries the page's `h1` because on the public route it is the
	 * document's only heading, and that page is linked from marketing email.
	 */
	it("names the certification in full as the page's h1", () => {
		renderWithProviders(
			<RegistrationBanner chrome={CHROME} heading={HEADING} />,
		)

		const heading = screen.getByRole("heading", { level: 1 })
		expect(heading).toHaveTextContent(
			"Financial Risk Manager (FRM®) Exam Registration",
		)
	})

	/*
	 * Artwork and seal are decoration — the heading already says which
	 * programme this is, so announcing them repeats it twice to a screen
	 * reader.
	 */
	it("leaves the artwork and seal out of the accessibility tree", () => {
		renderWithProviders(
			<RegistrationBanner chrome={CHROME} heading={HEADING} />,
		)

		expect(screen.queryAllByRole("img")).toHaveLength(0)
	})

	it("renders the programme's own artwork", () => {
		const { container } = renderWithProviders(
			<RegistrationBanner chrome={CHROME} heading={HEADING} />,
		)

		const sources = Array.from(container.querySelectorAll("img")).map((img) =>
			img.getAttribute("src"),
		)
		expect(sources).toEqual(["/banner.jpg", "/seal.png"])
	})

	/*
	 * FRM and SCR take the 30px `--text-title`; RAI's frame asks for 40px and
	 * supplies it as a literal class. Only the desktop step varies — the phone
	 * sizes are driven by wrapping, not by the design.
	 */
	it("takes the default title size unless the programme overrides it", () => {
		renderWithProviders(<RegistrationBanner chrome={CHROME} heading={HEADING} />)

		expect(screen.getByRole("heading", { level: 1 })).toHaveClass(
			"app:text-title",
		)
	})

	it("applies a programme's own title size when it has one", () => {
		renderWithProviders(
			<RegistrationBanner
				chrome={{ ...CHROME, titleSizeClass: "app:text-banner" }}
				heading={HEADING}
			/>,
		)

		const heading = screen.getByRole("heading", { level: 1 })
		expect(heading).toHaveClass("app:text-banner")
		expect(heading).not.toHaveClass("app:text-title")
	})
})
