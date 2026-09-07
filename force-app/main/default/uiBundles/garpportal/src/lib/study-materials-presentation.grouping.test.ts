import { describe, expect, it } from "vitest"

import { studyItem } from "@/testing/factories/study-materials"

import { groupByPart } from "./study-materials-presentation"

describe("groupByPart", () => {
	it("leads with Part 1, then Part 2, with un-parted items last", () => {
		const groups = groupByPart([
			studyItem({ id: "gen", relatedPart: null }),
			studyItem({ id: "p2", relatedPart: "Part 2" }),
			studyItem({ id: "p1a", relatedPart: "Part 1" }),
			studyItem({ id: "p1b", relatedPart: "Part 1" }),
		])

		expect(groups.map((g) => g.part)).toEqual(["Part 1", "Part 2", null])
		expect(groups.map((g) => g.items.map((i) => i.id))).toEqual([
			["p1a", "p1b"],
			["p2"],
			["gen"],
		])
	})

	it("keeps Apex's order inside a group", () => {
		const groups = groupByPart([
			studyItem({ id: "b", relatedPart: "Part 1" }),
			studyItem({ id: "a", relatedPart: "Part 1" }),
		])
		expect(groups[0]?.items.map((i) => i.id)).toEqual(["b", "a"])
	})

	it("yields one null-part group for a programme with no parts", () => {
		const groups = groupByPart([studyItem({ id: "x" }), studyItem({ id: "y" })])
		expect(groups).toHaveLength(1)
		expect(groups[0]?.part).toBeNull()
		expect(groups[0]?.items).toHaveLength(2)
	})

	it("yields nothing for nothing", () => {
		expect(groupByPart([])).toEqual([])
	})
})
