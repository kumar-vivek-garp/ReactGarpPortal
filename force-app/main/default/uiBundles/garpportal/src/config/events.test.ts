import { describe, expect, it } from "vitest"

import { manageAttendanceHref, SET_CHAPTER_HREF } from "./events"

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

describe("SET_CHAPTER_HREF", () => {
	it("opens My Account on the chapters tab", () => {
		expect(SET_CHAPTER_HREF).toBe("/my-account?tab=account-information")
	})
})
