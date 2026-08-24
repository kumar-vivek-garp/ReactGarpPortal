import { beforeEach, describe, expect, it, vi } from "vitest"
import { render } from "@testing-library/react"

const recordedConfigs: Array<Record<string, unknown>> = []

vi.mock("@use-gesture/react", async (importOriginal) => {
	const actual = await importOriginal<typeof import("@use-gesture/react")>()
	return {
		...actual,
		useDrag: (handler: never, config: Record<string, unknown>) => {
			recordedConfigs.push(config)
			return actual.useDrag(handler, config)
		},
	}
})

const { BentoGrid } = await import("@/components/molecules/bento-grid")
const { useBentoLayoutStore } = await import("@/store/bento-layout-store")

/**
 * Pins the one `@use-gesture` option a DOM-reordering sortable cannot leave at
 * its default.
 *
 * With pointer capture on, `@use-gesture` binds move/end to the grip element
 * and treats `lostpointercapture` as a pointer-up. Moving a card to another
 * column unmounts its DOM node, so the browser releases capture: the gesture
 * ends by itself (the card drops without the member letting go) and the element
 * listeners die with the node (the card then freezes mid-drag).
 *
 * This cannot be caught by rendering: jsdom has no `PointerEvent`, so
 * `@use-gesture` picks its touch device, for which `pointerCapture` resolves
 * false whatever we pass — the bug is invisible outside a real browser. So the
 * configuration itself is the thing under test.
 */
describe("bento drag gesture configuration", () => {
	beforeEach(() => {
		recordedConfigs.length = 0
		window.localStorage.clear()
		useBentoLayoutStore.setState({ layouts: {} })
	})

	it("disables pointer capture, so reordering cannot end the gesture", () => {
		render(
			<BentoGrid
				scope="account-information"
				items={[
					{
						id: "a",
						label: "Alpha",
						render: ({ handleProps }) =>
							handleProps ? <button {...handleProps}>grip</button> : null,
					},
				]}
			/>,
		)

		expect(recordedConfigs.length).toBeGreaterThan(0)
		const pointer = recordedConfigs[0].pointer as Record<string, unknown>
		expect(pointer.capture).toBe(false)
		// We own Space/Enter for the keyboard reorder state machine.
		expect(pointer.keys).toBe(false)
		// A click on the grip must not register as a zero-distance drag.
		expect(recordedConfigs[0].filterTaps).toBe(true)
	})
})
