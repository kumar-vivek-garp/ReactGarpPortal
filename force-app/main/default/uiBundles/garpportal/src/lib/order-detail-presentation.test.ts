import { describe, expect, it } from "vitest"

import type { PortalOrder } from "@/api/orders/types"
import { buildOrderDetailPresentation } from "./order-detail-presentation"

function order(overrides: Partial<PortalOrder> = {}): PortalOrder {
	return {
		id: "006xx0000001",
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

function field(presentation: { detailFields: { label: string; value: string }[] }, label: string) {
	return presentation.detailFields.find((row) => row.label === label)?.value
}

describe("buildOrderDetailPresentation — headline", () => {
	it("titles the panel with the description, falling back generically", () => {
		expect(buildOrderDetailPresentation(order()).title).toBe(
			"FRM Part I registration",
		)
		expect(
			buildOrderDetailPresentation(order({ description: "  " })).title,
		).toBe("GARP Order")
	})

	it("formats the money and date and keeps the raw order id", () => {
		const presentation = buildOrderDetailPresentation(order())
		expect(presentation.amountLabel).toBe("$300.00")
		expect(presentation.dateLabel).toBe("March 1, 2026")
		expect(presentation.orderId).toBe("006xx0000001")
	})

	it("treats a whitespace invoice number as absent", () => {
		const presentation = buildOrderDetailPresentation(order({ invoiceNumber: " " }))
		expect(presentation.invoiceNumber).toBeNull()
		expect(field(presentation, "Invoice Number")).toBeUndefined()
	})

	it("delegates status to orderStatusPresentation", () => {
		expect(buildOrderDetailPresentation(order())).toMatchObject({
			statusLabel: "Unpaid",
			statusTone: "warning",
		})
	})
})

describe("buildOrderDetailPresentation — summary strip", () => {
	it("lists date, invoice, then payment method", () => {
		const presentation = buildOrderDetailPresentation(
			order({ paymentMethod: "Credit Card" }),
		)
		expect(presentation.summaryFields).toEqual([
			{ label: "Purchase Date", value: "March 1, 2026" },
			{ label: "Invoice", value: "INV-1" },
			{ label: "Payment Method", value: "Credit Card" },
		])
	})

	it("omits what Apex left null instead of showing blanks", () => {
		const presentation = buildOrderDetailPresentation(
			order({ orderDate: null, invoiceNumber: null }),
		)
		expect(presentation.summaryFields).toEqual([])
	})
})

describe("buildOrderDetailPresentation — details card", () => {
	it("dashes a missing date and amount rather than dropping the rows", () => {
		const presentation = buildOrderDetailPresentation(
			order({ orderDate: null, amount: null }),
		)
		expect(field(presentation, "Purchase Date")).toBe("—")
		expect(field(presentation, "Amount")).toBe("—")
	})

	it("falls back to the status label when Apex sent no payment status", () => {
		expect(field(buildOrderDetailPresentation(order()), "Payment Status")).toBe(
			"Unpaid",
		)
		expect(
			field(
				buildOrderDetailPresentation(order({ paymentStatus: "Partially Paid" })),
				"Payment Status",
			),
		).toBe("Partially Paid")
	})

	it("shows the stage only when it adds information", () => {
		const distinct = buildOrderDetailPresentation(
			order({ stage: "Closed Won", paymentStatus: "Paid" }),
		)
		expect(field(distinct, "Order Stage")).toBe("Closed Won")

		// Repeats the payment status verbatim — noise.
		const same = buildOrderDetailPresentation(
			order({ stage: "Paid", paymentStatus: "Paid" }),
		)
		expect(field(same, "Order Stage")).toBeUndefined()

		// With no payment status the stage IS the status label already.
		const isLabel = buildOrderDetailPresentation(order({ stage: "Posted" }))
		expect(field(isLabel, "Payment Status")).toBe("Posted")
		expect(field(isLabel, "Order Stage")).toBeUndefined()
	})

	it("spells out the booleans and ends with the Salesforce id", () => {
		const presentation = buildOrderDetailPresentation(
			order({ isClosed: true, isPaid: true, canPay: false, paymentStatus: "Paid" }),
		)
		expect(field(presentation, "Order Status")).toBe("Closed")
		expect(field(presentation, "Paid")).toBe("Yes")
		const open = buildOrderDetailPresentation(order())
		expect(field(open, "Order Status")).toBe("Open")
		expect(field(open, "Paid")).toBe("No")

		expect(presentation.detailFields[presentation.detailFields.length - 1]).toEqual({
			label: "Order ID",
			value: "006xx0000001",
		})
	})
})

describe("buildOrderDetailPresentation — callout and actions", () => {
	it("invites payment while the order can be paid online", () => {
		const presentation = buildOrderDetailPresentation(order())
		expect(presentation.callout?.tone).toBe("pending")
		expect(presentation.callout?.title).toBe("Payment due")
		expect(presentation.canPay).toBe(true)
		// REST has no canCancel — cancel is gated with canPay (GarpAppv1 parity).
		expect(presentation.canCancel).toBe(true)
	})

	it("points an open but unpayable order at the invoice", () => {
		const presentation = buildOrderDetailPresentation(order({ canPay: false }))
		expect(presentation.callout?.tone).toBe("warning")
		expect(presentation.callout?.title).toBe("Payment instructions")
		expect(presentation.canCancel).toBe(false)
	})

	it("explains a closed unpaid order", () => {
		const presentation = buildOrderDetailPresentation(
			order({ canPay: false, isClosed: true }),
		)
		expect(presentation.callout?.tone).toBe("neutral")
		expect(presentation.callout?.title).toBe("Order closed")
	})

	it("says nothing about a settled order", () => {
		const presentation = buildOrderDetailPresentation(
			order({ canPay: false, isClosed: true, isPaid: true, paymentStatus: "Paid" }),
		)
		expect(presentation.callout).toBeNull()
	})
})
