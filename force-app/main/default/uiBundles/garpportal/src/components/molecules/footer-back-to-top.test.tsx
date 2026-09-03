import { act, screen, waitFor } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { afterEach, describe, expect, it, vi } from "vitest"

import { FooterBackToTop } from "@/components/molecules/footer-back-to-top"
import { renderWithProviders } from "@/testing/render"

const realMatchMedia = window.matchMedia

afterEach(() => {
	window.matchMedia = realMatchMedia
	vi.restoreAllMocks()
})

function pretendReducedMotion() {
	window.matchMedia = ((query: string) => ({
		matches: query === "(prefers-reduced-motion: reduce)",
		media: query,
		onchange: null,
		addListener: () => undefined,
		removeListener: () => undefined,
		addEventListener: () => undefined,
		removeEventListener: () => undefined,
	})) as unknown as typeof window.matchMedia
}

/** Gives the page a scrollable height and places the scroll position. */
function setScroll(y: number, { pageHeight = 2000, viewport = 800 } = {}) {
	Object.defineProperty(window, "scrollY", { configurable: true, value: y })
	Object.defineProperty(window, "innerHeight", {
		configurable: true,
		value: viewport,
	})
	Object.defineProperty(document.documentElement, "scrollHeight", {
		configurable: true,
		value: pageHeight,
	})
	act(() => {
		window.dispatchEvent(new Event("scroll"))
	})
}

// The shell hides via aria-hidden, so the button must be queried as hidden too.
const button = () =>
	screen.getByRole("button", { name: /Back to top/, hidden: true })

describe("the visibility threshold", () => {
	it("stays out of reach until the page has scrolled past it", () => {
		renderWithProviders(<FooterBackToTop />)
		expect(button()).toHaveAttribute("tabindex", "-1")

		setScroll(280)
		expect(button()).toHaveAttribute("tabindex", "-1")

		setScroll(281)
		expect(button()).toHaveAttribute("tabindex", "0")
		expect(screen.getByRole("button", { name: /Back to top/ })).toBeInTheDocument()

		setScroll(0)
		expect(button()).toHaveAttribute("tabindex", "-1")
	})
})

describe("clicking", () => {
	it("jumps straight to the top under reduced motion", async () => {
		pretendReducedMotion()
		const scrollTo = vi.spyOn(window, "scrollTo")
		const user = userEvent.setup()
		renderWithProviders(<FooterBackToTop />)
		setScroll(600)

		await user.click(button())
		expect(scrollTo).toHaveBeenCalledExactlyOnceWith(0, 0)
	})

	it("does nothing at all when already at the top", async () => {
		pretendReducedMotion()
		const scrollTo = vi.spyOn(window, "scrollTo")
		const user = userEvent.setup()
		renderWithProviders(<FooterBackToTop />)

		// Visible from an earlier position, but scrollY is back at 0 by click
		// time — the browser scrolled without another scroll event landing yet.
		setScroll(600)
		Object.defineProperty(window, "scrollY", { configurable: true, value: 0 })
		await user.click(button())
		expect(scrollTo).not.toHaveBeenCalled()
	})

	it("glides via the spring otherwise, and a wheel can interrupt it", async () => {
		const scrollTo = vi.spyOn(window, "scrollTo")
		const user = userEvent.setup()
		renderWithProviders(<FooterBackToTop />)
		setScroll(600)

		await user.click(button())
		// The spring drives window.scrollTo frame by frame towards 0.
		await waitFor(() => expect(scrollTo).toHaveBeenCalled())
		const [, firstY] = scrollTo.mock.calls[0] as [number, number]
		expect(firstY).toBeLessThanOrEqual(600)

		// A wheel gesture takes the scroll back without error.
		act(() => {
			window.dispatchEvent(new Event("wheel"))
		})
	})
})
