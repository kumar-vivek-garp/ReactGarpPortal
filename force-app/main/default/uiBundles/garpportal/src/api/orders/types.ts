import type { MemberPortalEnvelope } from "@/api/account/types"

/**
 * Types mirroring GARP_MemberPortal_Programs PortalOrder / OrdersView.
 */

export type PortalOrder = {
	id: string
	invoiceNumber: string | null
	description: string | null
	/** ISO date (yyyy-MM-dd) or null. */
	orderDate: string | null
	amount: number | null
	currencyCode: string | null
	stage: string | null
	paymentStatus: string | null
	paymentMethod: string | null
	isPaid: boolean
	isClosed: boolean
	canPay: boolean
}

export type OrdersView = {
	unpaidOrders: PortalOrder[]
	paidOrders: PortalOrder[]
}

/** Inner result for orderDetail / payOrder / cancelOrder (statusCode lives here too). */
export type PortalResult = {
	statusMessage: string | null
	statusCode: number
}

/** `GET orderDetail` payload — same summary shape as list rows. */
export type OrderDetailView = PortalResult & {
	order: PortalOrder | null
}

/** `POST orderCheckout` body. */
export type OrderCheckoutRequest = {
	/** An Opportunity id OR a staged Order_History__c id — `payableId` resolves either. */
	orderId: string
	successUrl: string
	cancelUrl: string
}

/** `POST orderCheckout` — already validated to carry a hosted checkout URL. */
export type OrderCheckoutResult = {
	checkoutUrl: string
	orderNumber: string | null
}

export type { MemberPortalEnvelope }
