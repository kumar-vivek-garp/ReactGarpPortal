import type { PortalOrder } from "@/api/orders/types"
import type { StatusTone } from "@/lib/status-tone"

/**
 * Status label + tone for one order.
 *
 * Pure so the label precedence is testable: Apex sends `paymentStatus`, `stage`,
 * `isPaid` and `canPay` semi-independently. Tones follow the same keyword style
 * as `case-status.ts` so known Payment_Status__c / StageName values
 * (Paid, Unpaid, Recurring, Stopped, Closed Lost, …) stay visually distinct.
 */

function toneForStatusText(text: string): StatusTone | null {
	const key = text.toLowerCase()

	// Terminal / cancelled states first — "Closed Lost" and "Stopped" must not
	// fall through to a generic unpaid yellow.
	if (
		key.includes("stop") ||
		key.includes("cancel") ||
		key.includes("void") ||
		key.includes("refund") ||
		key.includes("closed lost") ||
		key.includes("written off")
	) {
		return "danger"
	}

	// Active auto-renew / subscription intent.
	if (key.includes("recurring")) {
		return "info"
	}

	// Partial settlement is money still owed, not a success.
	if (key.includes("partial")) {
		return "warning"
	}

	if (
		key.includes("unpaid") ||
		key.includes("await") ||
		key.includes("due") ||
		key.includes("new lead") ||
		key.includes("draft") ||
		key === "open"
	) {
		return "warning"
	}

	if (
		(key.includes("paid") ||
			key.includes("settled") ||
			key.includes("complete")) &&
		!key.includes("unpaid")
	) {
		return "success"
	}

	return null
}

export function orderStatusPresentation(order: PortalOrder): {
	label: string
	tone: StatusTone
} {
	const paymentStatus = order.paymentStatus?.trim() ?? ""
	const stage = order.stage?.trim() ?? ""

	let label: string
	if (paymentStatus) {
		label = paymentStatus
	} else if (order.isPaid) {
		label = "Paid"
	} else if (stage) {
		label = stage
	} else if (order.canPay) {
		label = "Unpaid"
	} else {
		// Nothing payable and nothing paid — there is no status worth asserting.
		label = "—"
	}

	if (label === "—") {
		return { label, tone: "neutral" }
	}

	const fromText = toneForStatusText(label)
	if (fromText) {
		return { label, tone: fromText }
	}

	// Unknown Apex strings: lean on the boolean flags Apex already computed.
	if (order.isPaid) return { label, tone: "success" }
	if (order.canPay) return { label, tone: "warning" }
	if (order.isClosed) return { label, tone: "neutral" }
	return { label, tone: "neutral" }
}
