import { describe, expect, it } from "vitest"

import { formatLongDate } from "@/lib/account-format"
import { studyItem } from "@/testing/factories/study-materials"

import { resolveMaterialAction } from "./study-materials-presentation"

/**
 * GarpAppv1's `Actions` chain, one row per rung plus the tie-breaks between
 * neighbours. First match wins — the order IS the behaviour.
 */
describe("resolveMaterialAction — the chain", () => {
	it("1. GARP Learning access beats everything", () => {
		expect(
			resolveMaterialAction(
				studyItem({
					garpLearningAccessUrl: "https://learning.garp.org/sso?prog=FRM",
					accessUrl: "https://reader.example",
					downloadUrl: "https://pdf.example",
					isOwned: true,
					canPurchase: true,
				}),
			),
		).toEqual({ kind: "garpLearning", url: "https://learning.garp.org/sso?prog=FRM" })
	})

	it("resolves a portal-relative SSO path against the Experience host", () => {
		const action = resolveMaterialAction(
			studyItem({ garpLearningAccessUrl: "/BenchPrepSSO?prog=FRM&part=1" }),
		)
		expect(action.kind).toBe("garpLearning")
		if (action.kind !== "garpLearning") return
		expect(action.url).toContain("/BenchPrepSSO?prog=FRM&part=1")
	})

	it("2. an eBook access url beats a download", () => {
		expect(
			resolveMaterialAction(
				studyItem({ accessUrl: "https://reader.example", downloadUrl: "https://pdf.example" }),
			),
		).toEqual({
			kind: "external",
			label: "Read eBook",
			url: "https://reader.example",
			icon: "read",
		})
	})

	it("3. a download beats an unpaid order", () => {
		expect(
			resolveMaterialAction(
				studyItem({
					downloadUrl: "https://pdf.example",
					isUnPaidOrder: true,
					orderId: "006X",
				}),
			),
		).toEqual({
			kind: "external",
			label: "Download Now",
			url: "https://pdf.example",
			icon: "download",
		})
	})

	it("4. an unpaid order with an id points at the order", () => {
		expect(
			resolveMaterialAction(
				studyItem({ isUnPaidOrder: true, orderId: "006UNPAID", isOwned: true }),
			),
		).toEqual({ kind: "completeOrder", path: "/my-account/orders/006UNPAID" })
	})

	it("4a. an unpaid order WITHOUT an id falls through", () => {
		expect(
			resolveMaterialAction(studyItem({ isUnPaidOrder: true, orderId: null, isOwned: true })),
		).toMatchObject({ kind: "owned" })
	})

	it("5. owned — with and without a date, registration date first", () => {
		const on = formatLongDate("2026-02-11")
		expect(
			resolveMaterialAction(
				studyItem({
					isOwned: true,
					wasOrderedWithReg: true,
					registrationDate: "2026-02-11",
					orderedDate: "2026-03-05",
					isComingSoon: true,
					canPurchase: true,
				}),
			),
		).toEqual({ kind: "owned", text: `Included with your registration · ${on}` })
		expect(
			resolveMaterialAction(studyItem({ isOwned: true, orderedDate: "2026-02-11" })),
		).toEqual({ kind: "owned", text: `Purchased · ${on}` })
		expect(resolveMaterialAction(studyItem({ isOwned: true }))).toEqual({
			kind: "owned",
			text: "Purchased",
		})
	})

	it("6. coming soon — with and without a date and a notify link", () => {
		expect(
			resolveMaterialAction(
				studyItem({
					isComingSoon: true,
					comingSoonDate: "2026-12-01",
					leadGenUrl: "https://www.garp.org/notify",
					isOutOfStock: true,
					canPurchase: true,
				}),
			),
		).toEqual({
			kind: "comingSoon",
			text: `Available ${formatLongDate("2026-12-01")}`,
			notifyUrl: "https://www.garp.org/notify",
		})
		expect(resolveMaterialAction(studyItem({ isComingSoon: true }))).toEqual({
			kind: "comingSoon",
			text: "Available soon",
			notifyUrl: null,
		})
	})

	it("7. out of stock beats purchasable", () => {
		expect(
			resolveMaterialAction(studyItem({ isOutOfStock: true, canPurchase: true, price: 80 })),
		).toEqual({ kind: "outOfStock", text: "Out of stock" })
	})

	it("8. purchasable — price and the in-app purchase page", () => {
		expect(
			resolveMaterialAction(studyItem({ canPurchase: true, price: 295, productCode: "FRM2H" })),
		).toEqual({
			kind: "purchase",
			priceLabel: "$295",
			path: "/study-materials/purchase/FRM2H",
		})
		expect(
			resolveMaterialAction(studyItem({ canPurchase: true, price: null, productCode: "FRM2H" })),
		).toMatchObject({ kind: "purchase", priceLabel: null })
	})

	it("8a. purchasable without a product code asks for member services", () => {
		expect(
			resolveMaterialAction(studyItem({ canPurchase: true, price: 295, productCode: null })),
		).toEqual({ kind: "contact", text: "Contact member services to buy this." })
	})

	it("8b. a lead-gen url is NEVER a purchase link", () => {
		// The one wiring mistake this chain exists to prevent.
		expect(
			resolveMaterialAction(
				studyItem({ canPurchase: true, productCode: "X", leadGenUrl: "https://www.garp.org/notify" }),
			),
		).toMatchObject({ kind: "purchase", path: "/study-materials/purchase/X" })
	})

	it("9. nothing applies", () => {
		expect(resolveMaterialAction(studyItem())).toEqual({ kind: "none" })
	})
})
