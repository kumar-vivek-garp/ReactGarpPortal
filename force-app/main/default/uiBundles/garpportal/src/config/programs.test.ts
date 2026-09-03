import { describe, expect, it } from "vitest"

import {
	programsSearchSchema,
	resolveProgramsTab,
	resolveProgramsView,
} from "./programs"

describe("programsSearchSchema", () => {
	it("accepts every declared tab and view", () => {
		expect(programsSearchSchema.parse({ tab: "completed", view: "list" })).toEqual(
			{ tab: "completed", view: "list" },
		)
	})

	it("keeps absence distinguishable from a choice", () => {
		// No pinning to a default here — the panel's resolvers need to know
		// whether the member actually chose, so absent stays undefined.
		expect(programsSearchSchema.parse({})).toEqual({
			tab: undefined,
			view: undefined,
		})
	})

	it("degrades bad values to undefined instead of throwing", () => {
		expect(programsSearchSchema.parse({ tab: "bogus", view: 3 })).toEqual({
			tab: undefined,
			view: undefined,
		})
	})
})

describe("resolveProgramsTab", () => {
	it("respects an explicit tab regardless of enrollments", () => {
		expect(resolveProgramsTab("explore", 5)).toBe("explore")
		expect(resolveProgramsTab("all", 5)).toBe("all")
	})

	it("lands an enrolled member on their own programs", () => {
		expect(resolveProgramsTab(undefined, 1)).toBe("in-progress")
	})

	it("shows the full catalogue to someone with no enrollments", () => {
		expect(resolveProgramsTab(undefined, 0)).toBe("all")
	})
})

describe("resolveProgramsView", () => {
	it("gives an explicit ?view= top precedence", () => {
		expect(resolveProgramsView("grid", "in-progress", "list")).toBe("grid")
	})

	it("prefers the remembered choice over the per-bucket default", () => {
		// Once someone has picked a layout, reverting to the bucket default reads
		// as the app forgetting.
		expect(resolveProgramsView(undefined, "explore", "list")).toBe("list")
		expect(resolveProgramsView(undefined, "in-progress", "grid")).toBe("grid")
	})

	it("defaults personal buckets to rows and browsing buckets to cards", () => {
		expect(resolveProgramsView(undefined, "in-progress")).toBe("list")
		expect(resolveProgramsView(undefined, "completed")).toBe("list")
		expect(resolveProgramsView(undefined, "all")).toBe("grid")
		expect(resolveProgramsView(undefined, "explore")).toBe("grid")
	})

	it("treats a null remembered choice like no choice", () => {
		expect(resolveProgramsView(undefined, "all", null)).toBe("grid")
	})
})
