import { describe, expect, it } from "vitest"

import type { MemberEvent } from "@/api/events"
import {
	buildGoogleUrl,
	buildIcs,
	calendarEventFromMember,
	hasCalendarPayload,
	utcStamp,
} from "./event-calendar"

function member(overrides: Partial<MemberEvent> = {}): MemberEvent {
	return {
		eventId: "a00",
		eventType: "Event",
		eventName: "GARP 2025 Financial Risk Symposium",
		eventStartDate: "2026-10-28",
		eventSlug: "frs-2025",
		eventURL: "https://www.garp.org/event/frs-2025",
		chapterId: null,
		canManageAttendance: false,
		addToCalTitle: "GARP 2025 Financial Risk Symposium",
		addToCalDescription: "Join us<br/>in NYC",
		addToCalLocation: "New York, NY",
		addToCalStartDateTime: "2026-10-28 6:00 PM",
		addToCalEndDateTime: "2026-10-28 8:00 PM",
		addToCalTimeZone: "America/New_York",
		...overrides,
	}
}

describe("hasCalendarPayload", () => {
	it("is true only when Apex stamped a start datetime", () => {
		expect(hasCalendarPayload(member())).toBe(true)
		expect(hasCalendarPayload(member({ addToCalStartDateTime: null }))).toBe(
			false,
		)
	})
})

describe("calendarEventFromMember", () => {
	it("maps registered-event calendar fields and strips HTML", () => {
		const input = calendarEventFromMember(member())
		expect(input).toMatchObject({
			name: "GARP 2025 Financial Risk Symposium",
			description: "Join us\nin NYC",
			location: "New York, NY",
			startDate: "2026-10-28",
			startTime: "6:00 PM",
			timeZone: "America/New_York",
		})
	})

	it("returns null without a start stamp", () => {
		expect(
			calendarEventFromMember(member({ addToCalStartDateTime: null })),
		).toBeNull()
	})
})

describe("buildGoogleUrl", () => {
	it("uses UTC stamps for 6pm Eastern Daylight Time", () => {
		const input = calendarEventFromMember(member())
		expect(input).not.toBeNull()
		const url = new URL(buildGoogleUrl(input!))
		expect(url.searchParams.get("action")).toBe("TEMPLATE")
		expect(url.searchParams.get("text")).toBe(
			"GARP 2025 Financial Risk Symposium",
		)
		expect(url.searchParams.get("ctz")).toBe("America/New_York")
		// 28 Oct 2026 is still EDT (UTC-4) — 6–8pm → 22:00–00:00Z
		expect(url.searchParams.get("dates")).toBe(
			"20261028T220000Z/20261029T000000Z",
		)
	})
})

describe("buildIcs", () => {
	it("emits a VEVENT with escaped description", () => {
		const input = calendarEventFromMember(member())
		const ics = buildIcs(input!)
		expect(ics).toContain("BEGIN:VEVENT")
		expect(ics).toContain("SUMMARY:GARP 2025 Financial Risk Symposium")
		expect(ics).toContain("DESCRIPTION:Join us\\nin NYC")
		expect(ics).toContain("DTSTART:20261028T220000Z")
		expect(ics).toContain("DTEND:20261029T000000Z")
	})
})

describe("utcStamp", () => {
	it("formats a UTC instant as yyyyMMddTHHmmssZ", () => {
		expect(utcStamp(new Date(Date.UTC(2026, 9, 28, 22, 0, 0)))).toBe(
			"20261028T220000Z",
		)
	})
})
