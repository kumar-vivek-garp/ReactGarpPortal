import { describe, expect, it } from "vitest"

import {
	EVENT_TYPE_FILTER_ITEMS,
	EVENT_TYPE_META,
	eventsSearchSchema,
	manageAttendanceHref,
} from "./events"

describe("eventsSearchSchema", () => {
	it("passes a valid type filter through", () => {
		expect(eventsSearchSchema.parse({ type: "webcast" })).toEqual({
			type: "webcast",
		})
	})

	it("drops a garbage type instead of failing the whole search", () => {
		expect(eventsSearchSchema.parse({ type: "nonsense" }).type).toBeUndefined()
	})

	it("leaves type absent when it is absent", () => {
		expect(eventsSearchSchema.parse({}).type).toBeUndefined()
	})

	it("silently ignores the legacy tab param still in old links", () => {
		expect(
			eventsSearchSchema.parse({ tab: "chapter-meetings", type: "chapter" }),
		).toEqual({ type: "chapter" })
	})
})

describe("EVENT_TYPE_FILTER_ITEMS", () => {
	it("derives from the type meta so labels/icons cannot drift", () => {
		expect(EVENT_TYPE_FILTER_ITEMS).toHaveLength(3)
		for (const item of EVENT_TYPE_FILTER_ITEMS) {
			expect(item.label).toBe(EVENT_TYPE_META[item.value].label)
			expect(item.icon).toBe(EVENT_TYPE_META[item.value].icon)
		}
	})
})

describe("manageAttendanceHref", () => {
	it("builds the legacy MyGarp attendance start URL", () => {
		expect(manageAttendanceHref("a00TEST000000001")).toBe(
			"/Login?start=chapterMeetingRegistrationsAttendance/a00TEST000000001",
		)
	})

	it("returns null without an event id", () => {
		expect(manageAttendanceHref(null)).toBeNull()
		expect(manageAttendanceHref("   ")).toBeNull()
	})
})
