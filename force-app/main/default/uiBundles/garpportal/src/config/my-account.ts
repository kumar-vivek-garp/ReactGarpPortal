import { BellRing, ReceiptText, UserRound } from "lucide-react"
import type { LucideIcon } from "lucide-react"
import { z } from "zod"

import { ORDER_FILTERS } from "@/config/order-history"

export { AUTO_RENEW_SETUP_COMPLETE_STATUS } from "@/config/membership-account"

export const MY_ACCOUNT_TABS = [
	"account-information",
	"contact-preferences",
	"order-history",
] as const

export type MyAccountTab = (typeof MY_ACCOUNT_TABS)[number]

export const DEFAULT_MY_ACCOUNT_TAB: MyAccountTab = "account-information"

export const myAccountSearchSchema = z.object({
	tab: z.enum(MY_ACCOUNT_TABS).catch(DEFAULT_MY_ACCOUNT_TAB),
	status: z.string().optional(),
	/**
	 * Order History bucket filter. Optional + `catch(undefined)` so an absent
	 * value stays distinguishable from an explicit one, matching
	 * `programsSearchSchema` — the panel picks the default itself.
	 */
	orders: z.enum(ORDER_FILTERS).optional().catch(undefined),
})

export type MyAccountSearch = z.infer<typeof myAccountSearchSchema>

/** Tab bar items — shared by the my-account panel and its pending shell. */
export const MY_ACCOUNT_TAB_ITEMS: Array<{
	value: MyAccountTab
	label: string
	icon: LucideIcon
}> = [
	{ value: "account-information", label: "Account Information", icon: UserRound },
	{ value: "contact-preferences", label: "Contact Preferences", icon: BellRing },
	{ value: "order-history", label: "Order History", icon: ReceiptText },
]
