import { describe, expect, it } from "vitest"

import { activeRouteKey, isRouteActive } from "./route-active"

describe("isRouteActive", () => {
	it("matches the route exactly", () => {
		expect(isRouteActive("/programs", "/programs")).toBe(true)
	})

	it("matches nested routes", () => {
		expect(isRouteActive("/programs/frm", "/programs")).toBe(true)
		expect(isRouteActive("/programs/frm/exam", "/programs")).toBe(true)
	})

	it("does not match a sibling route that merely shares a prefix", () => {
		// The reason the check is on a segment boundary rather than startsWith.
		expect(isRouteActive("/programs-archive", "/programs")).toBe(false)
		expect(isRouteActive("/my-accounts", "/my-account")).toBe(false)
	})

	it("does not match unrelated routes", () => {
		expect(isRouteActive("/events", "/programs")).toBe(false)
		expect(isRouteActive("/", "/programs")).toBe(false)
	})
})

describe("activeRouteKey", () => {
	const routes = [
		"/my-account",
		"/dashboard",
		"/programs",
		"/study-materials",
	] as const

	it("returns the matching route", () => {
		expect(activeRouteKey("/programs", routes)).toBe("/programs")
		expect(activeRouteKey("/programs/scr", routes)).toBe("/programs")
		expect(activeRouteKey("/my-account", routes)).toBe("/my-account")
	})

	it("returns null when nothing matches, so the indicator can hide", () => {
		expect(activeRouteKey("/help-center", routes)).toBeNull()
		expect(activeRouteKey("/", routes)).toBeNull()
	})

	it("resolves in declaration order", () => {
		expect(activeRouteKey("/programs/frm", ["/programs", "/programs/frm"])).toBe(
			"/programs",
		)
	})
})
