import { afterEach, describe, expect, it, vi } from "vitest"

vi.mock("@/auth/sfdc-env", () => ({
	isLocalViteHost: vi.fn(() => false),
	getSfdcEnv: vi.fn(() => undefined),
}))

import type { MemberEvent } from "@/api/events"
import { EVENT_BUCKET_META, EVENT_TAB_ITEMS } from "@/config/events"
import {
	buildEventPresentation,
	eventDateBadge,
	eventKind,
	eventPageUrl,
	eventStartTimeLabel,
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
		// EVENT_TAB_ITEMS is derived from EVENT_BUCKET_META at module scope, so a
		// declaration-order regression would throw on import rather than fail a type check.
		expect(EVENT_TAB_ITEMS).toHaveLength(4)
		expect(EVENT_TAB_ITEMS[0].label).toBe(EVENT_BUCKET_META.all.label)
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

describe("eventStartTimeLabel", () => {
	it("renders the time in the event's own zone with its abbreviation", () => {
		const label = eventStartTimeLabel(memberEvent())
		// September is daylight time in New York.
		expect(label).toBe("2:00 PM EDT")
	})

	it("respects a different published timezone", () => {
		const label = eventStartTimeLabel(
			memberEvent({ addToCalTimeZone: "Europe/London" }),
		)
		expect(label).toContain("2:00 PM")
		expect(label).not.toContain("EDT")
	})

	it("returns null when there is no calendar stamp", () => {
		expect(
			eventStartTimeLabel(memberEvent({ addToCalStartDateTime: null })),
		).toBeNull()
	})

	it("returns null rather than a wrong time for an unparseable stamp", () => {
		expect(
			eventStartTimeLabel(memberEvent({ addToCalStartDateTime: "garbage" })),
		).toBeNull()
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
		expect(when?.text).toContain("2:00 PM EDT")
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
