import { describe, expect, it } from "vitest"

import {
	REGISTRATION_BAR_CONTROL_HEIGHT,
	REGISTRATION_GRID,
	REGISTRATION_MAIN_COLUMN,
	REGISTRATION_RAIL_COLUMN,
	REGISTRATION_STICKY_BAR,
} from "@/components/forms/registration-shell"

/** `lg:col-span-6` -> 6, `lg:grid-cols-10` -> 10. */
function span(classes: string, prefix: string): number {
	const match = new RegExp(`lg:${prefix}-(\\d+)`).exec(classes)
	if (!match) throw new Error(`no lg:${prefix}-N in "${classes}"`)
	return Number(match[1])
}

/** `pt-9` -> 9. Tailwind spacing units, so these are directly addable. */
function spacing(classes: string, prefix: string): number {
	const match = new RegExp(`(?:^|[ :])${prefix}-(\\d+)(?: |$)`).exec(classes)
	if (!match) throw new Error(`no ${prefix}-N in "${classes}"`)
	return Number(match[1])
}

describe("the registration checkout grid", () => {
	it("splits 60/40", () => {
		expect(span(REGISTRATION_MAIN_COLUMN, "col-span")).toBe(6)
		expect(span(REGISTRATION_RAIL_COLUMN, "col-span")).toBe(4)
	})

	it("fills its track exactly", () => {
		/*
		 * The regression this file exists for. The loading skeleton was written
		 * 7/3 against a 60/40 form, so the whole page stepped sideways the
		 * moment the payload landed. Both now read these constants, and this
		 * asserts the two halves still add up to the track they sit in — a
		 * change to one column without the other fails here rather than in a
		 * browser nobody reopened.
		 */
		const columns = span(REGISTRATION_GRID, "grid-cols")
		expect(
			span(REGISTRATION_MAIN_COLUMN, "col-span") +
				span(REGISTRATION_RAIL_COLUMN, "col-span"),
		).toBe(columns)
	})

	it("pins the rail at the sticky bar's own offset", () => {
		/*
		 * `sticky` with a `top` greater than the element's natural offset pushes
		 * it down at rest, on first paint — so this asserts the derivation
		 * rather than the number it currently comes to. Everything above the
		 * rail, in Tailwind spacing units: the bar's top padding (which absorbs
		 * the page container's, since the bar bleeds over it), the control row,
		 * the bar's bottom padding, and the grid gap.
		 *
		 * Change the bar's padding without moving the rail and this fails here
		 * rather than in a browser nobody reopened.
		 */
		const natural =
			spacing(REGISTRATION_STICKY_BAR, "pt") +
			spacing(REGISTRATION_BAR_CONTROL_HEIGHT, "h") +
			spacing(REGISTRATION_STICKY_BAR, "pb") +
			spacing(REGISTRATION_GRID, "gap")

		expect(REGISTRATION_RAIL_COLUMN).toContain(`lg:top-${natural}`)
		expect(REGISTRATION_RAIL_COLUMN).toContain("lg:h-fit")
	})

	it("bleeds the sticky bar over the page container's padding", () => {
		/*
		 * The bar is pinned against the shell's scroller now, and the container
		 * pads inside that. Without pulling back over both axes the form shows
		 * through above the bar and down each side while it is pinned — which
		 * reads as a rendering fault, not as depth.
		 */
		expect(REGISTRATION_STICKY_BAR).toContain("-mt-6")
		expect(REGISTRATION_STICKY_BAR).toContain("-mx-shell-gutter")
		expect(REGISTRATION_STICKY_BAR).toContain("px-shell-gutter")
		expect(REGISTRATION_STICKY_BAR).toContain("bg-background")
	})

	it("sizes the bar's controls to a large Button", () => {
		// The Button atom's `size="lg"` is h-10. The skeleton guessed h-11 and
		// the header jumped 4px on arrival.
		expect(REGISTRATION_BAR_CONTROL_HEIGHT).toBe("h-10")
	})
})
