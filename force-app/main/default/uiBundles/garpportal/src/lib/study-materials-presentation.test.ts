import { afterEach, describe, expect, it, vi } from "vitest"

import { formatLongDate } from "@/lib/account-format"
import { studyItem } from "@/testing/factories/study-materials"

import {
	accessExpiryLine,
	comingSoonLine,
	formatPrice,
	materialMetaLines,
	materialStatusBadge,
	ownedLine,
	purchasePath,
	studyCodeLabel,
} from "./study-materials-presentation"

afterEach(() => {
	vi.useRealTimers()
})

describe("studyCodeLabel", () => {
	it("uppercases the program key", () => {
		expect(studyCodeLabel("scr")).toBe("SCR")
		expect(studyCodeLabel(" frm ")).toBe("FRM")
	})
})

describe("accessExpiryLine", () => {
	it("counts down inside the 30-day window", () => {
		vi.useFakeTimers()
		vi.setSystemTime(new Date(2026, 7, 18))
		expect(accessExpiryLine("2026-08-27")).toEqual({
			icon: "expiringSoon",
			text: "Access ends in 9 days",
		})
	})

	it("uses today / tomorrow at the boundary", () => {
		vi.useFakeTimers()
		vi.setSystemTime(new Date(2026, 7, 18))
		expect(accessExpiryLine("2026-08-18")?.text).toBe("Access ends today")
		expect(accessExpiryLine("2026-08-19")?.text).toBe("Access ends tomorrow")
	})

	it("reports an expiry that has already passed", () => {
		vi.useFakeTimers()
		vi.setSystemTime(new Date(2026, 7, 18))
		const line = accessExpiryLine("2026-01-05")
		expect(line?.icon).toBe("expiringSoon")
		expect(line?.text).toContain("Access ended")
	})

	it("uses a plain date beyond the window", () => {
		vi.useFakeTimers()
		vi.setSystemTime(new Date(2026, 7, 18))
		const line = accessExpiryLine("2027-08-11")
		expect(line?.icon).toBe("accessUntil")
		expect(line?.text).toContain("Access until")
	})

	it("returns null with no date", () => {
		expect(accessExpiryLine(null)).toBeNull()
		expect(accessExpiryLine("")).toBeNull()
	})
})

describe("formatPrice / purchasePath", () => {
	it("renders whole dollars bare and cents when there are any", () => {
		expect(formatPrice(295)).toBe("USD 295")
		expect(formatPrice(12.5)).toBe("USD 12.50")
		expect(formatPrice(0)).toBe("USD 0")
		expect(formatPrice(null)).toBeNull()
		expect(formatPrice(undefined)).toBeNull()
	})

	it("builds the encoded in-app purchase path", () => {
		expect(purchasePath("FRM2H")).toBe("/study-materials/purchase/FRM2H")
		expect(purchasePath(" a/b ")).toBe("/study-materials/purchase/a%2Fb")
		expect(purchasePath("")).toBeNull()
		expect(purchasePath(null)).toBeNull()
	})
})

describe("ownedLine / comingSoonLine", () => {
	it("says how the material was acquired, with the date when there is one", () => {
		const on = formatLongDate("2026-02-11")
		expect(
			ownedLine({ wasOrderedWithReg: true, registrationDate: "2026-02-11", orderedDate: null }),
		).toBe(`Included with your registration · ${on}`)
		expect(
			ownedLine({ wasOrderedWithReg: false, registrationDate: null, orderedDate: "2026-02-11" }),
		).toBe(`Purchased · ${on}`)
		expect(
			ownedLine({ wasOrderedWithReg: false, registrationDate: null, orderedDate: null }),
		).toBe("Purchased")
	})

	it("dates a coming-soon item, or says soon", () => {
		expect(comingSoonLine("2026-12-01")).toBe(`Available ${formatLongDate("2026-12-01")}`)
		expect(comingSoonLine(null)).toBe("Available soon")
	})
})

describe("materialStatusBadge", () => {
	it("chips the first fact that applies, in the chain's order", () => {
		expect(materialStatusBadge(studyItem({ isUnPaidOrder: true, isOwned: true }))).toEqual({
			label: "Unpaid order",
			tone: "warning",
		})
		expect(materialStatusBadge(studyItem({ isOwned: true }))).toEqual({
			label: "Owned",
			tone: "success",
		})
		expect(
			materialStatusBadge(studyItem({ garpLearningAccessUrl: "https://l.example" })),
		).toEqual({ label: "Access granted", tone: "success" })
		expect(materialStatusBadge(studyItem({ accessUrl: "https://r.example" }))).toEqual({
			label: "Access granted",
			tone: "success",
		})
		expect(materialStatusBadge(studyItem({ isComingSoon: true }))).toEqual({
			label: "Coming soon",
			tone: "info",
		})
		expect(materialStatusBadge(studyItem({ isOutOfStock: true }))).toEqual({
			label: "Out of stock",
			tone: "neutral",
		})
	})

	it("chips nothing for a material that is simply for sale", () => {
		expect(materialStatusBadge(studyItem({ canPurchase: true, price: 295 }))).toBeNull()
	})
})

describe("materialMetaLines", () => {
	it("carries the eBook key's expiry and nothing else", () => {
		vi.useFakeTimers()
		vi.setSystemTime(new Date(2026, 7, 18))
		expect(
			materialMetaLines(
				studyItem({ eBookSet: { titles: [], expireDate: "2027-08-11" } }),
			),
		).toEqual([{ icon: "accessUntil", text: expect.stringContaining("Access until") }])
		expect(materialMetaLines(studyItem())).toEqual([])
	})
})
