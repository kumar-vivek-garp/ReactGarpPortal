import { describe, expect, it } from "vitest"

import {
	CPD_NAV_ITEM,
	SIDE_NAV_ITEMS,
	sideNavItems,
} from "@/config/navigation/side-nav-items"

describe("sideNavItems", () => {
	it("omits CPD for members who hold no certification", () => {
		const rows = sideNavItems({ includeCpd: false })

		expect(rows.some((item) => item.to === "/cpd")).toBe(false)
		expect(rows).toEqual(SIDE_NAV_ITEMS)
	})

	it("inserts CPD directly after Programs when included", () => {
		const rows = sideNavItems({ includeCpd: true })

		const programsIndex = rows.findIndex((item) => item.to === "/programs")
		expect(programsIndex).toBeGreaterThanOrEqual(0)
		expect(rows[programsIndex + 1]).toBe(CPD_NAV_ITEM)
		expect(rows.filter((item) => item.to === "/cpd")).toHaveLength(1)
	})

	it("keeps every base row, in order, around the inserted CPD row", () => {
		const rows = sideNavItems({ includeCpd: true })

		expect(rows).toHaveLength(SIDE_NAV_ITEMS.length + 1)
		expect(rows.filter((item) => item.to !== "/cpd")).toEqual(SIDE_NAV_ITEMS)
	})

	it("never mutates the shared base list", () => {
		const before = SIDE_NAV_ITEMS.map((item) => item.to)

		sideNavItems({ includeCpd: true })

		expect(SIDE_NAV_ITEMS.map((item) => item.to)).toEqual(before)
	})
})
