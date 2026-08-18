import { z } from "zod"

export const MY_ACCOUNT_TABS = [
	"account-information",
	"contact-preferences",
	"order-history",
] as const

export type MyAccountTab = (typeof MY_ACCOUNT_TABS)[number]

export const DEFAULT_MY_ACCOUNT_TAB: MyAccountTab = "account-information"

export const myAccountSearchSchema = z.object({
	tab: z.enum(MY_ACCOUNT_TABS).catch(DEFAULT_MY_ACCOUNT_TAB),
})

export type MyAccountSearch = z.infer<typeof myAccountSearchSchema>

/** Tab bar items — shared by the my-account panel and its pending shell. */
export const MY_ACCOUNT_TAB_ITEMS: Array<{
	value: MyAccountTab
	label: string
}> = [
	{ value: "account-information", label: "Account Information" },
	{ value: "contact-preferences", label: "Contact Preferences" },
	{ value: "order-history", label: "Order History" },
]
