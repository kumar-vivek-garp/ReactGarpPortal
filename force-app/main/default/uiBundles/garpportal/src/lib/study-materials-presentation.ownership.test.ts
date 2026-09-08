import { describe, expect, it, vi } from "vitest"

import {
	isGarpLearning,
	isOwnedMaterial,
	materialMetaLines,
	splitByOwnership,
} from "@/lib/study-materials-presentation"
import { studyItem } from "@/testing/factories/study-materials"

describe("isOwnedMaterial", () => {
	it("counts anything the member already holds or can already open", () => {
		expect(isOwnedMaterial(studyItem({ isOwned: true }))).toBe(true)
		expect(isOwnedMaterial(studyItem({ accessUrl: "/read" }))).toBe(true)
		expect(isOwnedMaterial(studyItem({ downloadUrl: "/x.pdf" }))).toBe(true)
		expect(
			isOwnedMaterial(studyItem({ garpLearningAccessUrl: "/BenchPrepSSO" })),
		).toBe(true)
	})

	/*
	 * An unpaid order is theirs pending payment. Filing it with things they
	 * could still buy invites a second purchase of the same book.
	 */
	it("counts an unpaid order as theirs", () => {
		expect(isOwnedMaterial(studyItem({ isUnPaidOrder: true }))).toBe(true)
	})

	it("leaves anything merely for sale on the other side", () => {
		expect(isOwnedMaterial(studyItem({ canPurchase: true, price: 295 }))).toBe(
			false,
		)
		expect(isOwnedMaterial(studyItem({ isComingSoon: true }))).toBe(false)
		expect(isOwnedMaterial(studyItem({ isOutOfStock: true }))).toBe(false)
	})
})

describe("splitByOwnership", () => {
	it("splits in two and keeps Apex's order inside each", () => {
		const mine1 = studyItem({ id: "a", isOwned: true })
		const buy1 = studyItem({ id: "b", canPurchase: true })
		const mine2 = studyItem({ id: "c", accessUrl: "/read" })
		const buy2 = studyItem({ id: "d", isComingSoon: true })

		const split = splitByOwnership([mine1, buy1, mine2, buy2])

		expect(split.mine.map((item) => item.id)).toEqual(["a", "c"])
		expect(split.available.map((item) => item.id)).toEqual(["b", "d"])
	})

	it("returns two empty lists for an empty programme", () => {
		expect(splitByOwnership([])).toEqual({ mine: [], available: [] })
	})
})

describe("isGarpLearning", () => {
	it("recognises the platform by its access URL or its type label", () => {
		expect(
			isGarpLearning(studyItem({ garpLearningAccessUrl: "/BenchPrepSSO" })),
		).toBe(true)
		// Access is granted by a sitting, so the URL is absent out of season.
		expect(isGarpLearning(studyItem({ typeLabel: "GARP Learning" }))).toBe(true)
		expect(isGarpLearning(studyItem({ typeLabel: "eBook" }))).toBe(false)
	})
})

describe("materialMetaLines — the purchase line", () => {
	it("dates an owned material", () => {
		expect(
			materialMetaLines(studyItem({ isOwned: true, orderedDate: "2026-02-11" })),
		).toContainEqual({ icon: "purchased", text: "Purchased on February 11, 2026" })
	})

	it("says so when the material came with a registration", () => {
		expect(
			materialMetaLines(
				studyItem({
					isOwned: true,
					wasOrderedWithReg: true,
					registrationDate: "2026-02-11",
				}),
			),
		).toContainEqual({
			icon: "purchased",
			text: "Included with your registration on February 11, 2026",
		})
	})

	it("says nothing about a purchase for an unpaid order or GARP Learning", () => {
		// Nothing is owned yet on an unpaid order…
		expect(
			materialMetaLines(studyItem({ isOwned: true, isUnPaidOrder: true })),
		).toEqual([])
		// …and GARP Learning access comes with the sitting, not from a purchase.
		expect(
			materialMetaLines(
				studyItem({ isOwned: true, garpLearningAccessUrl: "/BenchPrepSSO" }),
			),
		).toEqual([])
	})

	it("still leads with the access expiry when there is one", () => {
		vi.useFakeTimers()
		vi.setSystemTime(new Date(2026, 7, 18))
		try {
			const lines = materialMetaLines(
				studyItem({
					isOwned: true,
					orderedDate: "2026-02-11",
					eBookSet: { titles: [], expireDate: "2027-01-31" },
				}),
			)
			expect(lines[0].icon).toBe("accessUntil")
			expect(lines[1].icon).toBe("purchased")
		} finally {
			vi.useRealTimers()
		}
	})
})
