import { afterEach, describe, expect, it, vi } from "vitest"

vi.mock("@/auth/sfdc-env", () => ({
	isLocalViteHost: vi.fn(() => false),
	getSfdcEnv: vi.fn(() => undefined),
}))

import type { MemberEvent } from "@/api/events"
import { EVENT_TYPE_FILTER_ITEMS, EVENT_TYPE_META } from "@/config/events"
import {
	buildEventPresentation,
	eventDateBadge,
	eventKind,
	eventPageUrl,
	eventRegisterPath,
	eventTimeLabel,
	eventWeekday,
	eventTiming,
} from "./events-presentation"

function memberEvent(overrides: Partial<MemberEvent> = {}): MemberEvent {
	return {
		eventId: "e1",
		eventType: "Chapter Meeting",
		eventName: "Budapest Chapter: Navigating Market Risks",
		eventStartDate: "2026-09-28",
		eventSlug: "budapest-chapter",
		eventURL: "https://www.garp.org/events/budapest-chapter",
		chapterId: "c1",
		canManageAttendance: false,
		addToCalTitle: "Budapest Chapter Meeting",
		addToCalDescription: "<p>Join us</p>",
		addToCalStartDateTime: "2026-09-28 2:00 PM",
		addToCalEndDateTime: "2026-09-28 4:00 PM",
		addToCalTimeZone: "America/New_York",
		addToCalLocation: "<p>Budapest, Hungary</p>",
		...overrides,
	}
}

afterEach(() => {
	vi.useRealTimers()
})

describe("events config", () => {
	it("initialises without a temporal dead zone error", () => {
		// EVENT_TYPE_FILTER_ITEMS is derived from EVENT_TYPE_META at module scope,
		// so a declaration-order regression would throw on import rather than fail
		// a type check.
		expect(EVENT_TYPE_FILTER_ITEMS).toHaveLength(3)
		expect(EVENT_TYPE_FILTER_ITEMS[0].label).toBe(EVENT_TYPE_META.event.label)
	})
})

describe("eventKind", () => {
	it("classifies by substring, case-insensitively", () => {
		expect(eventKind("Chapter Meeting")).toBe("chapter")
		expect(eventKind("webcast")).toBe("webcast")
		expect(eventKind("Event")).toBe("event")
		expect(eventKind(null)).toBe("event")
	})
})

describe("eventPageUrl", () => {
	it("keeps urls with a real slug", () => {
		expect(eventPageUrl("https://www.garp.org/events/foo")).toBe(
			"https://www.garp.org/events/foo",
		)
	})

	it("drops bare catalogue paths that would land on an index", () => {
		expect(eventPageUrl("https://www.garp.org/event/")).toBeNull()
		expect(eventPageUrl("https://www.garp.org/")).toBeNull()
	})

	it("rejects unsafe or malformed urls", () => {
		expect(eventPageUrl("javascript:alert(1)")).toBeNull()
		expect(eventPageUrl("not a url")).toBeNull()
		expect(eventPageUrl(null)).toBeNull()
	})
})

describe("eventDateBadge", () => {
	it("splits an ISO date into month and day", () => {
		expect(eventDateBadge("2026-09-28")).toEqual({ month: "Sep", day: "28" })
	})

	it("returns null for missing or malformed dates", () => {
		expect(eventDateBadge(null)).toBeNull()
		expect(eventDateBadge("not-a-date")).toBeNull()
	})
})

describe("eventTimeLabel", () => {
	it("renders a range in the event's own zone with its abbreviation", () => {
		const label = eventTimeLabel(memberEvent())
		// September is daylight time in New York. ICU picks the separator spacing
		// and may use narrow no-break spaces, so every gap is matched as \s.
		expect(label).toMatch(/^2:00\s*–\s*4:00\sPM\sEDT$/)
	})

	it("falls back to the start alone when the end is missing", () => {
		expect(
			eventTimeLabel(memberEvent({ addToCalEndDateTime: null })),
		).toBe("2:00 PM EDT")
	})

	it("falls back to the start alone when the end equals the start", () => {
		expect(
			eventTimeLabel(
				memberEvent({ addToCalEndDateTime: "2026-09-28 2:00 PM" }),
			),
		).toBe("2:00 PM EDT")
	})

	it("falls back to the start alone across days — the date line already carries the date", () => {
		expect(
			eventTimeLabel(
				memberEvent({ addToCalEndDateTime: "2026-10-02 5:30 PM" }),
			),
		).toBe("2:00 PM EDT")
	})

	it("respects a different published timezone", () => {
		const label = eventTimeLabel(
			memberEvent({ addToCalTimeZone: "Europe/London" }),
		)
		expect(label).toContain("2:00")
		expect(label).not.toContain("EDT")
	})

	it("returns null when there is no calendar stamp", () => {
		expect(
			eventTimeLabel(memberEvent({ addToCalStartDateTime: null })),
		).toBeNull()
	})

	it("returns null rather than a wrong time for an unparseable stamp", () => {
		expect(
			eventTimeLabel(memberEvent({ addToCalStartDateTime: "garbage" })),
		).toBeNull()
	})
})

describe("eventRegisterPath", () => {
	it("maps the card kind to the registration route segment", () => {
		// The one place "chapter" (listing) and "chaptermeeting" (routes) meet.
		expect(eventRegisterPath("chapter", "a1")).toBe(
			"/events/chaptermeeting/a1/register",
		)
		expect(eventRegisterPath("webcast", "a2")).toBe(
			"/events/webcast/a2/register",
		)
		expect(eventRegisterPath("event", "a3")).toBe("/events/event/a3/register")
	})

	it("returns null without an id", () => {
		expect(eventRegisterPath("event", null)).toBeNull()
		expect(eventRegisterPath("event", "  ")).toBeNull()
	})
})

describe("buildEventPresentation register CTA", () => {
	it("offers registration only for events the member has not booked", () => {
		expect(buildEventPresentation(memberEvent()).registerUrl).toBe(
			"/events/chaptermeeting/e1/register",
		)
		expect(
			buildEventPresentation(memberEvent(), { isAttending: true }).registerUrl,
		).toBeNull()
	})
})

describe("eventWeekday", () => {
	it("names the weekday for the hero's date block", () => {
		// 2026-09-28 is a Monday.
		expect(eventWeekday("2026-09-28")).toBe("Monday")
	})

	it("returns null for missing or malformed dates", () => {
		expect(eventWeekday(null)).toBeNull()
		expect(eventWeekday("garbage")).toBeNull()
	})
})

describe("eventTiming", () => {
	it("flags today and tomorrow as warnings", () => {
		vi.useFakeTimers()
		vi.setSystemTime(new Date(2026, 8, 28))
		expect(eventTiming("2026-09-28")).toEqual({ label: "Today", tone: "warning" })
		expect(eventTiming("2026-09-29")).toEqual({
			label: "Tomorrow",
			tone: "warning",
		})
	})

	it("counts down inside the imminent window", () => {
		vi.useFakeTimers()
		vi.setSystemTime(new Date(2026, 8, 24))
		expect(eventTiming("2026-09-28")).toEqual({
			label: "In 4 days",
			tone: "info",
		})
	})

	it("stays silent beyond a week, and for past events", () => {
		vi.useFakeTimers()
		vi.setSystemTime(new Date(2026, 8, 1))
		expect(eventTiming("2026-09-28")).toBeNull()
		vi.setSystemTime(new Date(2026, 9, 5))
		expect(eventTiming("2026-09-28")).toBeNull()
	})
})

describe("buildEventPresentation", () => {
	it("surfaces the start time and location that were previously calendar-only", () => {
		const result = buildEventPresentation(memberEvent())
		const when = result.metaLines.find((line) => line.icon === "when")
		expect(when?.text).toMatch(/2:00\s*–\s*4:00\sPM\sEDT/)
		// Location arrives as HTML and must be rendered as plain text.
		expect(result.metaLines).toContainEqual({
			icon: "location",
			text: "Budapest, Hungary",
		})
	})

	it("marks attending events only when told", () => {
		expect(buildEventPresentation(memberEvent()).statusLabel).toBeNull()
		const attending = buildEventPresentation(memberEvent(), {
			isAttending: true,
		})
		expect(attending.statusLabel).toBe("Attending")
		expect(attending.statusTone).toBe("success")
	})

	it("exposes an attendance url only when Apex allows it", () => {
		expect(buildEventPresentation(memberEvent()).attendanceUrl).toBeNull()
		const managed = buildEventPresentation(
			memberEvent({ canManageAttendance: true }),
		)
		expect(managed.attendanceUrl).toContain("e1")
	})

	it("falls back to a placeholder title", () => {
		expect(buildEventPresentation(memberEvent({ eventName: "  " })).title).toBe(
			"Event",
		)
	})

	it("degrades to a date-only meta line without a calendar stamp", () => {
		const result = buildEventPresentation(
			memberEvent({ addToCalStartDateTime: null, addToCalLocation: null }),
		)
		const when = result.metaLines.find((line) => line.icon === "when")
		expect(when?.text).not.toContain("·")
		expect(result.hasCalendar).toBe(false)
		expect(result.metaLines.some((l) => l.icon === "location")).toBe(false)
	})

	it("exposes the calendar description as a plain-text blurb", () => {
		// The fixture ships it as HTML; it must come out stripped.
		expect(buildEventPresentation(memberEvent()).description).toBe("Join us")
	})

	it("drops a blurb that is empty or just the title again", () => {
		expect(
			buildEventPresentation(memberEvent({ addToCalDescription: "  " }))
				.description,
		).toBeNull()
		expect(
			buildEventPresentation(
				memberEvent({
					addToCalDescription:
						"Budapest Chapter: Navigating Market Risks",
				}),
			).description,
		).toBeNull()
	})

	it("has no meta lines at all when the date is missing", () => {
		const result = buildEventPresentation(
			memberEvent({
				eventStartDate: null,
				addToCalStartDateTime: null,
				addToCalLocation: null,
			}),
		)
		expect(result.metaLines).toEqual([])
		expect(result.dateBadge).toBeNull()
	})
})
