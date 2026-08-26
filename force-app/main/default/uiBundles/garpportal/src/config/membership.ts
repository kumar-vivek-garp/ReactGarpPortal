import { BadgeCheck } from "lucide-react"
import type { LucideIcon } from "lucide-react"
import { z } from "zod"

import { LIST_VIEWS, type ListView } from "@/config/list-view"

export const MEMBERSHIP_TABS = ["benefits", "directory"] as const

export type MembershipTab = (typeof MEMBERSHIP_TABS)[number]

export const DEFAULT_MEMBERSHIP_TAB: MembershipTab = "benefits"

/**
 * `view` is optional so an *absent* value stays distinguishable from an explicit
 * one — that difference is what lets a remembered choice apply (same contract as
 * the Programs and Study Materials pages).
 */
export const membershipSearchSchema = z.object({
	tab: z.enum(MEMBERSHIP_TABS).catch(DEFAULT_MEMBERSHIP_TAB),
	view: z.enum(LIST_VIEWS).optional().catch(undefined),
})

export type MembershipSearch = z.infer<typeof membershipSearchSchema>

/**
 * Precedence: explicit `?view=`, then the remembered choice, then grid.
 *
 * Grid is the default because benefits carry artwork and blurbs that sell the
 * benefit while browsing; list earns its place when scanning for one by name.
 */
export function resolveMembershipView(
	view: ListView | undefined,
	preferred?: ListView | null,
): ListView {
	if (view) return view
	if (preferred) return preferred
	return "grid"
}

/** Tab bar items — shared by the membership panel and its pending shell. */
export const MEMBERSHIP_TAB_ITEMS: Array<{
	value: MembershipTab
	label: string
}> = [
	{ value: "benefits", label: "Member Benefits" },
	{ value: "directory", label: "Member Directory" },
]

export type MembershipEmptyMeta = {
	icon: LucideIcon
	title: string
	message: string
}

/** Empty state for the benefits tab — same dashed-panel identity as Programs. */
export const MEMBERSHIP_BENEFITS_EMPTY: MembershipEmptyMeta = {
	icon: BadgeCheck,
	title: "No benefits published yet",
	message:
		"Membership benefits appear here once GARP publishes them. Check back soon.",
}
