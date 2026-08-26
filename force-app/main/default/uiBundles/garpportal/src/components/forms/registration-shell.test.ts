import { describe, expect, it } from "vitest"

import {
	REGISTRATION_BAR_CONTROL_HEIGHT,
	REGISTRATION_GRID,
	REGISTRATION_MAIN_COLUMN,
	REGISTRATION_RAIL_COLUMN,
} from "@/components/forms/registration-shell"

/** `lg:col-span-6` -> 6, `lg:grid-cols-10` -> 10. */
function span(classes: string, prefix: string): number {
	const match = new RegExp(`lg:${prefix}-(\\d+)`).exec(classes)
	if (!match) throw new Error(`no lg:${prefix}-N in "${classes}"`)
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
		// `sticky` with a `top` greater than the element's natural offset pushes
		// it down at rest, on first paint. 4rem bar + 1.5rem grid gap = 5.5rem.
		expect(REGISTRATION_RAIL_COLUMN).toContain("lg:top-22")
		expect(REGISTRATION_RAIL_COLUMN).toContain("lg:h-fit")
	})

	it("sizes the bar's controls to a large Button", () => {
		// The Button atom's `size="lg"` is h-10. The skeleton guessed h-11 and
		// the header jumped 4px on arrival.
		expect(REGISTRATION_BAR_CONTROL_HEIGHT).toBe("h-10")
	})
})
