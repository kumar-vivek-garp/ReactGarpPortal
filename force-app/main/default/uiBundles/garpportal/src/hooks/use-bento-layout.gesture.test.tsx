import { act, render, screen } from "@testing-library/react"
import { beforeEach, describe, expect, it, vi } from "vitest"

import type { BentoRenderItem } from "@/hooks/use-bento-layout"
import { useBentoLayoutStore } from "@/store/bento-layout-store"
import { stubBentoGeometry } from "@/testing/bento-geometry"
import { skipSpringAnimations } from "@/testing/springs"

/**
 * Drives the drag reducer with synthetic `@use-gesture` state, the idiom
 * `use-bento-layout.config.test.tsx` established. The touch-event suite
 * (`bento-grid.drag.test.tsx`) proves the wiring below the handler; this file
 * reaches the states no DOM event can produce in jsdom — a `canceled` gesture,
 * a pinned card's id, a stray id mid-drag, an unmeasured pickup.
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
/** Past the neighbour's middle (324 + 150) plus the 10px hysteresis band. */
const PAST_BRAVO = 360

const geometry = stubBentoGeometry()
skipSpringAnimations()

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

function items(): BentoRenderItem[] {
	const one = (
		id: string,
		label: string,
		sortable?: boolean,
	): BentoRenderItem => ({
		id,
		label,
		sortable,
		render: ({ handleProps }) => (
			<article data-testid="card">
				<h3>{label}</h3>
				{handleProps ? <button {...handleProps}>Reorder {label}</button> : null}
			</article>
		),
	})
	return [one("a", "Alpha"), one("b", "Bravo"), one("c", "Charlie", false)]
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
	geometry.enabled = true
})

describe("synthetic gesture lifecycle", () => {
	it("lifts on first, previews on move, commits on last", () => {
		render(<BentoGrid scope={SCOPE} items={items()} />)
		const grip = screen.getByRole("button", { name: "Reorder Alpha" })

		fireGesture({ args: ["a"], first: true, movement: [0, 8], xy: [10, 8] })
		expect(grip.dataset.lifted).toBe("true")
		expect(renderedOrder()).toEqual(["Alpha", "Bravo", "Charlie"])

		fireGesture({ args: ["a"], movement: [0, PAST_BRAVO], xy: [10, 360] })
		expect(renderedOrder()).toEqual(["Bravo", "Alpha", "Charlie"])

		fireGesture({ args: ["a"], last: true, movement: [0, PAST_BRAVO] })
		expect(grip.dataset.lifted).toBe("false")
		expect(renderedOrder()).toEqual(["Bravo", "Alpha", "Charlie"])
		expect(
			useBentoLayoutStore.getState().layouts[SCOPE]?.columns?.["1"],
		).toEqual([["b", "a", "c"]])
	})

	it("restores the pickup arrangement when the gesture is canceled", () => {
		render(<BentoGrid scope={SCOPE} items={items()} />)

		fireGesture({ args: ["a"], first: true, movement: [0, 8], xy: [10, 8] })
		fireGesture({ args: ["a"], movement: [0, PAST_BRAVO], xy: [10, 360] })
		expect(renderedOrder()).toEqual(["Bravo", "Alpha", "Charlie"])

		fireGesture({ args: ["a"], last: true, canceled: true })
		expect(renderedOrder()).toEqual(["Alpha", "Bravo", "Charlie"])
		expect(useBentoLayoutStore.getState().layouts[SCOPE]).toBeUndefined()
	})

	it("refuses the whole gesture for a pinned card", () => {
		render(<BentoGrid scope={SCOPE} items={items()} />)

		fireGesture({ args: ["c"], first: true, movement: [0, 8], xy: [10, 8] })
		fireGesture({ args: ["c"], movement: [0, -PAST_BRAVO], xy: [10, -360] })
		fireGesture({ args: ["c"], last: true, movement: [0, -PAST_BRAVO] })

		expect(renderedOrder()).toEqual(["Alpha", "Bravo", "Charlie"])
		expect(screen.getByRole("status").textContent).toBe("")
		expect(useBentoLayoutStore.getState().layouts[SCOPE]).toBeUndefined()
	})

	it("ignores movement reported for a card that is not the one in flight", () => {
		render(<BentoGrid scope={SCOPE} items={items()} />)

		fireGesture({ args: ["a"], first: true, movement: [0, 8], xy: [10, 8] })
		fireGesture({ args: ["b"], movement: [0, PAST_BRAVO], xy: [10, 360] })
		expect(renderedOrder()).toEqual(["Alpha", "Bravo", "Charlie"])

		fireGesture({ args: ["a"], last: true, canceled: true })
	})

	it("refuses a pointer pickup the grid has never measured", () => {
		geometry.enabled = false
		const warn = vi.spyOn(console, "warn").mockImplementation(() => {})
		try {
			render(<BentoGrid scope={SCOPE} items={items()} />)
			const grip = screen.getByRole("button", { name: "Reorder Alpha" })

			fireGesture({ args: ["a"], first: true, movement: [0, 8], xy: [10, 8] })
			expect(grip.dataset.lifted).toBe("false")
			expect(warn).toHaveBeenCalledWith(
				expect.stringContaining('cannot pick up "a"'),
			)

			// The refused pickup left no drag in flight for later events.
			fireGesture({ args: ["a"], movement: [0, PAST_BRAVO], xy: [10, 360] })
			fireGesture({ args: ["a"], last: true, movement: [0, PAST_BRAVO] })
			expect(renderedOrder()).toEqual(["Alpha", "Bravo", "Charlie"])
			expect(useBentoLayoutStore.getState().layouts[SCOPE]).toBeUndefined()
		} finally {
			warn.mockRestore()
		}
	})
})
