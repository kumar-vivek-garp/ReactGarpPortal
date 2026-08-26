import {
	BookOpen,
	CircleHelp,
	Inbox,
	LifeBuoy,
	Mail,
	TriangleAlert,
} from "lucide-react"
import type { LucideIcon } from "lucide-react"
import { z } from "zod"

/** Same inbox used by Study Materials and Order History. */
export const MEMBER_SERVICES_MAILTO =
	"mailto:memberservices@garp.com?Subject=Member%20portal%20support"

export const CONTACT_US_URL = "https://www.garp.org/about/contact-us"

export const HELP_CENTER_TABS = ["get-help", "requests"] as const

export type HelpCenterTab = (typeof HELP_CENTER_TABS)[number]

export const DEFAULT_HELP_CENTER_TAB: HelpCenterTab = "get-help"

export const helpCenterSearchSchema = z.object({
	tab: z.enum(HELP_CENTER_TABS).catch(DEFAULT_HELP_CENTER_TAB),
})

export type HelpCenterSearch = z.infer<typeof helpCenterSearchSchema>

export type HelpCenterBucketMeta = {
	label: string
	heading: string
	icon: LucideIcon
}

/**
 * One definition per tab, shared by the pills and the section headings — the
 * same pattern Programs / Study Materials / Events use.
 */
export const HELP_CENTER_BUCKET_META: Record<
	HelpCenterTab,
	HelpCenterBucketMeta
> = {
	"get-help": {
		label: "Get Help",
		heading: "Open a support case",
		icon: LifeBuoy,
	},
	requests: {
		label: "My Requests",
		heading: "My Requests",
		icon: Inbox,
	},
}

/** Requests tab with zero cases — rendered through the shared `EmptyState`. */
export const HELP_REQUESTS_EMPTY = {
	icon: Inbox,
	title: "You haven't raised any requests yet",
	message:
		"Anything you send using the form will be listed here with its status.",
} as const

/** Requests tab when the cases call fails — `EmptyState` with `tone="error"`. */
export const HELP_REQUESTS_ERROR = {
	icon: TriangleAlert,
	title: "We couldn't load your requests",
	message: "Please try again later.",
} as const

/** Tab bar items — derived from the bucket meta so labels/icons cannot drift. */
export const HELP_CENTER_TAB_ITEMS: Array<{
	value: HelpCenterTab
	label: string
	icon: LucideIcon
}> = HELP_CENTER_TABS.map((value) => ({
	value,
	label: HELP_CENTER_BUCKET_META[value].label,
	icon: HELP_CENTER_BUCKET_META[value].icon,
}))

export type HelpResourceLink = {
	title: string
	url: string
	icon: LucideIcon
	/** Grouped so contact routes read separately from self-serve reading. */
	group: "contact" | "faq"
}

export const HELP_RESOURCE_LINKS: readonly HelpResourceLink[] = [
	{
		title: "Email Member Services",
		url: MEMBER_SERVICES_MAILTO,
		icon: Mail,
		group: "contact",
	},
	{
		title: "Contact Us",
		url: CONTACT_US_URL,
		icon: CircleHelp,
		group: "contact",
	},
	{
		title: "FRM FAQs",
		url: "https://www.garp.org/frm/frequently-asked-questions",
		icon: BookOpen,
		group: "faq",
	},
	{
		title: "SCR FAQs",
		url: "https://www.garp.org/scr/frequently-asked-questions",
		icon: BookOpen,
		group: "faq",
	},
	{
		title: "RAI FAQs",
		url: "https://www.garp.org/rai/frequently-asked-questions",
		icon: BookOpen,
		group: "faq",
	},
] as const

export const HELP_RESOURCE_GROUPS = [
	{ key: "contact" as const, heading: "Contact Member Services" },
	{ key: "faq" as const, heading: "Browse FAQs" },
] as const
