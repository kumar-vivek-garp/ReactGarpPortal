import { act, render, screen } from "@testing-library/react"
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest"

import type { BentoRenderItem } from "@/hooks/use-bento-layout"
import { useBentoLayoutStore } from "@/store/bento-layout-store"
import { stubBentoGeometry } from "@/testing/bento-geometry"
import { skipSpringAnimations } from "@/testing/springs"

/**
 * The measuring lifecycle between gestures: geometry can change without a
 * React render (a resize, a font swap, a registry change), and the observer
 * path must feed the next pickup fresh rects — while a live drag's frozen
 * frame stays frozen. The gesture handler is captured with the same mock the
 * config and gesture suites use, because proving "fresh geometry" means
 * hit-testing against it.
 */

type SyntheticDragState = {
	args: [string]
	first: boolean
	last: boolean
	canceled: boolean
	movement: [number, number]
	xy: [number, number]
}

const handlers: Array<(state: SyntheticDragState) => void> = []

vi.mock("@use-gesture/react", async (importOriginal) => {
	const actual = await importOriginal<typeof import("@use-gesture/react")>()
	return {
		...actual,
		useDrag: (handler: never, config: never) => {
			handlers.push(handler as unknown as (state: SyntheticDragState) => void)
			return actual.useDrag(handler, config)
		},
	}
})

const { BentoGrid } = await import("@/components/molecules/bento-grid")

const SCOPE = "account-information"

const geometry = stubBentoGeometry()
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

function fireGesture(state: Partial<SyntheticDragState> & { args: [string] }) {
	const handler = handlers[handlers.length - 1]
	act(() => {
		handler({
			first: false,
			last: false,
			canceled: false,
			movement: [0, 0],
			xy: [0, 0],
			...state,
		})
	})
}

function fireResize() {
	act(() => {
		for (const instance of ControllableResizeObserver.instances) {
			instance.fire()
		}
	})
}

/** The reflow handler defers its DOM read to the next animation frame. */
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

beforeEach(() => {
	handlers.length = 0
	window.localStorage.clear()
	useBentoLayoutStore.setState({ layouts: {} })
	geometry.cardHeight = 300
	originalResizeObserver = globalThis.ResizeObserver
	ControllableResizeObserver.instances = []
	globalThis.ResizeObserver =
		ControllableResizeObserver as unknown as typeof ResizeObserver
})

afterEach(() => {
	globalThis.ResizeObserver = originalResizeObserver
})

describe("reflow between gestures", () => {
	it("re-measures on resize, so the next pickup hit-tests fresh geometry", async () => {
		render(<BentoGrid scope={SCOPE} items={items()} />)

		// The cards shrink without a React render — only the observer can see it.
		geometry.cardHeight = 100
		fireResize()
		fireResize() // A second burst exercises the frame coalescing.
		await flushFrames()

		// 150px crosses a 100px neighbour's middle, nowhere near a 300px one's.
		fireGesture({ args: ["a"], first: true, movement: [0, 8], xy: [10, 8] })
		fireGesture({ args: ["a"], movement: [0, 150], xy: [10, 150] })
		expect(renderedOrder()).toEqual(["Bravo", "Alpha", "Charlie"])

		// Mid-drag, a resize must not disturb the gesture's frozen frame.
		geometry.cardHeight = 700
		fireResize()
		await flushFrames()
		expect(renderedOrder()).toEqual(["Bravo", "Alpha", "Charlie"])

		fireGesture({ args: ["a"], last: true, movement: [0, 150] })
		expect(
			useBentoLayoutStore.getState().layouts[SCOPE]?.columns?.["1"],
		).toEqual([["b", "a", "c"]])
	})

	it("cancels a still-pending reflow frame on unmount", async () => {
		const { unmount } = render(<BentoGrid scope={SCOPE} items={items()} />)

		// Schedule the deferred re-measure, then tear down before it can run.
		fireResize()
		unmount()
		await flushFrames()
	})

	it("absorbs a registry change into a measured grid without a FLIP crash", () => {
		const { rerender } = render(<BentoGrid scope={SCOPE} items={items()} />)

		// The new card has no previous rect, so the FLIP must skip it.
		rerender(
			<BentoGrid
				scope={SCOPE}
				items={[
					...items(),
					{
						id: "d",
						label: "Delta",
						render: ({ handleProps }) => (
							<article data-testid="card">
								<h3>Delta</h3>
								{handleProps ? <button {...handleProps}>grip</button> : null}
							</article>
						),
					},
				]}
			/>,
		)
		expect(renderedOrder()).toEqual(["Alpha", "Bravo", "Charlie", "Delta"])
	})

	it("tolerates a font readiness probe that rejects", async () => {
		Object.defineProperty(document, "fonts", {
			configurable: true,
			value: { ready: Promise.reject(new Error("no fonts here")) },
		})
		try {
			render(<BentoGrid scope={SCOPE} items={items()} />)
			await act(async () => {
				await Promise.resolve()
			})
			expect(screen.getAllByTestId("card")).toHaveLength(3)
		} finally {
			delete (document as unknown as Record<string, unknown>).fonts
		}
	})
})
