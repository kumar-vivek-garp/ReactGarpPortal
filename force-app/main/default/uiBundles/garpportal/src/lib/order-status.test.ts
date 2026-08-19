import { describe, expect, it } from "vitest"

import type { PortalOrder } from "@/api/orders/types"
import { orderStatusPresentation } from "./order-status"

function order(overrides: Partial<PortalOrder> = {}): PortalOrder {
	return {
		id: "o1",
		invoiceNumber: "INV-1",
		description: "FRM Part I registration",
		orderDate: "2026-03-01",
		amount: 300,
		currencyCode: "USD",
		stage: null,
		paymentStatus: null,
		paymentMethod: null,
		isPaid: false,
		isClosed: false,
		canPay: true,
		...overrides,
	}
}

describe("orderStatusPresentation", () => {
	it("prefers the Apex payment status when present", () => {
		expect(
			orderStatusPresentation(order({ paymentStatus: "  Partially Paid  " })),
		).toEqual({ label: "Partially Paid", tone: "warning" })
	})

	it("tones a paid order as success", () => {
		expect(orderStatusPresentation(order({ isPaid: true }))).toEqual({
			label: "Paid",
			tone: "success",
		})
		// An explicit status still wins the label, but paid keeps the success tone.
		expect(
			orderStatusPresentation(order({ isPaid: true, paymentStatus: "Settled" })),
		).toEqual({ label: "Settled", tone: "success" })
	})

	it("falls back to the stage before inventing a label", () => {
		expect(orderStatusPresentation(order({ stage: "Draft" }))).toEqual({
			label: "Draft",
			tone: "warning",
		})
	})

	it("reports Unpaid only when the order can actually be paid", () => {
		expect(orderStatusPresentation(order({ canPay: true }))).toEqual({
			label: "Unpaid",
			tone: "warning",
		})
	})

	it("asserts nothing when there is no status and nothing to pay", () => {
		expect(orderStatusPresentation(order({ canPay: false }))).toEqual({
			label: "—",
			tone: "neutral",
		})
	})

	it("ignores blank strings from Apex", () => {
		expect(
			orderStatusPresentation(order({ paymentStatus: "   ", stage: "   " })),
		).toEqual({ label: "Unpaid", tone: "warning" })
	})
})
