import type { MemberEvent } from "@/api/events"
import { manageAttendanceHref } from "@/config/events"
import { formatLongDate } from "@/lib/account-format"
import { daysUntil } from "@/lib/days-until"
import {
	calendarEventFromMember,
	hasCalendarPayload,
	parseLocal,
} from "@/lib/event-calendar"
import type { MetaLine } from "@/lib/meta-line"
import type { StatusTone } from "@/lib/status-tone"

/** Drives the card glyph. Kept as a key so this layer stays React-free. */
export type EventKind = "chapter" | "webcast" | "event"

export type EventPresentation = {
	id: string
	title: string
	kind: EventKind
	typeLabel: string
	/** "Attending" when the member has registered. */
	statusLabel: string | null
	statusTone: StatusTone | null
	/** Short relative timing, only when the event is imminent. */
	timingLabel: string | null
	timingTone: StatusTone | null
	/** Month/day block for the card's date tile. */
	dateBadge: { month: string; day: string } | null
	metaLines: MetaLine[]
	eventUrl: string | null
	attendanceUrl: string | null
	hasCalendar: boolean
}

/**
 * Only surface a countdown when it changes behaviour. Beyond a week the date
 * itself is the useful fact, and a chip on every card would stop meaning much.
 */
const IMMINENT_DAYS = 7

function isSafeHttpUrl(url: string | null | undefined): url is string {
	if (!url?.trim()) return false
	try {
		const parsed = new URL(url.trim())
		return parsed.protocol === "http:" || parsed.protocol === "https:"
	} catch {
		return false
	}
}

/**
 * Drop base catalogue paths with no vanity slug (`/event/`) — those land on a
 * generic index rather than this event.
 */
export function eventPageUrl(url: string | null | undefined): string | null {
	if (!isSafeHttpUrl(url)) return null
	const path = new URL(url.trim()).pathname.replace(/\/+$/, "")
	return path.split("/").filter(Boolean).length >= 2 ? url.trim() : null
}

export function eventKind(type: string | null | undefined): EventKind {
	const normalized = type?.toLowerCase() ?? ""
	if (normalized.includes("chapter")) return "chapter"
	if (normalized.includes("webcast")) return "webcast"
	return "event"
}

export function eventDateBadge(
	iso: string | null | undefined,
): { month: string; day: string } | null {
	if (!iso) return null
	const [year, month, day] = iso.split("-").map(Number)
	if (!year || !month || !day) return null
	return {
		month: new Date(year, month - 1, day).toLocaleDateString(undefined, {
			month: "short",
		}),
		day: String(day),
	}
}

/**
 * Start time rendered in the event's own timezone with its abbreviation, e.g.
 * "2:00 PM EDT".
 *
 * The organiser publishes a specific zone (`addToCalTimeZone`), so showing that
 * zone — labelled — matches what a member sees everywhere else GARP advertises
 * the event, rather than silently re-basing it to the browser's locale.
 */
export function eventStartTimeLabel(event: MemberEvent): string | null {
	if (!hasCalendarPayload(event)) return null
	const input = calendarEventFromMember(event)
	if (!input) return null
	const parsed = parseLocal(input)
	if (!parsed) return null

	try {
		return new Intl.DateTimeFormat(undefined, {
			hour: "numeric",
			minute: "2-digit",
			timeZone: input.timeZone,
			timeZoneName: "short",
		}).format(parsed.start)
	} catch {
		// An unrecognised IANA zone would throw; a missing time beats a wrong one.
		return null
	}
}

/** Relative timing for imminent events only. */
export function eventTiming(
	iso: string | null | undefined,
): { label: string; tone: StatusTone } | null {
	if (!iso) return null
	const remaining = daysUntil(iso)
	if (remaining === null || remaining < 0 || remaining > IMMINENT_DAYS) {
		return null
	}
	if (remaining === 0) return { label: "Today", tone: "warning" }
	if (remaining === 1) return { label: "Tomorrow", tone: "warning" }
	return { label: `In ${remaining} days`, tone: "info" }
}

/**
 * Maps one listing event into everything the card renders.
 *
 * Pure — no React, no DOM. Location and start time already arrive in the payload
 * but were previously only fed to the Add-to-Calendar builder and never shown.
 */
export function buildEventPresentation(
	event: MemberEvent,
	options: { isAttending?: boolean } = {},
): EventPresentation {
	const kind = eventKind(event.eventType)
	const typeLabel = event.eventType?.trim() || "Event"
	const dateLabel = formatLongDate(event.eventStartDate?.slice(0, 10))
	const timeLabel = eventStartTimeLabel(event)
	const timing = eventTiming(event.eventStartDate?.slice(0, 10))

	const metaLines: MetaLine[] = []
	if (dateLabel) {
		metaLines.push({
			icon: "when",
			text: timeLabel ? `${dateLabel} · ${timeLabel}` : dateLabel,
		})
	}

	// Location ships in the calendar payload as HTML; the calendar builder is
	// where it gets cleaned, so reuse that rather than re-stripping tags here.
	const location = calendarEventFromMember(event)?.location.trim()
	if (location) metaLines.push({ icon: "location", text: location })

	return {
		id: event.eventId,
		title: event.eventName?.trim() || "Event",
		kind,
		typeLabel,
		statusLabel: options.isAttending ? "Attending" : null,
		statusTone: options.isAttending ? "success" : null,
		timingLabel: timing?.label ?? null,
		timingTone: timing?.tone ?? null,
		dateBadge: eventDateBadge(event.eventStartDate?.slice(0, 10)),
		metaLines,
		eventUrl: eventPageUrl(event.eventURL),
		attendanceUrl: event.canManageAttendance
			? manageAttendanceHref(event.eventId)
			: null,
		hasCalendar: hasCalendarPayload(event),
	}
}
