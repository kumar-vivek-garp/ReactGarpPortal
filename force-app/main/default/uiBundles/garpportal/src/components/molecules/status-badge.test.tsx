import { render, screen } from "@testing-library/react"
import { describe, expect, it } from "vitest"

import { MetaLines } from "./meta-lines"
import { StatusBadge } from "./status-badge"

/**
 * These two now back programs, study materials, events, membership and order
 * history. The assertions pin the theming contract — every tone must resolve to
 * `--color-*` token utilities, never a stock Tailwind palette class, which is
 * exactly the violation this shared pair was introduced to remove.
 */

const STOCK_PALETTE =
	/\b(?:text|bg|border)-(?:slate|gray|zinc|neutral|stone|red|orange|amber|yellow|lime|green|emerald|teal|sky|blue|indigo|violet|purple|fuchsia|rose)-\d{2,3}\b/

describe("StatusBadge", () => {
	it("renders the label", () => {
		render(<StatusBadge label="Registration open" tone="success" />)
		expect(screen.getByText("Registration open")).toBeInTheDocument()
	})

	it("maps every tone to token-based classes and never a stock palette", () => {
		const tones = ["neutral", "info", "success", "warning", "danger"] as const
		for (const tone of tones) {
			const { container, unmount } = render(
				<StatusBadge label={tone} tone={tone} />,
			)
			const badge = container.querySelector('[data-slot="badge"]')
			expect(badge, tone).not.toBeNull()
			expect(badge!.className, tone).not.toMatch(STOCK_PALETTE)
			unmount()
		}
	})

	it("pairs brand tones with their declared foreground token", () => {
		const { container } = render(<StatusBadge label="Warn" tone="warning" />)
		const cls = container.querySelector('[data-slot="badge"]')!.className
		// theming.md: a brand swatch must use its `-foreground` partner, not white/black.
		expect(cls).toContain("bg-light-yellow")
		expect(cls).toContain("text-light-yellow-foreground")
	})
})

describe("MetaLines", () => {
	it("renders nothing when there are no lines", () => {
		const { container } = render(<MetaLines lines={[]} />)
		expect(container).toBeEmptyDOMElement()
	})

	it("renders one row per line with an icon", () => {
		const { container } = render(
			<MetaLines
				lines={[
					{ icon: "administration", text: "November 2026" },
					{ icon: "location", text: "Budapest" },
				]}
			/>,
		)
		const rows = container.querySelectorAll("li")
		expect(rows).toHaveLength(2)
		expect(screen.getByText("November 2026")).toBeInTheDocument()
		expect(screen.getByText("Budapest")).toBeInTheDocument()
		for (const row of rows) {
			expect(row.querySelector("svg")).not.toBeNull()
		}
	})

	it("tones warning icons differently from informational ones", () => {
		const { container } = render(
			<MetaLines
				lines={[
					{ icon: "administration", text: "info" },
					{ icon: "unavailable", text: "warn" },
				]}
			/>,
		)
		const [info, warn] = [...container.querySelectorAll("li svg")]
		expect(info.getAttribute("class")).toContain("text-primary")
		expect(warn.getAttribute("class")).toContain("text-light-yellow-foreground")
	})

	it("uses no stock palette classes", () => {
		const { container } = render(
			<MetaLines lines={[{ icon: "expiringSoon", text: "soon" }]} />,
		)
		expect(container.innerHTML).not.toMatch(STOCK_PALETTE)
	})
})
