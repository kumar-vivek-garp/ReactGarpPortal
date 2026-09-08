import { act, screen, waitFor } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest"

import { FooterBackToTop } from "@/components/molecules/footer-back-to-top"
import { APP_SCROLL_ID } from "@/lib/app-scroll"
import { renderWithProviders } from "@/testing/render"

const realMatchMedia = window.matchMedia
let scroller: HTMLElement

/*
 * The button reads and drives the shell's scroller, not the window — so the
 * test has to stand one up. jsdom never lays anything out, so the three
 * geometry properties are defined by hand; `scrollTop` has to be writable
 * because the component assigns to it, which is the whole behaviour under test.
 */
beforeEach(() => {
	scroller = document.createElement("div")
	scroller.id = APP_SCROLL_ID
	Object.defineProperty(scroller, "scrollHeight", {
		configurable: true,
		value: 2000,
	})
	Object.defineProperty(scroller, "clientHeight", {
		configurable: true,
		value: 800,
	})
	Object.defineProperty(scroller, "scrollTop", {
		configurable: true,
		writable: true,
		value: 0,
	})
	document.body.append(scroller)
})

afterEach(() => {
	scroller.remove()
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

/** Places the scroll position and lets the component hear about it. */
function setScroll(y: number) {
	scroller.scrollTop = y
	act(() => {
		scroller.dispatchEvent(new Event("scroll"))
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
		const user = userEvent.setup()
		renderWithProviders(<FooterBackToTop />)
		setScroll(600)

		await user.click(button())
		expect(scroller.scrollTop).toBe(0)
	})

	it("does nothing at all when already at the top", async () => {
		pretendReducedMotion()
		const user = userEvent.setup()
		renderWithProviders(<FooterBackToTop />)

		// Visible from an earlier position, but the offset is back at 0 by click
		// time — the browser scrolled without another scroll event landing yet.
		setScroll(600)
		scroller.scrollTop = 0
		const scrolled = vi.fn()
		Object.defineProperty(scroller, "scrollTop", {
			configurable: true,
			get: () => 0,
			set: scrolled,
		})

		await user.click(button())
		expect(scrolled).not.toHaveBeenCalled()
	})

	it("glides via the spring otherwise, and a wheel can interrupt it", async () => {
		const user = userEvent.setup()
		renderWithProviders(<FooterBackToTop />)
		setScroll(600)

		const written: number[] = []
		Object.defineProperty(scroller, "scrollTop", {
			configurable: true,
			get: () => (written.length ? written[written.length - 1] : 600),
			set: (value: number) => {
				written.push(value)
			},
		})

		await user.click(button())
		// The spring drives the scroller frame by frame towards 0.
		await waitFor(() => expect(written.length).toBeGreaterThan(0))
		expect(written[0]).toBeLessThanOrEqual(600)

		// A wheel gesture takes the scroll back without error.
		act(() => {
			window.dispatchEvent(new Event("wheel"))
		})
	})
})
