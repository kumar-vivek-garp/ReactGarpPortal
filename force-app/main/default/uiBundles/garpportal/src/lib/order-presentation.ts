import type { PortalOrder } from "@/api/orders/types"
import { formatLongDate, formatMoney } from "@/lib/account-format"
import type { MetaLine } from "@/lib/meta-line"
import { orderStatusPresentation } from "@/lib/order-status"
import type { StatusTone } from "@/lib/status-tone"

/**
 * Pure derivation for Order History — same split as `order-status.ts` and
 * `program-listing-presentation.ts`, so the row, the summary bar and the search
 * can never disagree about what an order says.
 */

/* -------------------------------------------------------------------------- */
/* Search                                                                     */
/* -------------------------------------------------------------------------- */

/**
 * Client-side filter over every field the row actually shows, so a member can
 * search for anything they can see — including the formatted date and amount
 * rather than only their raw values.
 */
export function orderMatches(order: PortalOrder, term: string): boolean {
	if (!term) return true
	const needle = term.toLowerCase()
	return [
		order.invoiceNumber,
		order.description,
		order.paymentStatus,
		order.paymentMethod,
		order.stage,
		formatLongDate(order.orderDate),
		order.amount == null ? null : String(order.amount),
		formatMoney(order.amount, order.currencyCode),
	]
		.filter(Boolean)
		.some((field) => String(field).toLowerCase().includes(needle))
}

/* -------------------------------------------------------------------------- */
/* Summary                                                                    */
/* -------------------------------------------------------------------------- */

export type OutstandingTotal = {
	/** ISO code, or null when Apex sent an amount with no currency. */
	currency: string | null
	total: number
	formatted: string
}

export type OrdersSummary = {
	/**
	 * One entry per currency. Never a single cross-currency total — orders carry
	 * their own `currencyCode`, so summing them together would invent a number.
	 */
	outstanding: OutstandingTotal[]
	/** Whether anything is actually payable, which gates the Pay CTA. */
	hasPayable: boolean
	unpaidCount: number
	paidCount: number
	totalCount: number
}

/**
 * Outstanding counts only orders where `canPay` is true.
 *
 * The unpaid bucket also holds closed-but-not-paid orders — refunded, void,
 * written off — which Apex marks `canPay: false`. Those are not money the member
 * owes, so folding them into a balance would overstate it.
 */
export function summarizeOrders(
	unpaidOrders: PortalOrder[],
	paidOrders: PortalOrder[],
): OrdersSummary {
	const payable = unpaidOrders.filter(
		(order) => order.canPay && order.amount != null,
	)

	const byCurrency = new Map<string | null, number>()
	for (const order of payable) {
		const key = order.currencyCode ?? null
		byCurrency.set(key, (byCurrency.get(key) ?? 0) + (order.amount ?? 0))
	}

	const outstanding: OutstandingTotal[] = [...byCurrency.entries()]
		.map(([currency, total]) => ({
			currency,
			total,
			formatted: formatMoney(total, currency) ?? String(total),
		}))
		.sort((a, b) => b.total - a.total)

	return {
		outstanding,
		hasPayable: unpaidOrders.some((order) => order.canPay),
		unpaidCount: unpaidOrders.length,
		paidCount: paidOrders.length,
		totalCount: unpaidOrders.length + paidOrders.length,
	}
}

/* -------------------------------------------------------------------------- */
/* Row                                                                        */
/* -------------------------------------------------------------------------- */

export type OrderRowPresentation = {
	description: string
	amountLabel: string
	metaLines: MetaLine[]
	statusLabel: string
	statusTone: StatusTone
	canPay: boolean
}

const EM_DASH = "—"

export function buildOrderRowPresentation(
	order: PortalOrder,
): OrderRowPresentation {
	const { label: statusLabel, tone: statusTone } = orderStatusPresentation(order)

	const metaLines: MetaLine[] = []
	if (order.invoiceNumber) {
		metaLines.push({ icon: "invoice", text: order.invoiceNumber })
	}
	const dateLabel = formatLongDate(order.orderDate)
	if (dateLabel) metaLines.push({ icon: "when", text: dateLabel })
	if (order.paymentMethod) {
		metaLines.push({ icon: "paymentMethod", text: order.paymentMethod })
	}

	return {
		description: order.description ?? "GARP Order",
		amountLabel: formatMoney(order.amount, order.currencyCode) ?? EM_DASH,
		metaLines,
		statusLabel,
		statusTone,
		canPay: order.canPay,
	}
}
