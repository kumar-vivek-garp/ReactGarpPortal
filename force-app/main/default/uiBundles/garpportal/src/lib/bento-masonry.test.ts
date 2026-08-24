import { describe, expect, it } from "vitest"

import {
	flattenColumns,
	locate,
	moveCard,
	packRoundRobin,
	reconcileColumns,
	resolveMasonryTarget,
} from "./bento-masonry"
import type { BentoRect as Rect } from "./bento-layout"

const DEFAULTS = [
	"personal",
	"membership",
	"career",
	"chapters",
	"expertise",
	"directory",
] as const

describe("packRoundRobin", () => {
	it("deals across columns in order", () => {
		expect(packRoundRobin(DEFAULTS, 2)).toEqual([
			["personal", "career", "expertise"],
			["membership", "chapters", "directory"],
		])
	})

	it("is height-independent, so the first paint cannot re-shuffle", () => {
		// Same input, same output, with no measurement involved at all.
		expect(packRoundRobin(DEFAULTS, 2)).toEqual(packRoundRobin(DEFAULTS, 2))
	})

	it("degenerates to one column", () => {
		expect(packRoundRobin(DEFAULTS, 1)).toEqual([[...DEFAULTS]])
	})

	it("tolerates more columns than cards", () => {
		expect(packRoundRobin(["a", "b"], 4)).toEqual([["a"], ["b"], [], []])
	})
})

describe("locate / moveCard / flattenColumns", () => {
	const columns = [
		["a", "b"],
		["c", "d"],
	]

	it("finds a card's slot", () => {
		expect(locate(columns, "d")).toEqual({ column: 1, index: 1 })
		expect(locate(columns, "zz")).toBeNull()
	})

	it("moves across columns, closing the gap left behind", () => {
		expect(moveCard(columns, "a", { column: 1, index: 1 })).toEqual([
			["b"],
			["c", "a", "d"],
		])
	})

	it("moves within a column", () => {
		expect(moveCard(columns, "a", { column: 0, index: 1 })).toEqual([
			["b", "a"],
			["c", "d"],
		])
	})

	it("clamps an out-of-range target rather than dropping the card", () => {
		const moved = moveCard(columns, "a", { column: 9, index: 99 })
		expect(flattenColumns(moved).sort()).toEqual(["a", "b", "c", "d"])
		expect(moved[1]).toContain("a")
	})

	it("never mutates its input", () => {
		const snapshot = JSON.stringify(columns)
		moveCard(columns, "a", { column: 1, index: 0 })
		expect(JSON.stringify(columns)).toBe(snapshot)
	})
})

describe("reconcileColumns", () => {
	it("deals the defaults when nothing is stored", () => {
		expect(reconcileColumns(undefined, DEFAULTS, 2)).toEqual(
			packRoundRobin(DEFAULTS, 2),
		)
	})

	it("keeps a valid stored arrangement verbatim", () => {
		const stored = [
			["directory", "personal", "career"],
			["membership", "chapters", "expertise"],
		]
		expect(reconcileColumns(stored, DEFAULTS, 2)).toEqual(stored)
	})

	it("drops ids that no longer exist and collapses duplicates", () => {
		const stored = [
			["personal", "gone", "personal"],
			["membership", "career", "chapters", "expertise", "directory"],
		]
		const next = reconcileColumns(stored, DEFAULTS, 2)
		expect(flattenColumns(next).sort()).toEqual([...DEFAULTS].sort())
	})

	it("inserts a newly shipped card after its default predecessor", () => {
		// `chapters` did not exist when this was saved.
		const stored = [
			["personal", "career"],
			["membership", "expertise", "directory"],
		]
		const next = reconcileColumns(stored, DEFAULTS, 2)
		const slot = locate(next, "chapters")!
		const previous = next[slot.column][slot.index - 1]
		expect(previous).toBe("career")
	})

	it("re-deals when the stored arrangement is for a different column count", () => {
		const stored = [[...DEFAULTS]] // saved on a phone
		const next = reconcileColumns(stored, DEFAULTS, 2)
		expect(next).toHaveLength(2)
		expect(flattenColumns(next).sort()).toEqual([...DEFAULTS].sort())
	})

	it("survives garbage from a hand-edited localStorage entry", () => {
		for (const junk of ["nope", 7, null, [["a", 3]], [{}]]) {
			const next = reconcileColumns(junk, DEFAULTS, 2)
			expect(flattenColumns(next).sort()).toEqual([...DEFAULTS].sort())
		}
	})
})

/** Two 581px columns, 24px gutter — the real `xl` geometry. */
const BOUNDS = [
	{ left: 0, width: 581 },
	{ left: 605, width: 581 },
]

function rects(): Map<string, Rect> {
	return new Map<string, Rect>([
		["a", { left: 0, top: 0, width: 581, height: 300 }],
		["b", { left: 0, top: 324, width: 581, height: 400 }],
		["c", { left: 605, top: 0, width: 581, height: 250 }],
		["d", { left: 605, top: 274, width: 581, height: 350 }],
	])
}

const COLUMNS = [
	["a", "b"],
	["c", "d"],
]

function resolve(x: number, y: number, current = { column: 0, index: 0 }) {
	return resolveMasonryTarget({
		columns: COLUMNS,
		draggingId: "a",
		rects: rects(),
		columnBounds: BOUNDS,
		centroid: { x, y },
		current,
		hysteresis: 10,
	})
}

describe("resolveMasonryTarget", () => {
	it("picks the column the centroid is over", () => {
		expect(resolve(290, 100).column).toBe(0)
		expect(resolve(900, 100).column).toBe(1)
	})

	it("falls back to the nearest column past the outer edge", () => {
		expect(resolve(-400, 100).column).toBe(0)
		expect(resolve(2000, 100).column).toBe(1)
	})

	it("inserts above a card whose middle it has not passed", () => {
		// Above c's middle (125) in column 1.
		expect(resolve(900, 60)).toEqual({ column: 1, index: 0 })
	})

	it("inserts between two cards", () => {
		// Past c's middle (125), above d's middle (449).
		expect(resolve(900, 300)).toEqual({ column: 1, index: 1 })
	})

	it("appends past the last card's middle", () => {
		expect(resolve(900, 900)).toEqual({ column: 1, index: 2 })
	})

	it("ignores the dragged card when indexing its own column", () => {
		// Column 0 holds [a, b]; `a` is being dragged, so only `b` counts and the
		// deepest index is 1, not 2.
		expect(resolve(290, 5000)).toEqual({ column: 0, index: 1 })
	})

	it("holds position inside the dead band rather than strobing", () => {
		// b's middle is 524. Moving down needs to pass 534.
		const current = { column: 0, index: 0 }
		expect(resolve(290, 528, current)).toEqual({ column: 0, index: 0 })
		expect(resolve(290, 540, current)).toEqual({ column: 0, index: 1 })
	})

	it("keeps the current slot when nothing has been measured", () => {
		const current = { column: 1, index: 1 }
		expect(
			resolveMasonryTarget({
				columns: COLUMNS,
				draggingId: "a",
				rects: new Map(),
				columnBounds: [],
				centroid: { x: 0, y: 0 },
				current,
				hysteresis: 10,
			}),
		).toEqual(current)
	})
})
