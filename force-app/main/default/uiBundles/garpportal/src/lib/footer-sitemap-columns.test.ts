import { describe, expect, it } from "vitest"

import { packFooterColumns } from "./footer-sitemap-columns"
import { FOOTER_NAV_SECTIONS } from "@/config/navigation/footer-nav-sections"
import type { FooterNavSection } from "@/config/navigation/types"

function section(key: string, linkCount: number): FooterNavSection {
	return {
		key,
		label: key.toUpperCase(),
		accentToken: "garp-cyan",
		links: Array.from({ length: linkCount }, (_, i) => ({
			title: `${key}-${i}`,
			url: `https://example.test/${key}/${i}`,
		})),
	}
}

/** Rows a column occupies: one per link, plus one per section heading. */
function columnWeight(column: FooterNavSection[]) {
	return column.reduce((total, s) => total + s.links.length + 1, 0)
}

describe("packFooterColumns", () => {
	it("keeps every section exactly once", () => {
		const columns = packFooterColumns(FOOTER_NAV_SECTIONS, 5)
		const keys = columns.flat().map((s) => s.key)

		expect(keys).toHaveLength(FOOTER_NAV_SECTIONS.length)
		expect(new Set(keys).size).toBe(FOOTER_NAV_SECTIONS.length)
	})

	it("beats naive in-order filling on the real footer", () => {
		const columns = packFooterColumns(FOOTER_NAV_SECTIONS, 5)
		const tallest = Math.max(...columns.map(columnWeight))
		const total = columnWeight(FOOTER_NAV_SECTIONS)

		// The failure this exists to prevent: FRM/SCR/RAI (9 rows each) each
		// claiming a whole column while six short sections pile into two.
		expect(tallest).toBeLessThanOrEqual(Math.ceil(total / 5) + 2)
	})

	it("reads left to right in the configured order", () => {
		const columns = packFooterColumns(FOOTER_NAV_SECTIONS, 5)
		const order = FOOTER_NAV_SECTIONS.map((s) => s.key)
		const firstOfEach = columns.map((column) => order.indexOf(column[0].key))

		expect(firstOfEach).toEqual([...firstOfEach].sort((a, b) => a - b))
		for (const column of columns) {
			const indices = column.map((s) => order.indexOf(s.key))
			expect(indices).toEqual([...indices].sort((a, b) => a - b))
		}
	})

	it("balances a lopsided set instead of filling in order", () => {
		const sections = [section("a", 8), section("b", 8), section("c", 2), section("d", 2)]
		const columns = packFooterColumns(sections, 2)

		expect(columns.map(columnWeight)).toEqual([12, 12])
	})

	it("never emits an empty column", () => {
		const columns = packFooterColumns([section("a", 3), section("b", 3)], 5)

		expect(columns).toHaveLength(2)
		expect(columns.every((column) => column.length > 0)).toBe(true)
	})

	it("returns a single column when asked for none", () => {
		const sections = [section("a", 1)]

		expect(packFooterColumns(sections, 0)).toEqual([sections])
	})
})
