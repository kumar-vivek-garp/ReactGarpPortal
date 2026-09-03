import { render, screen } from "@testing-library/react"
import { describe, expect, it } from "vitest"

import { MegaMenuHeadingText } from "@/components/molecules/mega-menu-heading"

describe("the branded acronym", () => {
	it("tints a plain highlight and carries the registration symbol", () => {
		render(
			<h1>
				<MegaMenuHeadingText
					heading={{
						prefix: "Financial Risk Manager (",
						highlight: "FRM",
						highlightToken: "garp-cyan",
						symbol: "®",
						suffix: ")",
					}}
				/>
			</h1>,
		)
		expect(screen.getByRole("heading").textContent).toBe(
			"Financial Risk Manager (FRM®)",
		)
		expect(screen.getByText("FRM").textContent).toContain("®")
	})

	it("splits the RAI mark across its two brand hues", () => {
		render(
			<h1>
				<MegaMenuHeadingText
					heading={{
						prefix: "Risk Intelligence (",
						highlight: "RAI",
						highlightToken: "rai-split",
						symbol: "™",
						suffix: ")",
					}}
				/>
			</h1>,
		)
		// The mark renders as R + AI, still reading as one word.
		expect(screen.getByRole("heading").textContent).toBe(
			"Risk Intelligence (RAI™)",
		)
		expect(screen.getByText("R")).toBeInTheDocument()
		expect(screen.getByText(/AI/)).toBeInTheDocument()
	})
})
