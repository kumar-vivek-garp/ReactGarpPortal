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

	it("tones paid statuses as success", () => {
		expect(orderStatusPresentation(order({ isPaid: true }))).toEqual({
			label: "Paid",
			tone: "success",
		})
		expect(
			orderStatusPresentation(order({ isPaid: true, paymentStatus: "Settled" })),
		).toEqual({ label: "Settled", tone: "success" })
	})

	it("tones unpaid / awaiting as warning", () => {
		expect(orderStatusPresentation(order({ canPay: true }))).toEqual({
			label: "Unpaid",
			tone: "warning",
		})
		expect(
			orderStatusPresentation(order({ paymentStatus: "Unpaid", canPay: true })),
		).toEqual({ label: "Unpaid", tone: "warning" })
	})

	it("tones Recurring as info (active auto-renew)", () => {
		expect(
			orderStatusPresentation(
				order({
					paymentStatus: "Recurring",
					isPaid: false,
					canPay: false,
					isClosed: false,
				}),
			),
		).toEqual({ label: "Recurring", tone: "info" })
		expect(
			orderStatusPresentation(order({ stage: "Recurring Intent", canPay: false })),
		).toEqual({ label: "Recurring Intent", tone: "info" })
	})

	it("tones Stopped / cancelled / void as danger", () => {
		expect(
			orderStatusPresentation(
				order({
					paymentStatus: "Stopped",
					canPay: false,
					isClosed: true,
				}),
			),
		).toEqual({ label: "Stopped", tone: "danger" })
		expect(
			orderStatusPresentation(
				order({ stage: "Closed Lost", canPay: false, isClosed: true }),
			),
		).toEqual({ label: "Closed Lost", tone: "danger" })
		expect(
			orderStatusPresentation(order({ paymentStatus: "Void", canPay: false })),
		).toEqual({ label: "Void", tone: "danger" })
	})

	it("falls back to the stage before inventing a label", () => {
		expect(orderStatusPresentation(order({ stage: "Draft" }))).toEqual({
			label: "Draft",
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

	it("uses flag fallbacks for unknown Apex strings", () => {
		expect(
			orderStatusPresentation(
				order({ paymentStatus: "Wire Transfer Pending", isPaid: true }),
			),
		).toEqual({ label: "Wire Transfer Pending", tone: "success" })
		expect(
			orderStatusPresentation(
				order({
					paymentStatus: "Employer Invoice",
					canPay: true,
					isPaid: false,
				}),
			),
		).toEqual({ label: "Employer Invoice", tone: "warning" })
	})
})
