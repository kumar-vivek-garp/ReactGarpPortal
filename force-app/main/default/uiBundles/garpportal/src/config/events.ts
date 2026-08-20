import { CalendarCheck, CalendarDays, Sparkles, Users } from "lucide-react"
import type { LucideIcon } from "lucide-react"
import { z } from "zod"

export const EVENTS_TABS = [
	"all",
	"attending",
	"chapter-meetings",
	"featured",
] as const

export type EventsTab = (typeof EVENTS_TABS)[number]

export const DEFAULT_EVENTS_TAB: EventsTab = "all"

export const eventsSearchSchema = z.object({
	tab: z.enum(EVENTS_TABS).catch(DEFAULT_EVENTS_TAB),
})

export type EventsSearch = z.infer<typeof eventsSearchSchema>


export type EventBucketMeta = {
	label: string
	heading: string
	icon: LucideIcon
	emptyTitle: string
	emptyMessage: string
}

/**
 * One definition per bucket, shared by the tab pills, the "All" section
 * headings and the empty states — the same pattern Programs and Study Materials
 * use, so a bucket looks the same wherever it appears.
 */
export const EVENT_BUCKET_META: Record<EventsTab, EventBucketMeta> = {
	all: {
		label: "All",
		heading: "All Events",
		icon: CalendarDays,
		emptyTitle: "No events to show",
		emptyMessage:
			"Your registrations and upcoming GARP events will appear here.",
	},
	attending: {
		label: "Attending",
		heading: "Attending",
		icon: CalendarCheck,
		emptyTitle: "You're not attending anything yet",
		emptyMessage:
			"Events you register for will show up here so you can keep track of what's next.",
	},
	"chapter-meetings": {
		label: "Chapter Meetings",
		heading: "Upcoming Chapter Meetings",
		icon: Users,
		emptyTitle: "No upcoming chapter meetings",
		emptyMessage:
			"Meetings from your chapters will appear here when they are scheduled.",
	},
	featured: {
		label: "Featured Events",
		heading: "Featured Events",
		icon: Sparkles,
		emptyTitle: "No featured events right now",
		emptyMessage:
			"Browse the full GARP calendar for conferences, webcasts, and more.",
	},
}

/** Tab bar items — derived from the bucket meta so labels/icons cannot drift. */
export const EVENT_TAB_ITEMS: Array<{
	value: EventsTab
	label: string
	icon: LucideIcon
}> = EVENTS_TABS.map((value) => ({
	value,
	label: EVENT_BUCKET_META[value].label,
	icon: EVENT_BUCKET_META[value].icon,
}))

/**
 * Legacy Experience Cloud attendance tool (same path MyGarp used).
 * Only render when Apex set `canManageAttendance`.
 */
export function manageAttendanceHref(
	eventId: string | null | undefined,
): string | null {
	const id = eventId?.trim()
	if (!id) return null
	return `/Login?start=chapterMeetingRegistrationsAttendance/${id}`
}
