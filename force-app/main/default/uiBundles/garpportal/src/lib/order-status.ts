import type { PortalOrder } from "@/api/orders/types"
import type { StatusTone } from "@/lib/status-tone"

/**
 * Status label + tone for one order.
 *
 * Pure so the label precedence is testable: Apex sends `paymentStatus`, `stage`,
 * `isPaid` and `canPay` semi-independently, and the display used to pick between
 * them inline inside the component.
 */
export function orderStatusPresentation(order: PortalOrder): {
	label: string
	tone: StatusTone
} {
	const tone: StatusTone = order.isPaid ? "success" : "warning"

	if (order.paymentStatus?.trim()) {
		return { label: order.paymentStatus.trim(), tone }
	}
	if (order.isPaid) return { label: "Paid", tone }
	if (order.stage?.trim()) return { label: order.stage.trim(), tone }
	// Nothing payable and nothing paid — there is no status worth asserting.
	return order.canPay
		? { label: "Unpaid", tone }
		: { label: "—", tone: "neutral" }
}
