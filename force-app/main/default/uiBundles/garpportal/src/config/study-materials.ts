import { BookMarked, BookOpen, ShieldOff } from "lucide-react"
import { z } from "zod"

import { LIST_VIEWS, type ListView } from "@/config/list-view"
import { looseSearchString } from "@/config/registration"

/** Default program tab — shows the full catalogue. */
export const DEFAULT_STUDY_MATERIALS_TAB = "all"

/**
 * Program filter synced to `?tab=`. Values are `"all"` or a live program `key`
 * from the API (dynamic), so we accept any non-empty string and normalize
 * unknowns after data loads.
 *
 * `view` is optional so an *absent* value stays distinguishable from an explicit
 * one — that difference is what lets a remembered choice apply.
 *
 * `purchased` is the payment provider's success return from the purchase
 * page (`/study-materials?purchased=1`). It has to survive the router's
 * JSON-parse of search values — `1` arrives as a number — which is what
 * `looseSearchString` is for.
 */
export const studyMaterialsSearchSchema = z.object({
	tab: z.string().min(1).catch(DEFAULT_STUDY_MATERIALS_TAB),
	view: z.enum(LIST_VIEWS).optional().catch(undefined),
	purchased: looseSearchString(),
})

export type StudyMaterialsSearch = z.infer<typeof studyMaterialsSearchSchema>

/** Search params the purchase page accepts — the provider's cancel leg. */
export const materialPurchaseSearchSchema = z.object({
	checkout_cancelled: looseSearchString(),
})

export type MaterialPurchaseSearch = z.infer<typeof materialPurchaseSearchSchema>

/**
 * Precedence: explicit `?view=`, then the remembered choice, then grid.
 *
 * Grid is the default because this page is primarily a catalogue — artwork and
 * blurbs carry meaning while browsing. List earns its place when scanning many
 * items for a specific one.
 */
export function resolveStudyMaterialsView(
	view: ListView | undefined,
	preferred?: ListView | null,
): ListView {
	if (view) return view
	if (preferred) return preferred
	return "grid"
}

export const STUDY_MATERIALS_TITLE = "Study Materials for Risk Professionals"

/** Nothing published for any programme the member is registered for. */
export const STUDY_MATERIALS_EMPTY = {
	icon: BookOpen,
	title: "No study materials for your programs yet",
	message:
		"Materials appear here once they are published for a program you are registered for.",
} as const

/**
 * `GARP_Portal_Access.verify` refused — no membership contract. The message
 * is the server's own when it sends one.
 */
export const STUDY_MATERIALS_DENIED = {
	icon: ShieldOff,
	title: "Study materials are for members",
	fallbackMessage:
		"We couldn't confirm your membership. Please contact member services.",
} as const

/** The per-programme errata link on the listing. */
export const STUDY_MATERIALS_ERRATA_LABEL = "Report an error"

/** The archive entry point, shown only to members who hold an eBook key. */
export const STUDY_MATERIALS_ARCHIVE_LABEL = "My eBook links"

/** Toasted once when the provider returns to the listing with `?purchased=1`. */
export const PURCHASE_SUCCESS_NOTICE = {
	title: "Purchase complete",
	description: "Thank you — your study materials have been updated.",
} as const

/** The purchased-materials archive (`/study-materials/archive`). */
export const EBOOK_ARCHIVE = {
	icon: BookMarked,
	title: "Purchased Study Materials",
	emptyTitle: "No purchased materials yet",
	emptyMessage:
		"eBooks you buy appear here, grouped by edition. Nothing has been purchased on this account.",
} as const

/** The purchase page (`/study-materials/purchase/$productCode`). */
export const STUDY_MATERIAL_PURCHASE = {
	title: "Complete your purchase",
	currency: "USD",
	itemHeading: "Your order",
	deliveryPrinted: "Printed book — posted to the address below.",
	deliveryOnline: "Delivered online — nothing to post.",
	summaryHeading: "Order summary",
	taxNote: "Tax is calculated by our payment provider at checkout.",
	shippingUnknown: "Calculated at checkout",
	addressHeading: "Shipping address",
	addressIntro:
		"This is a printed book. We have filled in the address on your record — change it here if it should go somewhere else.",
	addressIncomplete: "A street, city and country are needed to post a book.",
	countryChangedHint:
		"Shipping is charged per country — the final amount is confirmed at checkout.",
	cancelledTitle: "Payment cancelled",
	cancelledMessage:
		"Nothing has been charged. You can try again whenever you are ready.",
	unavailableTitle: "This item is not available to purchase",
	unavailableMessage:
		"It may already be yours, or no longer on sale. Everything available to you is on Study Materials.",
	errorTitle: "We couldn't load this purchase",
	/** The paid registration forms' own submit label — one checkout vocabulary. */
	payLabel: "Continue to Payment",
	payBusyLabel: "Opening payment…",
} as const
