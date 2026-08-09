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
