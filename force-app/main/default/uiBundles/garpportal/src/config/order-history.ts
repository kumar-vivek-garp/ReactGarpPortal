import { CircleCheck, Clock, ReceiptText } from "lucide-react"
import type { LucideIcon } from "lucide-react"

/**
 * Order History filter vocabulary — the my-account analogue of
 * `PROGRAM_BUCKET_META`. The panel and its pending shell both read from here so
 * labels, counts and section copy cannot drift apart.
 */

export const ORDER_FILTERS = ["all", "unpaid", "paid"] as const

export type OrderFilter = (typeof ORDER_FILTERS)[number]

export const DEFAULT_ORDER_FILTER: OrderFilter = "all"

/** Legacy invoice PDF Visualforce page — same as garpApp2 `downloadOrder`. */
export const INVOICE_PDF_PATH = "/apex/InvoicePrintAsPDF"

/** Hosted Stripe checkout for unpaid orders (legacy `regType=orders`). */
export const ORDERS_STRIPE_CHECKOUT_PATH = "/stripe_checkout"

const CHECKOUT_SESSION_COOKIE = "garp-checkout-session-token"
const CHECKOUT_SESSION_MINUTES = 20

/** Invoice PDF URL for an Opportunity Id. */
export function invoicePdfUrl(orderId: string): string {
	return `${INVOICE_PDF_PATH}?id=${encodeURIComponent(orderId.trim())}`
}

/** Matches garpApp2: `/stripe_checkout?regType=orders&id=` + orderId. */
export function stripeOrdersCheckoutUrl(orderId: string): string {
	return `${ORDERS_STRIPE_CHECKOUT_PATH}?regType=orders&id=${encodeURIComponent(orderId.trim())}`
}

/**
 * Legacy checkout cookie so Stripe can restore session context after redirect.
 * Value shape: `orders:{orderId}`, TTL 20 minutes.
 */
export function setOrdersCheckoutSessionCookie(orderId: string): void {
	const id = orderId.trim()
	if (!id || typeof document === "undefined") return
	const maxAge = CHECKOUT_SESSION_MINUTES * 60
	document.cookie = `${CHECKOUT_SESSION_COOKIE}=${encodeURIComponent(`orders:${id}`)}; path=/; max-age=${maxAge}; SameSite=Lax`
}

/** The two buckets Apex splits orders into. `all` renders both, in this order. */
export const ORDER_SECTIONS = ["unpaid", "paid"] as const

export type OrderSection = (typeof ORDER_SECTIONS)[number]

type OrderSectionMeta = {
	heading: string
	icon: LucideIcon
	/** Shown when the bucket is genuinely empty. */
	emptyTitle: string
	emptyMessage: string
	/** Shown when a search term hid everything in the bucket. */
	searchEmptyTitle: string
}

export const ORDER_SECTION_META: Record<OrderSection, OrderSectionMeta> = {
	unpaid: {
		heading: "Unpaid Purchases",
		icon: Clock,
		emptyTitle: "No unpaid purchases",
		emptyMessage: "Anything awaiting payment will appear here.",
		searchEmptyTitle: "No unpaid purchases match your search",
	},
	paid: {
		heading: "Paid Purchases",
		icon: CircleCheck,
		emptyTitle: "No paid purchases",
		emptyMessage: "Completed purchases will appear here once they settle.",
		searchEmptyTitle: "No paid purchases match your search",
	},
}

/** Filter buttons, in bar order. Counts are supplied by the panel at render. */
export const ORDER_FILTER_ITEMS: Array<{
	value: OrderFilter
	label: string
}> = [
	{ value: "all", label: "All" },
	{ value: "unpaid", label: "Unpaid" },
	{ value: "paid", label: "Paid" },
]

/** Which buckets a filter renders. `all` keeps the unpaid-first order. */
export const ORDER_FILTER_SECTIONS: Record<OrderFilter, readonly OrderSection[]> =
	{
		all: ORDER_SECTIONS,
		unpaid: ["unpaid"],
		paid: ["paid"],
	}

/** Whole-tab zero state — no orders at all, before any filtering. */
export const ORDERS_ZERO_STATE = {
	icon: ReceiptText,
	title: "No orders yet",
	message:
		"Exam registrations, membership, and event purchases appear here with their invoice numbers.",
} as const
