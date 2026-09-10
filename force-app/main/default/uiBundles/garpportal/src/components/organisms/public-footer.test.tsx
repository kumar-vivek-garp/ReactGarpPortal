import { screen } from "@testing-library/react"
import { describe, expect, it } from "vitest"

import {
	FOOTER_COPYRIGHT,
	FOOTER_LEGAL_LINKS,
	FOOTER_TAGLINE,
} from "@/config/navigation/footer-misc-links"
import { renderWithProviders } from "@/testing/render"

import { PublicFooter } from "./public-footer"

describe("PublicFooter", () => {
	it("carries the brand, tagline and every legal link", () => {
		renderWithProviders(<PublicFooter />)

		expect(screen.getByRole("contentinfo")).toBeInTheDocument()
		expect(screen.getByRole("img", { name: "GARP" })).toBeInTheDocument()
		expect(screen.getByText(FOOTER_TAGLINE)).toBeInTheDocument()
		expect(screen.getByText(FOOTER_COPYRIGHT)).toBeInTheDocument()

		for (const link of FOOTER_LEGAL_LINKS) {
			expect(screen.getByRole("link", { name: link.title })).toHaveAttribute(
				"href",
				link.url,
			)
		}
	})

	/*
	 * The point of this footer is what it leaves out. It sits under a checkout,
	 * and the portal footer's sitemap, contact link and social row are each a
	 * way to abandon one half-finished — so a well-meaning "restore parity"
	 * change here would undo the design decision.
	 */
	it("omits the portal footer's sitemap, contact and social rows", () => {
		renderWithProviders(<PublicFooter />)

		expect(
			screen.queryByRole("link", { name: /Contact Us/ }),
		).not.toBeInTheDocument()
		expect(
			screen.queryByRole("button", { name: /sitemap/i }),
		).not.toBeInTheDocument()
		expect(
			screen.queryByRole("link", { name: /LinkedIn/i }),
		).not.toBeInTheDocument()
	})
})
