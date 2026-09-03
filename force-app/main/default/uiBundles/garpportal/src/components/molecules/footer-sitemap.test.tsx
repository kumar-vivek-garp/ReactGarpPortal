import { screen, within } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { afterEach, describe, expect, it } from "vitest"

import { FooterSitemap } from "@/components/molecules/footer-sitemap"
import type { FooterNavSection } from "@/config/navigation/types"
import { renderWithProviders } from "@/testing/render"

const SECTIONS: FooterNavSection[] = [
	{
		key: "frm",
		label: "FRM",
		accentToken: "garp-cyan",
		links: [
			{ title: "About the FRM", url: "https://www.garp.org/frm" },
			{ title: "Study Materials", url: "https://www.garp.org/frm/study" },
		],
	},
	{
		key: "membership",
		label: "Membership",
		accentToken: "garp-saffron",
		links: [{ title: "Join GARP", url: "https://www.garp.org/membership" }],
	},
]

const realMatchMedia = window.matchMedia
afterEach(() => {
	window.matchMedia = realMatchMedia
})

/** The vitest.setup stub answers false to everything — that IS mobile. */
function pretendDesktop() {
	window.matchMedia = ((query: string) => ({
		matches: query === "(min-width: 64rem)",
		media: query,
		onchange: null,
		addListener: () => undefined,
		removeListener: () => undefined,
		addEventListener: () => undefined,
		removeEventListener: () => undefined,
		dispatchEvent: () => false,
	})) as unknown as typeof window.matchMedia
}

const trigger = () =>
	screen.getByRole("button", { name: /Site map|Hide site map/ })

describe("the one disclosure", () => {
	it("opens and closes from the pill, relabelling as it goes", async () => {
		const user = userEvent.setup()
		renderWithProviders(<FooterSitemap sections={SECTIONS} />)

		expect(trigger()).toHaveTextContent("Site map")
		expect(trigger()).toHaveAttribute("aria-expanded", "false")
		expect(trigger()).toHaveAttribute(
			"aria-controls",
			"footer-sitemap-content",
		)

		await user.click(trigger())
		expect(trigger()).toHaveTextContent("Hide site map")
		expect(trigger()).toHaveAttribute("aria-expanded", "true")

		await user.click(trigger())
		expect(trigger()).toHaveTextContent("Site map")
		expect(trigger()).toHaveAttribute("aria-expanded", "false")
	})

	it("places the trigger through the caller's bar when one is given", () => {
		renderWithProviders(
			<FooterSitemap
				sections={SECTIONS}
				renderBar={(pill) => <div role="contentinfo">{pill}</div>}
			/>,
		)
		expect(
			within(screen.getByRole("contentinfo")).getByRole("button", {
				name: "Site map",
			}),
		).toBeInTheDocument()
	})
})

describe("below lg — the accordion", () => {
	it("gives every section its own collapsible card", async () => {
		const user = userEvent.setup()
		renderWithProviders(<FooterSitemap sections={SECTIONS} />)

		const frm = screen.getByRole("button", { name: "FRM" })
		expect(frm).toHaveAttribute("aria-expanded", "false")
		expect(frm).toHaveAttribute("aria-controls", "footer-section-frm")

		await user.click(frm)
		expect(frm).toHaveAttribute("aria-expanded", "true")
		// The other card keeps its own state.
		expect(screen.getByRole("button", { name: "Membership" })).toHaveAttribute(
			"aria-expanded",
			"false",
		)

		await user.click(frm)
		expect(frm).toHaveAttribute("aria-expanded", "false")
	})

	it("keeps every link in the DOM, one interaction away", () => {
		renderWithProviders(<FooterSitemap sections={SECTIONS} />)
		const nav = screen.getByRole("navigation", { name: "Site map" })
		expect(within(nav).getByRole("link", { name: "Join GARP" })).toHaveAttribute(
			"href",
			"https://www.garp.org/membership",
		)
	})
})

describe("at lg — the columns", () => {
	it("lays the sections out as headed columns with no per-section buttons", () => {
		pretendDesktop()
		renderWithProviders(<FooterSitemap sections={SECTIONS} />)

		const nav = screen.getByRole("navigation", { name: "Site map" })
		expect(
			within(nav).getByRole("heading", { level: 3, name: "FRM" }),
		).toBeInTheDocument()
		expect(
			within(nav).getByRole("heading", { level: 3, name: "Membership" }),
		).toBeInTheDocument()
		expect(within(nav).queryByRole("button")).not.toBeInTheDocument()
		expect(
			within(nav).getByRole("link", { name: "About the FRM" }),
		).toHaveAttribute("href", "https://www.garp.org/frm")
	})
})
