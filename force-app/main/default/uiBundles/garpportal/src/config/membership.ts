import { z } from "zod"

export const MEMBERSHIP_TABS = ["benefits", "directory"] as const

export type MembershipTab = (typeof MEMBERSHIP_TABS)[number]

export const DEFAULT_MEMBERSHIP_TAB: MembershipTab = "benefits"

export const membershipSearchSchema = z.object({
	tab: z.enum(MEMBERSHIP_TABS).catch(DEFAULT_MEMBERSHIP_TAB),
})

export type MembershipSearch = z.infer<typeof membershipSearchSchema>
