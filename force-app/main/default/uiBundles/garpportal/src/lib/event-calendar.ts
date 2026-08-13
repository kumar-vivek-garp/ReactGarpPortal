import type { MemberEvent } from "@/api/events"

/** Matches MyGarp CalendarService / Apex `yyyy-MM-dd h:mm a`. */
const DEFAULT_TIME_ZONE = "America/New_York"
const STAMP = /^(\d{4}-\d{2}-\d{2})\s+(.+)$/

export type CalendarProvider = "google" | "apple" | "microsoft365" | "ics"

export type CalendarEventInput = {
	name: string
	description: string
	location: string
	startDate: string
	startTime: string
	endDate: string
	endTime: string
	timeZone: string
}

export function hasCalendarPayload(
	event: Pick<MemberEvent, "addToCalStartDateTime">,
): boolean {
	return Boolean(event.addToCalStartDateTime?.trim())
}

export function calendarEventFromMember(
	event: MemberEvent,
): CalendarEventInput | null {
	const start = splitStamp(event.addToCalStartDateTime)
	if (!start) return null

	const end = splitStamp(event.addToCalEndDateTime) ?? start
	const input: CalendarEventInput = {
		name: event.addToCalTitle?.trim() || event.eventName?.trim() || "Event",
		description: calendarPlainText(event.addToCalDescription),
		location: calendarPlainText(event.addToCalLocation),
		startDate: start.date,
		startTime: start.time,
		endDate: end.date,
		endTime: end.time,
		timeZone: event.addToCalTimeZone?.trim() || DEFAULT_TIME_ZONE,
	}

	return parseLocal(input) ? input : null
}

export function openCalendar(
	provider: CalendarProvider,
	event: CalendarEventInput,
): void {
	if (provider === "apple" || provider === "ics") {
		downloadIcs(event)
		return
	}

	const url =
		provider === "google" ? buildGoogleUrl(event) : buildMicrosoft365Url(event)
	if (url) window.open(url, "_blank", "noopener,noreferrer")
}

export function buildGoogleUrl(event: CalendarEventInput): string {
	const range = parseLocal(event)
	if (!range) return ""

	const u = new URL("https://calendar.google.com/calendar/render")
	u.searchParams.set("action", "TEMPLATE")
	u.searchParams.set("text", event.name || "Event")
	if (event.description) u.searchParams.set("details", event.description)
	if (event.location) u.searchParams.set("location", event.location)
	u.searchParams.set(
		"dates",
		`${utcStamp(range.start)}/${utcStamp(range.end)}`,
	)
	u.searchParams.set("ctz", event.timeZone || DEFAULT_TIME_ZONE)
	return u.toString()
}

export function buildMicrosoft365Url(event: CalendarEventInput): string {
	const range = parseLocal(event)
	if (!range) return ""

	const u = new URL("https://outlook.office.com/calendar/0/deeplink/compose")
	u.searchParams.set("subject", event.name || "Event")
	u.searchParams.set("startdt", range.start.toISOString())
	u.searchParams.set("enddt", range.end.toISOString())
	if (event.description) u.searchParams.set("body", event.description)
	if (event.location) u.searchParams.set("location", event.location)
	return u.toString()
}

export function buildIcs(event: CalendarEventInput): string {
	const range = parseLocal(event)
	if (!range) return ""

	const uid =
		typeof crypto !== "undefined" && "randomUUID" in crypto
			? crypto.randomUUID()
			: `${Date.now()}`

	return [
		"BEGIN:VCALENDAR",
		"VERSION:2.0",
		"PRODID:-//GARP//Calendar//EN",
		"CALSCALE:GREGORIAN",
		"METHOD:PUBLISH",
		"BEGIN:VEVENT",
		`UID:${uid}@garp.org`,
		`DTSTAMP:${utcStamp(new Date())}`,
		`DTSTART:${utcStamp(range.start)}`,
		`DTEND:${utcStamp(range.end)}`,
		"STATUS:CONFIRMED",
		"TRANSP:OPAQUE",
		`SUMMARY:${icsEscape(event.name || "Event")}`,
		event.description ? `DESCRIPTION:${icsEscape(event.description)}` : "",
		event.location ? `LOCATION:${icsEscape(event.location)}` : "",
		"END:VEVENT",
		"END:VCALENDAR",
	]
		.filter(Boolean)
		.join("\r\n")
}

export function utcStamp(date: Date): string {
	const y = date.getUTCFullYear()
	const m = String(date.getUTCMonth() + 1).padStart(2, "0")
	const d = String(date.getUTCDate()).padStart(2, "0")
	const h = String(date.getUTCHours()).padStart(2, "0")
	const min = String(date.getUTCMinutes()).padStart(2, "0")
	const s = String(date.getUTCSeconds()).padStart(2, "0")
	return `${y}${m}${d}T${h}${min}${s}Z`
}

export function parseLocal(
	event: CalendarEventInput,
): { start: Date; end: Date } | null {
	const start = zonedDateTime(
		event.startDate,
		event.startTime,
		event.timeZone,
	)
	const end = zonedDateTime(
		event.endDate || event.startDate,
		event.endTime || event.startTime,
		event.timeZone,
	)
	if (!start || !end) return null
	return { start, end }
}

function downloadIcs(event: CalendarEventInput): void {
	const ics = buildIcs(event)
	if (!ics) return

	const blob = new Blob([ics], { type: "text/calendar;charset=utf-8" })
	const url = URL.createObjectURL(blob)
	const link = document.createElement("a")
	link.href = url
	link.download = `${(event.name || "Event").replace(/[^\w.-]+/g, "_")}.ics`
	document.body.appendChild(link)
	link.click()
	document.body.removeChild(link)
	URL.revokeObjectURL(url)
}

function splitStamp(
	value: string | null | undefined,
): { date: string; time: string } | null {
	if (!value) return null
	const match = value.trim().match(STAMP)
	if (!match) return null
	return { date: match[1], time: match[2].trim() }
}

function parseClock(time: string): { hour: number; minute: number } | null {
	const ampm = time.match(/^(\d{1,2}):(\d{2})\s*(AM|PM)$/i)
	if (ampm) {
		let hour = Number(ampm[1])
		const minute = Number(ampm[2])
		const period = ampm[3].toUpperCase()
		if (period === "PM" && hour < 12) hour += 12
		if (period === "AM" && hour === 12) hour = 0
		return { hour, minute }
	}

	const h24 = time.match(/^(\d{1,2}):(\d{2})$/)
	if (!h24) return null
	return { hour: Number(h24[1]), minute: Number(h24[2]) }
}

/** Interpret a wall-clock time in `timeZone` as a UTC Date. */
function zonedDateTime(
	date: string,
	time: string,
	timeZone: string,
): Date | null {
	const dateMatch = date.match(/^(\d{4})-(\d{2})-(\d{2})$/)
	const clock = parseClock(time)
	if (!dateMatch || !clock) return null

	const year = Number(dateMatch[1])
	const month = Number(dateMatch[2])
	const day = Number(dateMatch[3])
	const utcGuess = Date.UTC(year, month - 1, day, clock.hour, clock.minute, 0)

	try {
		const parts = new Intl.DateTimeFormat("en-US", {
			timeZone: timeZone || DEFAULT_TIME_ZONE,
			year: "numeric",
			month: "2-digit",
			day: "2-digit",
			hour: "2-digit",
			minute: "2-digit",
			hourCycle: "h23",
		}).formatToParts(new Date(utcGuess))

		const read = (type: Intl.DateTimeFormatPartTypes) =>
			Number(parts.find((part) => part.type === type)?.value)

		const asZone = Date.UTC(
			read("year"),
			read("month") - 1,
			read("day"),
			read("hour"),
			read("minute"),
		)
		return new Date(utcGuess + (utcGuess - asZone))
	} catch {
		return null
	}
}

function calendarPlainText(html: string | null | undefined): string {
	if (!html) return ""
	return html
		.replace(/<br\s*\/?>/gi, "\n")
		.replace(/<\/p>/gi, "\n")
		.replace(/<[^>]+>/g, "")
		.replace(/&nbsp;/gi, " ")
		.replace(/&amp;/gi, "&")
		.replace(/&lt;/gi, "<")
		.replace(/&gt;/gi, ">")
		.replace(/\n{3,}/g, "\n\n")
		.trim()
}

function icsEscape(value: string): string {
	return value
		.replace(/\\/g, "\\\\")
		.replace(/;/g, "\\;")
		.replace(/,/g, "\\,")
		.replace(/\r?\n/g, "\\n")
}
