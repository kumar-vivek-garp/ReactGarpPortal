import type { MemberPortalEnvelope } from "@/api/account/types"

export type EventType = "Event" | "Webcast" | "Chapter Meeting"

/** Listing row from `GARP_Portal_EventsService.MemberEventInfo`. */
export type MemberEvent = {
	eventId: string
	eventType: EventType | string
	eventName: string | null
	/** ISO date (`yyyy-MM-dd`). */
	eventStartDate: string | null
	eventSlug: string | null
	eventURL: string | null
	chapterId: string | null
	canManageAttendance: boolean
	addToCalTitle: string | null
	addToCalDescription: string | null
	addToCalStartDateTime: string | null
	addToCalEndDateTime: string | null
	addToCalTimeZone: string | null
	addToCalLocation: string | null
}

/** `GET /memberportal/events` view (`GARP_Portal_EventsService.EventsView`). */
export type EventsView = {
	statusMessage: string | null
	statusCode: number
	/** Attending — already registered, upcoming only. */
	registeredEvents: MemberEvent[]
	/** Upcoming meetings of the member's own chapters. */
	upcomingChapterMeetings: MemberEvent[]
	/** Other open meetings, events, and webcasts (featured / explore). */
	upcomingOtherEvents: MemberEvent[]
}

export type { MemberPortalEnvelope }
