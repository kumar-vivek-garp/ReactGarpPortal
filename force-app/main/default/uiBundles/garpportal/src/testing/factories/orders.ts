import type { PortalOrder } from "@/api/orders/types"

/** An unpaid, payable order row — override for the paid/closed variants. */
export function portalOrder(overrides: Partial<PortalOrder> = {}): PortalOrder {
	return {
		id: "006xx1",
		invoiceNumber: "INV-0001",
		description: "FRM Part I Exam",
		orderDate: "2026-01-15",
		amount: 750,
		currencyCode: "USD",
		stage: "New Lead",
		paymentStatus: "Unpaid",
		paymentMethod: null,
		isPaid: false,
		isClosed: false,
		canPay: true,
		...overrides,
	}
}
