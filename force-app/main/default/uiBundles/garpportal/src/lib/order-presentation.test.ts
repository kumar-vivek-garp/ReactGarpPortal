import { describe, expect, it } from "vitest"

import type { PortalOrder } from "@/api/orders/types"
import {
	buildOrderRowPresentation,
	orderMatches,
	summarizeOrders,
} from "./order-presentation"

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

describe("summarizeOrders", () => {
	it("groups outstanding per currency rather than inventing a total", () => {
		const summary = summarizeOrders(
			[
				order({ id: "a", amount: 300, currencyCode: "USD" }),
				order({ id: "b", amount: 120, currencyCode: "EUR" }),
				order({ id: "c", amount: 50, currencyCode: "USD" }),
			],
			[],
		)

		expect(summary.outstanding).toHaveLength(2)
		// Sorted by total desc — USD 350 before EUR 120.
		expect(summary.outstanding[0]).toMatchObject({ currency: "USD", total: 350 })
		expect(summary.outstanding[1]).toMatchObject({ currency: "EUR", total: 120 })
	})

	it("excludes unpaid orders that cannot be paid", () => {
		// Refunded / void / written off land in the unpaid bucket with canPay false;
		// they are not money owed.
		const summary = summarizeOrders(
			[
				order({ id: "a", amount: 300, canPay: true }),
				order({ id: "b", amount: 999, canPay: false }),
			],
			[],
		)

		expect(summary.outstanding).toEqual([
			expect.objectContaining({ currency: "USD", total: 300 }),
		])
		// The count still reflects the whole bucket, matching the filter tab.
		expect(summary.unpaidCount).toBe(2)
		expect(summary.hasPayable).toBe(true)
	})

	it("reports nothing outstanding when no order is payable", () => {
		const summary = summarizeOrders([order({ canPay: false })], [order()])
		expect(summary.outstanding).toEqual([])
		expect(summary.hasPayable).toBe(false)
	})

	it("skips orders with no amount instead of counting them as zero", () => {
		const summary = summarizeOrders(
			[order({ id: "a", amount: null }), order({ id: "b", amount: 75 })],
			[],
		)
		expect(summary.outstanding).toEqual([
			expect.objectContaining({ total: 75 }),
		])
	})

	it("counts both buckets", () => {
		const summary = summarizeOrders(
			[order({ id: "a" })],
			[order({ id: "b" }), order({ id: "c" })],
		)
		expect(summary).toMatchObject({
			unpaidCount: 1,
			paidCount: 2,
			totalCount: 3,
		})
	})
})

describe("orderMatches", () => {
	it("matches everything on an empty term", () => {
		expect(orderMatches(order(), "")).toBe(true)
	})

	it("matches on payment method, which the row now shows", () => {
		expect(orderMatches(order({ paymentMethod: "Invoice" }), "invoice")).toBe(
			true,
		)
	})

	it("matches on the formatted amount, not only the raw number", () => {
		// "300" is the raw value; the formatted string is what the member sees.
		expect(orderMatches(order({ amount: 300 }), "300")).toBe(true)
	})

	it("matches on the formatted date", () => {
		expect(orderMatches(order({ orderDate: "2026-03-01" }), "march")).toBe(true)
	})

	it("is case-insensitive on invoice and description", () => {
		expect(orderMatches(order(), "inv-1")).toBe(true)
		expect(orderMatches(order(), "FRM PART")).toBe(true)
	})

	it("returns false when nothing matches", () => {
		expect(orderMatches(order(), "zzzz")).toBe(false)
	})
})

describe("buildOrderRowPresentation", () => {
	it("falls back to a generic description", () => {
		expect(buildOrderRowPresentation(order({ description: null })).description).toBe(
			"GARP Order",
		)
	})

	it("omits meta lines for fields Apex left null", () => {
		const presentation = buildOrderRowPresentation(
			order({ invoiceNumber: null, orderDate: null, paymentMethod: null }),
		)
		expect(presentation.metaLines).toEqual([])
	})

	it("orders meta lines invoice, date, then payment method", () => {
		const presentation = buildOrderRowPresentation(
			order({ paymentMethod: "Credit" }),
		)
		expect(presentation.metaLines.map((line) => line.icon)).toEqual([
			"invoice",
			"when",
			"paymentMethod",
		])
	})

	it("shows a dash rather than an empty amount", () => {
		expect(buildOrderRowPresentation(order({ amount: null })).amountLabel).toBe(
			"—",
		)
	})

	it("delegates status to orderStatusPresentation", () => {
		const presentation = buildOrderRowPresentation(order({ isPaid: true }))
		expect(presentation).toMatchObject({ statusLabel: "Paid", statusTone: "success" })
	})
})
