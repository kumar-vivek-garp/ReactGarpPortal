import type { PortalOrder } from "@/api/orders/types"
import { formatLongDate, formatMoney } from "@/lib/account-format"
import { orderStatusPresentation } from "@/lib/order-status"
import type { StatusTone } from "@/lib/status-tone"

const EM_DASH = "—"

export type OrderDetailField = {
	label: string
	value: string
}

export type OrderDetailCallout = {
	tone: "warning" | "pending" | "neutral"
	title: string
	body: string
}

export type OrderDetailPresentation = {
	title: string
	invoiceNumber: string | null
	amountLabel: string | null
	dateLabel: string | null
	statusLabel: string
	statusTone: StatusTone
	/** Primary facts for the summary strip. */
	summaryFields: OrderDetailField[]
	/** Full label/value list for the details card. */
	detailFields: OrderDetailField[]
	callout: OrderDetailCallout | null
	canPay: boolean
	/** REST has no canCancel — gate cancel with canPay (GarpAppv1 parity). */
	canCancel: boolean
	orderId: string
}

/**
 * Pure derivation for the order detail panel — every non-null PortalOrder field
 * the API returns is represented once, so list and detail stay aligned.
 */
export function buildOrderDetailPresentation(
	order: PortalOrder,
): OrderDetailPresentation {
	const { label: statusLabel, tone: statusTone } =
		orderStatusPresentation(order)

	const invoice = order.invoiceNumber?.trim() || null
	const description = order.description?.trim() || "GARP Order"
	const amountLabel = formatMoney(order.amount, order.currencyCode)
	const dateLabel = formatLongDate(order.orderDate)
	const stage = order.stage?.trim() || null
	const paymentMethod = order.paymentMethod?.trim() || null
	const paymentStatus = order.paymentStatus?.trim() || null

	const summaryFields: OrderDetailField[] = []
	if (dateLabel) summaryFields.push({ label: "Purchase Date", value: dateLabel })
	if (invoice) summaryFields.push({ label: "Invoice", value: invoice })
	if (paymentMethod) {
		summaryFields.push({ label: "Payment Method", value: paymentMethod })
	}

	const detailFields: OrderDetailField[] = [
		{ label: "Description", value: description },
		{ label: "Purchase Date", value: dateLabel ?? EM_DASH },
		{ label: "Amount", value: amountLabel ?? EM_DASH },
		{
			label: "Payment Status",
			value: paymentStatus ?? statusLabel,
		},
	]
	if (stage && stage !== paymentStatus && stage !== statusLabel) {
		detailFields.push({ label: "Order Stage", value: stage })
	}
	if (invoice) {
		detailFields.push({ label: "Invoice Number", value: invoice })
	}
	if (paymentMethod) {
		detailFields.push({ label: "Payment Method", value: paymentMethod })
	}
	detailFields.push({
		label: "Order Status",
		value: order.isClosed ? "Closed" : "Open",
	})
	detailFields.push({
		label: "Paid",
		value: order.isPaid ? "Yes" : "No",
	})
	// Salesforce Opportunity Id — useful for Member Services.
	detailFields.push({ label: "Order ID", value: order.id })

	let callout: OrderDetailCallout | null = null
	if (order.canPay) {
		callout = {
			tone: "pending",
			title: "Payment due",
			body: "Pay this order online, or download the invoice for alternate payment instructions.",
		}
	} else if (!order.canPay && !order.isClosed) {
		callout = {
			tone: "warning",
			title: "Payment instructions",
			body: "Please download your order to see instructions on how to make payment.",
		}
	} else if (order.isClosed && !order.isPaid) {
		callout = {
			tone: "neutral",
			title: "Order closed",
			body: "This order is closed and cannot be paid online. Download the invoice or contact Member Services if you need help.",
		}
	}

	return {
		title: description,
		invoiceNumber: invoice,
		amountLabel,
		dateLabel,
		statusLabel,
		statusTone,
		summaryFields,
		detailFields,
		callout,
		canPay: order.canPay,
		canCancel: order.canPay,
		orderId: order.id,
	}
}
