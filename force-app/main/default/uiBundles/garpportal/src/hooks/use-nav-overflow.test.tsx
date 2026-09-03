import { act, screen } from "@testing-library/react"
import { afterEach, beforeEach, describe, expect, it } from "vitest"

import { NAV_OVERFLOW_KEY, useNavOverflow } from "@/hooks/use-nav-overflow"
import { renderWithProviders } from "@/testing/render"

/**
 * jsdom lays nothing out, so the geometry is scripted: each element gets its
 * width stamped on via defineProperty, and the global ResizeObserver stub
 * (which never fires) is swapped for a controllable one so a "resize" can be
 * delivered by hand.
 */
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
})

afterEach(() => {
	globalThis.ResizeObserver = originalResizeObserver
})

/** Deliver a resize to every observer (StrictMode mounts more than one). */
function fireResize() {
	act(() => {
		for (const instance of ControllableResizeObserver.instances) instance.fire()
	})
}

function defineWidth(
	el: HTMLElement,
	prop: "clientWidth" | "offsetWidth",
	value: number,
) {
	Object.defineProperty(el, prop, { configurable: true, value })
}

const getKey = (item: string) => item

type HarnessProps = {
	items: string[]
	gapPx?: number
	containerWidth: number
	/** offsetWidth per measuring copy, keyed by item — include NAV_OVERFLOW_KEY. */
	widths: Record<string, number>
}

function Harness({ items, gapPx, containerWidth, widths }: HarnessProps) {
	const { containerRef, registerMeasureRef, ...nav } = useNavOverflow({
		items,
		getKey,
		gapPx,
	})
	return (
		<div>
			<div
				ref={(el) => {
					if (el) defineWidth(el, "clientWidth", containerWidth)
					containerRef.current = el
				}}
			>
				<output data-testid="visible">{nav.visibleItems.join(",")}</output>
				<output data-testid="overflow">{nav.overflowItems.join(",")}</output>
				<output data-testid="has-overflow">{String(nav.hasOverflow)}</output>
			</div>
			<div aria-hidden>
				{[...items, NAV_OVERFLOW_KEY].map((key) => (
					<span
						key={key}
						ref={(el) => {
							if (el) defineWidth(el, "offsetWidth", widths[key] ?? 0)
							registerMeasureRef(key, el)
						}}
					/>
				))}
			</div>
		</div>
	)
}

function readSplit() {
	return {
		visible: screen.getByTestId("visible").textContent,
		overflow: screen.getByTestId("overflow").textContent,
		hasOverflow: screen.getByTestId("has-overflow").textContent,
	}
}

const ITEMS = ["alpha", "beta", "gamma"]
const WIDTHS = { alpha: 100, beta: 100, gamma: 100, [NAV_OVERFLOW_KEY]: 50 }

describe("useNavOverflow", () => {
	it("shows everything when the row fits, gaps included", () => {
		// 3×100 + 2×8 = 316 ≤ 320 — but only because the gaps are counted.
		renderWithProviders(
			<Harness items={ITEMS} gapPx={8} containerWidth={320} widths={WIDTHS} />,
		)
		expect(readSplit()).toEqual({
			visible: "alpha,beta,gamma",
			overflow: "",
			hasOverflow: "false",
		})
	})

	it("collapses the tail into overflow, budgeting for the More trigger and its seam", () => {
		// budget = 250 − 50 (More copy) − 8 (seam gap) = 192: alpha uses 100,
		// beta would need 8 + 100 = 108 more — over budget, so it overflows.
		renderWithProviders(
			<Harness items={ITEMS} gapPx={8} containerWidth={250} widths={WIDTHS} />,
		)
		expect(readSplit()).toEqual({
			visible: "alpha",
			overflow: "beta,gamma",
			hasOverflow: "true",
		})
	})

	it("admits an item that fits the budget exactly, and drops it at one pixel less", () => {
		// budget = 266 − 50 − 8 = 208 = 100 + (8 + 100): beta fits exactly.
		const { rerender } = renderWithProviders(
			<Harness items={ITEMS} gapPx={8} containerWidth={266} widths={WIDTHS} />,
		)
		expect(readSplit().visible).toBe("alpha,beta")

		rerender(
			<Harness items={ITEMS} gapPx={8} containerWidth={265} widths={WIDTHS} />,
		)
		fireResize()
		expect(readSplit().visible).toBe("alpha")
	})

	it("re-splits when the container resizes", () => {
		const { rerender } = renderWithProviders(
			<Harness items={ITEMS} gapPx={8} containerWidth={320} widths={WIDTHS} />,
		)
		expect(readSplit().hasOverflow).toBe("false")

		rerender(
			<Harness items={ITEMS} gapPx={8} containerWidth={250} widths={WIDTHS} />,
		)
		fireResize()
		expect(readSplit()).toEqual({
			visible: "alpha",
			overflow: "beta,gamma",
			hasOverflow: "true",
		})
	})

	it("bails out at zero available width — a hidden toolbar must not collapse into More", () => {
		// The whole row is display:none (clientWidth 0): keep every item visible
		// rather than measuring nothing and folding it all away.
		renderWithProviders(
			<Harness items={ITEMS} gapPx={8} containerWidth={0} widths={WIDTHS} />,
		)
		expect(readSplit()).toEqual({
			visible: "alpha,beta,gamma",
			overflow: "",
			hasOverflow: "false",
		})
	})

	it("bails out while any measuring copy is zero-width, keeping the previous split", () => {
		const { rerender } = renderWithProviders(
			<Harness items={ITEMS} gapPx={8} containerWidth={250} widths={WIDTHS} />,
		)
		expect(readSplit().visible).toBe("alpha")

		// The webfont swap moment: beta measures 0. Do not recompute from it.
		rerender(
			<Harness
				items={ITEMS}
				gapPx={8}
				containerWidth={250}
				widths={{ ...WIDTHS, beta: 0 }}
			/>,
		)
		fireResize()
		expect(readSplit()).toEqual({
			visible: "alpha",
			overflow: "beta,gamma",
			hasOverflow: "true",
		})
	})

	it("re-measures on an items change without waiting for a resize", () => {
		const { rerender } = renderWithProviders(
			<Harness items={ITEMS} gapPx={8} containerWidth={250} widths={WIDTHS} />,
		)
		expect(readSplit().visible).toBe("alpha")

		// Two items fit again (100 + 8 + 100 = 208 ≤ 250) — no fireResize here:
		// the itemsKey change alone must re-run the measurement.
		rerender(
			<Harness
				items={["alpha", "beta"]}
				gapPx={8}
				containerWidth={250}
				widths={WIDTHS}
			/>,
		)
		expect(readSplit()).toEqual({
			visible: "alpha,beta",
			overflow: "",
			hasOverflow: "false",
		})
	})

	it("defaults the gap to zero when the caller declares none", () => {
		// Without gaps 3×100 = 300 ≤ 300; with the default at 8 it would overflow.
		renderWithProviders(
			<Harness items={ITEMS} containerWidth={300} widths={WIDTHS} />,
		)
		expect(readSplit().hasOverflow).toBe("false")
	})
})
