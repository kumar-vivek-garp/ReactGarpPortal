import { CalendarDays, MonitorPlay, Users } from "lucide-react"
import type { LucideIcon } from "lucide-react"
import { z } from "zod"

// Type-only: a runtime import here would close a cycle, since
// events-presentation.ts imports manageAttendanceHref from this file.
import type { EventKind } from "@/lib/events-presentation"

/**
 * Values deliberately equal `EventKind`, so applying the filter is
 * `eventKind(event.eventType) === type` with no mapping layer between.
 */
export const EVENT_TYPE_FILTERS = ["event", "webcast", "chapter"] as const

export type EventTypeFilter = (typeof EVENT_TYPE_FILTERS)[number]

/**
 * The page has no tabs: an "up next" hero plus one grid, narrowed by `?type=`.
 * Legacy `?tab=` URLs still resolve — zod strips the unknown key silently.
 * Optional so an absent value stays distinguishable from an explicit one —
 * absent means "all types", and never appears in the URL.
 */
export const eventsSearchSchema = z.object({
	type: z.enum(EVENT_TYPE_FILTERS).optional().catch(undefined),
})

export type EventsSearch = z.infer<typeof eventsSearchSchema>


export type EventTypeMeta = {
	/** Filter-bar label (plural). */
	label: string
	/** Lowercase noun for filtered-empty copy: "No webcasts here". */
	noun: string
	icon: LucideIcon
	/**
	 * Tinted chip for the card's type badge. Written out in full because
	 * Tailwind's scanner cannot see composed class names (see program-brand.ts).
	 */
	chip: string
}

/**
 * One identity per event type, shared by the card badge, the type dropdown
 * and the filtered-empty state, so a type looks the same wherever it appears.
 *
 * Hues are the brand tokens the program map leaves unclaimed: corporate-navy
 * for flagship GARP events, vermillion's "on-air" warmth for webcasts, and
 * green's community connotation for chapter meetings. All are /15 washes with
 * `text-foreground`, so type is never encoded by color alone — the icon and
 * label carry it too.
 */
export const EVENT_TYPE_META: Record<EventKind, EventTypeMeta> = {
	event: {
		label: "Events",
		noun: "events",
		icon: CalendarDays,
		chip: "border-transparent bg-corporate-navy/15 text-foreground",
	},
	webcast: {
		label: "Webcasts",
		noun: "webcasts",
		icon: MonitorPlay,
		chip: "border-transparent bg-accent-vermillion/15 text-foreground",
	},
	chapter: {
		label: "Chapter Meetings",
		noun: "chapter meetings",
		icon: Users,
		chip: "border-transparent bg-erp-green/15 text-foreground",
	},
}

/** Type-filter bar items — broadest first, mirroring the eventKind fallback. */
export const EVENT_TYPE_FILTER_ITEMS: Array<{
	value: EventTypeFilter
	label: string
	icon: LucideIcon
}> = EVENT_TYPE_FILTERS.map((value) => ({
	value,
	label: EVENT_TYPE_META[value].label,
	icon: EVENT_TYPE_META[value].icon,
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
