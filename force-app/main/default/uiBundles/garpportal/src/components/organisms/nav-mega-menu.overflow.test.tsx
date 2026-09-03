import { act, screen } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { afterEach, beforeEach, describe, expect, it } from "vitest"

import { NavMegaMenu } from "@/components/organisms/nav-mega-menu"
import { useNavigationStore } from "@/store/navigation-store"
import { renderWithRouterProviders } from "@/testing/router"
import { skipSpringAnimations } from "@/testing/springs"

/**
 * jsdom lays nothing out, so the geometry is scripted per the
 * use-nav-overflow precedent: widths stamped via defineProperty, the global
 * ResizeObserver stub swapped for a controllable one so "resizes" can be
 * delivered by hand. Springs settle instantly (no useSubpageTransition here).
 */
skipSpringAnimations()

class ControllableResizeObserver {
	static instances: ControllableResizeObserver[] = []
	private readonly callback: ResizeObserverCallback
	constructor(callback: ResizeObserverCallback) {
		this.callback = callback
		ControllableResizeObserver.instances.push(this)
	}
	observe() {}
	unobserve() {}
	disconnect() {}
	fire() {
		this.callback([], this as unknown as ResizeObserver)
	}
}

let originalResizeObserver: typeof ResizeObserver

beforeEach(() => {
	originalResizeObserver = globalThis.ResizeObserver
	ControllableResizeObserver.instances = []
	globalThis.ResizeObserver =
		ControllableResizeObserver as unknown as typeof ResizeObserver
	useNavigationStore.setState({
		openDesktopNavTitle: null,
		desktopMoreDrillTitle: null,
		isMobileNavOpen: false,
		mobileSelectedNavItem: null,
	})
})

afterEach(() => {
	globalThis.ResizeObserver = originalResizeObserver
})

function fireResize() {
	act(() => {
		for (const instance of ControllableResizeObserver.instances) instance.fire()
	})
}

function defineSize(el: Element, prop: string, value: number) {
	Object.defineProperty(el, prop, { configurable: true, value })
}

/**
 * Stamp a 400px row whose seven measuring copies (six items + More) are
 * 100/60px wide: budget 400 − 60 − 6 = 334 fits exactly three items, so
 * Membership, Insights & Events and About Us collapse into "More".
 */
function stampOverflowGeometry() {
	const row = screen.getByRole("navigation", { name: "Primary" }).parentElement
	if (!row) throw new Error("nav row not rendered")
	defineSize(row, "clientWidth", 400)
	const copies = row.querySelectorAll('div[aria-hidden="true"] button')
	if (copies.length === 0) throw new Error("measuring copies not rendered")
	for (const copy of copies) {
		defineSize(copy, "offsetWidth", copy.textContent === "More" ? 60 : 100)
	}
	fireResize()
}

async function renderOverflowing() {
	const rendered = await renderWithRouterProviders(<NavMegaMenu />)
	stampOverflowGeometry()
	return rendered
}

describe("NavMegaMenu — overflow into More", () => {
	it("collapses the items that no longer fit into a More trigger", async () => {
		await renderOverflowing()

		for (const title of ["FRM", "SCR", "Risk & AI", "More"]) {
			expect(screen.getByRole("button", { name: title })).toBeInTheDocument()
		}
		// Collapsed items keep only their aria-hidden measuring copies.
		for (const title of ["Membership", "Insights & Events", "About Us"]) {
			expect(
				screen.queryByRole("button", { name: title }),
			).not.toBeInTheDocument()
		}
	})

	it("drills from the More list into an item's panel and back out", async () => {
		const user = userEvent.setup()
		await renderOverflowing()

		await user.click(screen.getByRole("button", { name: "More" }))

		// The root layer lists the collapsed items.
		const membership = await screen.findByRole("button", {
			name: "Membership",
		})
		expect(
			screen.getByRole("button", { name: "About Us" }),
		).toBeInTheDocument()

		await user.click(membership)
		expect(
			useNavigationStore.getState().desktopMoreDrillTitle,
		).toBe("Membership")
		expect(
			await screen.findByRole("link", { name: "Professional Chapters" }),
		).toBeInTheDocument()

		// Back returns to the overflow root and clears the drill. Two buttons
		// are named "More" now — the row trigger and the panel's back control;
		// only the trigger declares a popup.
		const back = screen
			.getAllByRole("button", { name: "More" })
			.find((el) => !el.hasAttribute("aria-haspopup"))
		await user.click(back as HTMLElement)
		expect(useNavigationStore.getState().desktopMoreDrillTitle).toBeNull()
		expect(
			await screen.findByRole("button", { name: "Membership" }),
		).toBeInTheDocument()
	})

	it("clears the drill when More closes, so it reopens on the root list", async () => {
		const user = userEvent.setup()
		await renderOverflowing()

		const moreTrigger = () =>
			screen
				.getAllByRole("button", { name: "More" })
				.find((el) => el.getAttribute("aria-haspopup") === "menu")

		await user.click(moreTrigger() as HTMLElement)
		await user.click(await screen.findByRole("button", { name: "Membership" }))
		expect(
			useNavigationStore.getState().desktopMoreDrillTitle,
		).toBe("Membership")

		// Close via the trigger; the drill must not survive.
		await user.click(moreTrigger() as HTMLElement)
		expect(useNavigationStore.getState().openDesktopNavTitle).toBeNull()
		expect(useNavigationStore.getState().desktopMoreDrillTitle).toBeNull()
	})
})

describe("NavMegaMenu — measured panel geometry", () => {
	it("sizes the surface from the invisible copy and clamps the caret to the corner clearance", async () => {
		const user = userEvent.setup()
		await renderWithRouterProviders(<NavMegaMenu />)

		// The always-mounted natural-size copy drives the width/height springs.
		const measure = document.querySelector(
			'div[aria-hidden="true"].invisible.fixed',
		)
		if (!measure) throw new Error("measuring copy not rendered")
		defineSize(measure, "offsetWidth", 500)
		defineSize(measure, "offsetHeight", 300)
		// Deliver the "content resized" signal before opening, the order the
		// real observer produces — the copy is always mounted and measured
		// ahead of the panel, so the first placement already knows the size.
		fireResize()

		await user.click(screen.getByRole("button", { name: "FRM" }))

		const trigger = screen.getByRole("button", { name: "FRM" })
		const panelId = trigger.getAttribute("aria-controls")
		const panel = panelId ? document.getElementById(panelId) : null
		if (!panel) throw new Error("panel not rendered")

		const surface = panel.querySelector<HTMLElement>(
			".origin-top.overflow-hidden",
		)
		// The surface takes the copy's natural size…
		expect(surface?.style.width).toBe("500px")
		expect(surface?.style.height).toBe("300px")
		// …the wrapper is pushed off the left viewport gutter (trigger rect is
		// all zeros in jsdom, so the 20px gutter clamp wins)…
		const wrapper = surface?.parentElement as HTMLElement
		expect(wrapper.style.transform).toBe("translateX(20px)")
		// …and the caret can never reach the rounded corner (18px clearance).
		const caret = panel.querySelector<HTMLElement>('span[aria-hidden="true"]')
		expect(caret?.style.left).toBe("18px")
	})
})
