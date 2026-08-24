import { afterAll, beforeAll, beforeEach, describe, expect, it } from "vitest"
import { act, render, screen } from "@testing-library/react"
import { Globals } from "@react-spring/web"

import { BentoDragHandle } from "@/components/molecules/bento-drag-handle"
import { BentoGrid } from "@/components/molecules/bento-grid"
import type { BentoRenderItem } from "@/hooks/use-bento-layout"
import { useBentoLayoutStore } from "@/store/bento-layout-store"

/**
 * Exercises a real gesture through the real `BentoDragHandle` — the layer the
 * pure-logic tests cannot reach.
 *
 * jsdom reports 0 for every offset and has no `PointerEvent`, so two things are
 * substituted: a single-column geometry stub, and touch events (the family
 * `@use-gesture` selects when pointer events are absent). Everything above the
 * DOM event name — the lift, hit-testing, the preview reorder, the ghost and
 * the commit — is the production path.
 */

const SCOPE = "account-information"
const CARD_H = 300
const CARD_W = 600
const GAP = 24
/**
 * One slot's worth of travel, plus enough to clear the hysteresis dead band.
 * Landing exactly on a neighbour's midpoint is deliberately *not* a move — that
 * band is what stops the arrangement strobing when a finger rests on a boundary.
 */
const SLOT = CARD_H + GAP + 60

const ORIGINAL: PropertyDescriptor[] = []

function stubGeometry() {
	const props: Array<[string, (el: HTMLElement) => unknown]> = [
		["offsetParent", (el) => el.parentElement],
		["offsetLeft", () => 0],
		["offsetWidth", () => CARD_W],
		["offsetHeight", () => CARD_H],
		[
			"offsetTop",
			(el) => {
				const siblings = Array.from(el.parentElement?.children ?? []).filter(
					(node) => node.tagName === "DIV",
				)
				const index = siblings.indexOf(el)
				return index < 0 ? 0 : index * (CARD_H + GAP)
			},
		],
	]
	for (const [name, get] of props) {
		const existing = Object.getOwnPropertyDescriptor(
			HTMLElement.prototype,
			name,
		)
		if (existing) ORIGINAL.push({ ...existing, ...{ name } })
		Object.defineProperty(HTMLElement.prototype, name, {
			configurable: true,
			get(this: HTMLElement) {
				return get(this)
			},
		})
	}
}

function touch(target: EventTarget, x: number, y: number) {
	return { identifier: 0, target, clientX: x, clientY: y, pageX: x, pageY: y }
}

function fireTouch(
	target: EventTarget,
	type: "touchstart" | "touchmove" | "touchend",
	x: number,
	y: number,
) {
	const event = new Event(type, { bubbles: true, cancelable: true })
	const list = [touch(target, x, y)]
	Object.assign(event, {
		touches: type === "touchend" ? [] : list,
		targetTouches: type === "touchend" ? [] : list,
		changedTouches: list,
	})
	act(() => {
		target.dispatchEvent(event)
	})
	return event
}

/**
 * react-spring commits values to the DOM through its own rAF frameloop, so a
 * value written during an event handler is not in `style` until a frame runs.
 * `skipAnimation` removes the *animation*, not the flush.
 */
async function flushFrames() {
	await act(async () => {
		await new Promise((resolve) => requestAnimationFrame(() => resolve(null)))
		await new Promise((resolve) => requestAnimationFrame(() => resolve(null)))
	})
}

function items(): BentoRenderItem[] {
	const one = (id: string, label: string): BentoRenderItem => ({
		id,
		label,
		render: ({ handleProps }) => (
			<article data-testid="card">
				<h3>{label}</h3>
				{handleProps ? <BentoDragHandle handleProps={handleProps} /> : null}
			</article>
		),
	})
	return [one("a", "Alpha"), one("b", "Bravo"), one("c", "Charlie")]
}

function renderedOrder() {
	return screen
		.getAllByTestId("card")
		.map((node) => node.querySelector("h3")?.textContent ?? "")
}

function ghost() {
	return document.querySelector<HTMLElement>(
		"[aria-hidden][class*='border-dashed']",
	)
}

describe("BentoGrid pointer drag", () => {
	beforeAll(() => {
		stubGeometry()
		// Springs are rAF-driven, so their values are not observable in the tick
		// after an event. This is the same switch `useReducedMotion()` flips in
		// `pages/__root.tsx`, so it exercises a path production really uses.
		Globals.assign({ skipAnimation: true })
	})
	afterAll(() => {
		Globals.assign({ skipAnimation: false })
		for (const descriptor of ORIGINAL) {
			const { name, ...rest } = descriptor as PropertyDescriptor & {
				name: string
			}
			Object.defineProperty(HTMLElement.prototype, name, rest)
		}
	})

	beforeEach(() => {
		window.localStorage.clear()
		useBentoLayoutStore.setState({ layouts: {} })
	})

	it("lifts the card, proving the gesture survived the press-spring merge", () => {
		render(<BentoGrid scope={SCOPE} items={items()} />)
		const grip = screen.getByRole("button", { name: "Reorder Alpha" })
		expect(grip.dataset.lifted).toBe("false")

		fireTouch(grip, "touchstart", 10, 10)
		fireTouch(window, "touchmove", 10, 60)
		// Only reachable if the gesture handler ran — a plain spread would have
		// let the press spring clobber it and this would still read "false".
		expect(grip.dataset.lifted).toBe("true")

		fireTouch(window, "touchend", 10, 60)
		expect(grip.dataset.lifted).toBe("false")
	})

	it("shows the placeholder on pickup and hides it on drop", () => {
		render(<BentoGrid scope={SCOPE} items={items()} />)
		const grip = screen.getByRole("button", { name: "Reorder Alpha" })

		expect(ghost()).toBeTruthy()
		expect(ghost()?.style.opacity).toBe("0")

		fireTouch(grip, "touchstart", 10, 10)
		fireTouch(window, "touchmove", 10, 40)
		expect(ghost()?.style.opacity).toBe("1")
		// Sized to the slot it would land in, not left at zero.
		expect(ghost()?.style.width).toBe(`${CARD_W}px`)
		expect(ghost()?.style.height).toBe(`${CARD_H}px`)

		fireTouch(window, "touchend", 10, 40)
		expect(ghost()?.style.opacity).toBe("0")
	})

	it("reorders by dragging a card down past its neighbour, and persists it", () => {
		render(<BentoGrid scope={SCOPE} items={items()} />)
		expect(renderedOrder()).toEqual(["Alpha", "Bravo", "Charlie"])

		const grip = screen.getByRole("button", { name: "Reorder Alpha" })
		fireTouch(grip, "touchstart", 10, 10)
		// Far enough that Alpha's centroid lands squarely inside Bravo's slot.
		fireTouch(window, "touchmove", 10, 10 + SLOT)
		expect(renderedOrder()).toEqual(["Bravo", "Alpha", "Charlie"])

		fireTouch(window, "touchend", 10, 10 + SLOT)
		expect(renderedOrder()).toEqual(["Bravo", "Alpha", "Charlie"])
		expect(
			useBentoLayoutStore.getState().layouts[SCOPE]?.columns?.["1"]?.[0],
		).toEqual(["b", "a", "c"])
	})
})

/**
 * The defect this suite exists for: springs were allocated per SLOT, while the
 * lift (scale / shadow / tilt) is per CARD. One preview reorder re-pointed a
 * card at another card's spring, so the neighbour inherited the lift and kept
 * it — and nothing ever cleaned up a slot the dragged card had left.
 */
describe("BentoGrid identity invariant", () => {
	beforeAll(() => {
		stubGeometry()
		Globals.assign({ skipAnimation: true })
	})
	afterAll(() => {
		Globals.assign({ skipAnimation: false })
		for (const descriptor of ORIGINAL) {
			const { name, ...rest } = descriptor as PropertyDescriptor & {
				name: string
			}
			Object.defineProperty(HTMLElement.prototype, name, rest)
		}
	})

	beforeEach(() => {
		window.localStorage.clear()
		useBentoLayoutStore.setState({ layouts: {} })
	})

	function wrappers() {
		return screen
			.getAllByTestId("card")
			.map((node) => node.parentElement as HTMLElement)
	}

	function scaleOf(el: HTMLElement) {
		return Number(/scale\(([\d.]+)\)/.exec(el.style.transform)?.[1] ?? "1")
	}

	function shadowAlphaOf(el: HTMLElement) {
		return Number(
			/rgb\(0 0 0 \/ ([\d.]+)\)/.exec(el.style.boxShadow)?.[1] ?? "0",
		)
	}

	it("leaves every card at rest after a drag across two slots", async () => {
		render(<BentoGrid scope={SCOPE} items={items()} />)
		const grip = screen.getByRole("button", { name: "Reorder Alpha" })

		fireTouch(grip, "touchstart", 10, 10)
		// Cross Bravo...
		fireTouch(window, "touchmove", 10, 10 + SLOT)
		// ...and on into Charlie's slot, so Alpha has passed through two springs.
		fireTouch(window, "touchmove", 10, 10 + 2 * SLOT)
		expect(renderedOrder()).toEqual(["Bravo", "Charlie", "Alpha"])

		fireTouch(window, "touchend", 10, 10 + 2 * SLOT)
		await flushFrames()

		for (const el of wrappers()) {
			const label = el.querySelector("h3")?.textContent
			expect(scaleOf(el), `${label} scale`).toBe(1)
			expect(shadowAlphaOf(el), `${label} shadow`).toBe(0)
			expect(el.style.transform, `${label} transform`).not.toMatch(
				/rotateZ\((?!0\))/,
			)
		}
	})

	it("keeps the lift on the dragged card, and only that card, mid-drag", () => {
		render(<BentoGrid scope={SCOPE} items={items()} />)
		const grip = screen.getByRole("button", { name: "Reorder Alpha" })

		fireTouch(grip, "touchstart", 10, 10)
		fireTouch(window, "touchmove", 10, 10 + SLOT)

		for (const el of wrappers()) {
			const label = el.querySelector("h3")?.textContent
			const lifted = label === "Alpha"
			expect(scaleOf(el) > 1, `${label} lifted?`).toBe(lifted)
			expect(shadowAlphaOf(el) > 0, `${label} shadowed?`).toBe(lifted)
		}

		fireTouch(window, "touchend", 10, 10 + SLOT)
	})
})

describe("BentoGrid pointer cancel", () => {
	beforeAll(() => {
		stubGeometry()
		Globals.assign({ skipAnimation: true })
	})
	afterAll(() => {
		Globals.assign({ skipAnimation: false })
		for (const descriptor of ORIGINAL) {
			const { name, ...rest } = descriptor as PropertyDescriptor & {
				name: string
			}
			Object.defineProperty(HTMLElement.prototype, name, rest)
		}
	})

	beforeEach(() => {
		window.localStorage.clear()
		useBentoLayoutStore.setState({ layouts: {} })
	})

	it("abandons a pointer drag on Escape and persists nothing", () => {
		render(<BentoGrid scope={SCOPE} items={items()} />)
		const grip = screen.getByRole("button", { name: "Reorder Alpha" })

		fireTouch(grip, "touchstart", 10, 10)
		fireTouch(window, "touchmove", 10, 10 + SLOT)
		expect(renderedOrder()).toEqual(["Bravo", "Alpha", "Charlie"])

		act(() => {
			window.dispatchEvent(
				new KeyboardEvent("keydown", { key: "Escape", bubbles: true }),
			)
		})

		expect(renderedOrder()).toEqual(["Alpha", "Bravo", "Charlie"])
		expect(useBentoLayoutStore.getState().layouts[SCOPE]).toBeUndefined()

		// The gesture's own end event must not then commit anything.
		fireTouch(window, "touchend", 10, 10 + SLOT)
		expect(renderedOrder()).toEqual(["Alpha", "Bravo", "Charlie"])
		expect(useBentoLayoutStore.getState().layouts[SCOPE]).toBeUndefined()
	})
})
