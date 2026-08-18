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

/** Tab bar items — shared by the events panel and its pending shell. */
export const EVENT_TAB_ITEMS: Array<{
	value: EventsTab
	label: string
	icon: LucideIcon
}> = [
	{ value: "all", label: "All", icon: CalendarDays },
	{ value: "attending", label: "Attending", icon: CalendarCheck },
	{ value: "chapter-meetings", label: "Chapter Meetings", icon: Users },
	{ value: "featured", label: "Featured Events", icon: Sparkles },
]

/** Public GARP catalogue — listing CTA, always a new tab. */
export const SEE_ALL_EVENTS_URL = "https://www.garp.org/events/all"

/** In-app account page where preferred chapters are shown. */
export const SET_CHAPTER_HREF = "/my-account?tab=account-information"

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
