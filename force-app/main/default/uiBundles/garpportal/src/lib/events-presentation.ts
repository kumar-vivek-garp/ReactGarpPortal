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
	/** Short blurb for the card body; null when absent or just the title again. */
	description: string | null
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
 * Time rendered in the event's own timezone with its abbreviation — a range
 * ("2:00 – 4:00 PM EDT") when the payload carries a distinct end, otherwise
 * the start alone ("2:00 PM EDT").
 *
 * The organiser publishes a specific zone (`addToCalTimeZone`), so showing that
 * zone — labelled — matches what a member sees everywhere else GARP advertises
 * the event, rather than silently re-basing it to the browser's locale.
 */
export function eventTimeLabel(event: MemberEvent): string | null {
	if (!hasCalendarPayload(event)) return null
	const input = calendarEventFromMember(event)
	if (!input) return null
	const parsed = parseLocal(input)
	if (!parsed) return null

	try {
		const format = new Intl.DateTimeFormat(undefined, {
			hour: "numeric",
			minute: "2-digit",
			timeZone: input.timeZone,
			timeZoneName: "short",
		})
		// Range only within a single day — across days formatRange pulls full
		// dates into a line that already sits next to the date, saying it twice.
		// parseLocal defaults a missing end to the start, so "later than" also
		// covers "absent"; a zero-length range would just repeat the start.
		const sameDay = !input.endDate || input.endDate === input.startDate
		return sameDay && parsed.end.getTime() > parsed.start.getTime()
			? format.formatRange(parsed.start, parsed.end)
			: format.format(parsed.start)
	} catch {
		// An unrecognised IANA zone would throw; a missing time beats a wrong one.
		return null
	}
}

/** Weekday name for the hero's date block, e.g. "Wednesday". */
export function eventWeekday(iso: string | null | undefined): string | null {
	if (!iso) return null
	const [year, month, day] = iso.split("-").map(Number)
	if (!year || !month || !day) return null
	return new Date(year, month - 1, day).toLocaleDateString(undefined, {
		weekday: "long",
	})
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
	const title = event.eventName?.trim() || "Event"
	const dateLabel = formatLongDate(event.eventStartDate?.slice(0, 10))
	const timeLabel = eventTimeLabel(event)
	const timing = eventTiming(event.eventStartDate?.slice(0, 10))

	const metaLines: MetaLine[] = []
	if (dateLabel) {
		metaLines.push({
			icon: "when",
			text: timeLabel ? `${dateLabel} · ${timeLabel}` : dateLabel,
		})
	}

	// Location and description ship in the calendar payload as HTML; the
	// calendar builder is where they get cleaned, so reuse that rather than
	// re-stripping tags here.
	const calendar = calendarEventFromMember(event)
	const location = calendar?.location.trim()
	if (location) metaLines.push({ icon: "location", text: location })

	const blurb = calendar?.description.trim() ?? ""
	const description =
		blurb && blurb.toLowerCase() !== title.toLowerCase() ? blurb : null

	return {
		id: event.eventId,
		title,
		kind,
		typeLabel,
		statusLabel: options.isAttending ? "Attending" : null,
		statusTone: options.isAttending ? "success" : null,
		timingLabel: timing?.label ?? null,
		timingTone: timing?.tone ?? null,
		dateBadge: eventDateBadge(event.eventStartDate?.slice(0, 10)),
		description,
		metaLines,
		eventUrl: eventPageUrl(event.eventURL),
		attendanceUrl: event.canManageAttendance
			? manageAttendanceHref(event.eventId)
			: null,
		hasCalendar: hasCalendarPayload(event),
	}
}
