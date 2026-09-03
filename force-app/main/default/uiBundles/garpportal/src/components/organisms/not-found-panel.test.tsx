import { fireEvent, render, screen } from "@testing-library/react"
import { describe, expect, it, vi } from "vitest"
import type { ReactNode } from "react"

// The panel only needs a link renderer and the history pair from the router —
// mocking them keeps the test free of a full memory-router harness.
const canGoBack = vi.hoisted(() => ({ value: true }))
const historyBack = vi.hoisted(() => vi.fn())
vi.mock("@tanstack/react-router", () => ({
	Link: ({ to, children }: { to: unknown; children: ReactNode }) => (
		<a href={String(to)}>{children}</a>
	),
	useCanGoBack: () => canGoBack.value,
	useRouter: () => ({ history: { back: historyBack } }),
}))

import { NotFoundPanel } from "./not-found-panel"

const STOCK_PALETTE =
	/\b(?:text|bg|border)-(?:slate|gray|zinc|neutral|stone|red|orange|amber|yellow|lime|green|emerald|teal|sky|blue|indigo|violet|purple|fuchsia|rose)-\d{2,3}\b/

describe("NotFoundPanel", () => {
	it("renders the 404 marker, heading, and attempted path", () => {
		render(<NotFoundPanel variant="member" attemptedPath="/nonsense" />)
		expect(screen.getByText("Page not found")).toBeInTheDocument()
		expect(screen.getByText("/nonsense")).toBeInTheDocument()
		// The display "404" is split across spans; the accent digit is present.
		expect(screen.getByText("0")).toBeInTheDocument()
	})

	it("offers the portal ways forward to a member", () => {
		render(<NotFoundPanel variant="member" />)
		expect(
			screen.getByRole("link", { name: "Go to Dashboard" }),
		).toHaveAttribute("href", "/dashboard")
		expect(screen.getByRole("button", { name: "Go back" })).toBeInTheDocument()
		expect(screen.queryByRole("link", { name: /sign in/i })).toBeNull()
	})

	it("walks the history back when Go back is pressed", () => {
		historyBack.mockClear()
		render(<NotFoundPanel variant="member" />)

		fireEvent.click(screen.getByRole("button", { name: "Go back" }))

		expect(historyBack).toHaveBeenCalledTimes(1)
	})

	it("hides Go back when there is no history to go back to", () => {
		canGoBack.value = false
		render(<NotFoundPanel variant="member" />)
		expect(screen.queryByRole("button", { name: "Go back" })).toBeNull()
		canGoBack.value = true
	})

	it("offers Sign In and garp.org to a guest", () => {
		render(<NotFoundPanel variant="guest" />)
		expect(screen.getByRole("link", { name: /sign in/i })).toBeInTheDocument()
		expect(screen.getByRole("link", { name: "Go to garp.org" })).toHaveAttribute(
			"href",
			"https://www.garp.org/",
		)
		expect(screen.queryByRole("link", { name: "Go to Dashboard" })).toBeNull()
	})

	it("uses theme tokens, never the stock Tailwind palette", () => {
		const { container } = render(
			<NotFoundPanel variant="guest" attemptedPath="/x" />,
		)
		expect(container.innerHTML).not.toMatch(STOCK_PALETTE)
	})
})
