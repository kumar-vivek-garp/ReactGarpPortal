import { describe, expect, it } from "vitest"

import {
	RAIL_COLLAPSED_WIDTH_PX,
	RAIL_WIDTH_PX,
	labelOffsetAt,
	labelOpacityAt,
	railWidthAt,
} from "./sidebar-rail"

describe("railWidthAt", () => {
	it("spans the two rail widths at the endpoints", () => {
		expect(railWidthAt(0)).toBe(RAIL_WIDTH_PX)
		expect(railWidthAt(1)).toBe(RAIL_COLLAPSED_WIDTH_PX)
	})

	it("interpolates linearly, so the edge travels at the spring's own rate", () => {
		expect(railWidthAt(0.5)).toBe((RAIL_WIDTH_PX + RAIL_COLLAPSED_WIDTH_PX) / 2)
	})

	it("clamps overshoot, so a spring that overshoots cannot invert the panel", () => {
		expect(railWidthAt(-0.4)).toBe(RAIL_WIDTH_PX)
		expect(railWidthAt(1.4)).toBe(RAIL_COLLAPSED_WIDTH_PX)
	})
})

describe("labelOpacityAt", () => {
	it("is fully opaque expanded and fully gone collapsed", () => {
		expect(labelOpacityAt(0)).toBe(1)
		expect(labelOpacityAt(1)).toBe(0)
	})

	it("reaches zero before the edge does, so no label is ever clipped mid-glyph", () => {
		// Text is fully gone by ~53% of the travel, while the panel still has
		// ~90px of room beyond the puck for a label that is no longer there.
		expect(labelOpacityAt(0.53)).toBe(0)
		expect(railWidthAt(0.53)).toBeGreaterThan(RAIL_COLLAPSED_WIDTH_PX + 90)
	})

	it("stays within range across the whole curve", () => {
		for (const t of [-0.5, 0, 0.25, 0.5, 0.75, 1, 1.5]) {
			expect(labelOpacityAt(t)).toBeGreaterThanOrEqual(0)
			expect(labelOpacityAt(t)).toBeLessThanOrEqual(1)
		}
	})
})

describe("labelOffsetAt", () => {
	it("pulls labels leftward as they fade", () => {
		expect(labelOffsetAt(0)).toBe(-0)
		expect(labelOffsetAt(1)).toBeLessThan(0)
		expect(labelOffsetAt(0.5)).toBeGreaterThan(labelOffsetAt(1))
	})
})
