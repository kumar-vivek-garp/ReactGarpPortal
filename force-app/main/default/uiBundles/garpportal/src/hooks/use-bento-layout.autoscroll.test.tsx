import { act, render, screen } from "@testing-library/react"
import { afterEach, beforeEach, describe, expect, it } from "vitest"

import { BentoGrid } from "@/components/molecules/bento-grid"
import type { BentoRenderItem } from "@/hooks/use-bento-layout"
import { useBentoLayoutStore } from "@/store/bento-layout-store"
import { stubBentoGeometry } from "@/testing/bento-geometry"
import { skipSpringAnimations } from "@/testing/springs"

/**
 * The auto-scroll frame loop, with `requestAnimationFrame` replaced by a hand
 * pump so each frame runs with a chosen timestamp: speed is a rate, the first
 * frame only seeds the clock, and the loop stops at the band edge, at the
 * scroll extents, and on release. Cards are 300×600 with a 24px gap; the panel
 * shows 768px of a 2000px scroll, so its bottom band starts at 696.
 */

const SCOPE = "account-information"
const SCROLL_HEIGHT = 2000
const CLIENT_HEIGHT = 768
/** 900px/s × the (760 − 696)/72 band factor. */
const SPEED = 800
const PER_FRAME = SPEED * 0.016

stubBentoGeometry()
skipSpringAnimations()

const rafQueue = new Map<number, FrameRequestCallback>()
let rafSeq = 0
let originalRaf: typeof window.requestAnimationFrame
let originalCancel: typeof window.cancelAnimationFrame

beforeEach(() => {
	window.localStorage.clear()
	useBentoLayoutStore.setState({ layouts: {} })
	rafQueue.clear()
	originalRaf = window.requestAnimationFrame
	originalCancel = window.cancelAnimationFrame
	window.requestAnimationFrame = ((callback: FrameRequestCallback) => {
		rafSeq += 1
		rafQueue.set(rafSeq, callback)
		return rafSeq
	}) as typeof window.requestAnimationFrame
	window.cancelAnimationFrame = ((id: number) => {
		rafQueue.delete(id)
	}) as typeof window.cancelAnimationFrame
})

afterEach(() => {
	window.requestAnimationFrame = originalRaf
	window.cancelAnimationFrame = originalCancel
})

function runFrame(now: number) {
	const callbacks = [...rafQueue.values()]
	rafQueue.clear()
	act(() => {
		for (const callback of callbacks) callback(now)
	})
}

function runFrames(from: number, count: number) {
	for (let frame = 1; frame <= count; frame += 1) runFrame(from + frame * 16)
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
}

function items(): BentoRenderItem[] {
	const one = (id: string, label: string): BentoRenderItem => ({
		id,
		label,
		render: ({ handleProps }) => (
			<article data-testid="card">
				<h3>{label}</h3>
				{handleProps ? <button {...handleProps}>Reorder {label}</button> : null}
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

/** An `overflow-y: auto` panel the drag's `scrollParent` lookup resolves to. */
function renderInScroller(rect?: { top: number; bottom: number }) {
	const { top = 0, bottom = CLIENT_HEIGHT } = rect ?? {}
	render(
		<div
			data-testid="scroller"
			ref={(el) => {
				if (!el) return
				el.style.overflowY = "auto"
				let scrollTop = 0
				Object.defineProperty(el, "scrollHeight", {
					configurable: true,
					value: SCROLL_HEIGHT,
				})
				Object.defineProperty(el, "clientHeight", {
					configurable: true,
					value: CLIENT_HEIGHT,
				})
				Object.defineProperty(el, "scrollTop", {
					configurable: true,
					get: () => scrollTop,
					set: (value: number) => {
						scrollTop = value
					},
				})
				el.getBoundingClientRect = () =>
					({
						top,
						bottom,
						left: 0,
						right: 800,
						width: 800,
						height: bottom - top,
						x: 0,
						y: top,
						toJSON: () => ({}),
					}) as DOMRect
			}}
		>
			<BentoGrid scope={SCOPE} items={items()} reveal={false} />
		</div>,
	)
	return screen.getByTestId("scroller")
}

function grip(label: string) {
	return screen.getByRole("button", { name: `Reorder ${label}` })
}

describe("auto-scroll in the bottom band", () => {
	it("keeps scrolling while the finger holds still, and the reorder follows", () => {
		const scroller = renderInScroller()
		fireTouch(grip("Alpha"), "touchstart", 10, 700)
		fireTouch(window, "touchmove", 10, 760)
		expect(renderedOrder()).toEqual(["Alpha", "Bravo", "Charlie"])

		// The first frame only seeds the clock — no scroll yet.
		runFrame(1000)
		expect(scroller.scrollTop).toBe(0)

		// 30 × 16ms at 800px/s ≈ 384px, enough to carry Alpha past Bravo
		// with no further pointer movement at all.
		runFrames(1000, 30)
		expect(scroller.scrollTop).toBeCloseTo(30 * PER_FRAME, 0)
		expect(renderedOrder()).toEqual(["Bravo", "Alpha", "Charlie"])

		// Release commits the auto-scrolled slot and parks the loop.
		fireTouch(window, "touchend", 10, 760)
		expect(
			useBentoLayoutStore.getState().layouts[SCOPE]?.columns?.["1"],
		).toEqual([["b", "a", "c"]])
		const settled = scroller.scrollTop
		runFrames(3000, 5)
		expect(scroller.scrollTop).toBe(settled)
	})

	it("clamps a long frame gap so a backgrounded tab cannot jump", () => {
		const scroller = renderInScroller()
		fireTouch(grip("Alpha"), "touchstart", 10, 700)
		fireTouch(window, "touchmove", 10, 760)

		runFrame(1000)
		runFrame(51_000) // 50s later — dt clamps to 0.05s.
		expect(scroller.scrollTop).toBeCloseTo(SPEED * 0.05, 0)
	})

	it("stops outside the band and resumes when the finger re-enters it", () => {
		const scroller = renderInScroller()
		fireTouch(grip("Alpha"), "touchstart", 10, 700)
		fireTouch(window, "touchmove", 10, 760)
		runFrame(1000)
		runFrames(1000, 5)
		const paused = scroller.scrollTop
		expect(paused).toBeCloseTo(5 * PER_FRAME, 0)

		fireTouch(window, "touchmove", 10, 400)
		runFrames(2000, 5)
		expect(scroller.scrollTop).toBe(paused)

		fireTouch(window, "touchmove", 10, 760)
		runFrame(10_000)
		runFrames(10_000, 5)
		expect(scroller.scrollTop).toBeCloseTo(paused + 5 * PER_FRAME, 0)
	})

	it("stops dead when already hard against the bottom", () => {
		const scroller = renderInScroller()
		scroller.scrollTop = SCROLL_HEIGHT - CLIENT_HEIGHT
		fireTouch(grip("Alpha"), "touchstart", 10, 700)
		fireTouch(window, "touchmove", 10, 760)

		runFrame(1000)
		runFrames(1000, 3)
		expect(scroller.scrollTop).toBe(SCROLL_HEIGHT - CLIENT_HEIGHT)
	})
})

describe("auto-scroll in the top band", () => {
	it("scrolls up, clamps at zero, then stops", () => {
		const scroller = renderInScroller()
		scroller.scrollTop = 500
		fireTouch(grip("Alpha"), "touchstart", 10, 100)
		fireTouch(window, "touchmove", 10, 8)

		runFrame(1000)
		runFrames(1000, 10)
		expect(scroller.scrollTop).toBeCloseTo(500 - 10 * PER_FRAME, 0)

		runFrames(2000, 60)
		expect(scroller.scrollTop).toBe(0)
		runFrames(4000, 3)
		expect(scroller.scrollTop).toBe(0)
	})
})

describe("auto-scroll degenerate scrollers", () => {
	it("gives up on the document when the page itself cannot scroll", () => {
		render(<BentoGrid scope={SCOPE} items={items()} reveal={false} />)
		fireTouch(grip("Alpha"), "touchstart", 10, 700)
		fireTouch(window, "touchmove", 10, 760)

		runFrame(1000)
		runFrames(1000, 3)
		expect(document.documentElement.scrollTop).toBe(0)
		expect(renderedOrder()).toEqual(["Alpha", "Bravo", "Charlie"])
	})

	it("collapses the bands to nothing when the panel sits out of view", () => {
		const scroller = renderInScroller({ top: -500, bottom: -40 })
		fireTouch(grip("Alpha"), "touchstart", 10, 700)
		fireTouch(window, "touchmove", 10, 760)

		runFrame(1000)
		runFrames(1000, 3)
		expect(scroller.scrollTop).toBe(0)
	})
})
