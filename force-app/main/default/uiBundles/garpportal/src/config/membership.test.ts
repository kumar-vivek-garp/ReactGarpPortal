import { describe, expect, it } from "vitest"

import { membershipSearchSchema, resolveMembershipView } from "./membership"

describe("membershipSearchSchema", () => {
	it("accepts both declared tabs", () => {
		expect(membershipSearchSchema.parse({ tab: "directory" }).tab).toBe(
			"directory",
		)
		expect(membershipSearchSchema.parse({ tab: "benefits" }).tab).toBe(
			"benefits",
		)
	})

	it("pins an absent or unknown tab to benefits", () => {
		expect(membershipSearchSchema.parse({}).tab).toBe("benefits")
		expect(membershipSearchSchema.parse({ tab: "bogus" }).tab).toBe("benefits")
	})

	it("keeps the view optional so a remembered choice can apply", () => {
		expect(membershipSearchSchema.parse({ view: "list" }).view).toBe("list")
		expect(membershipSearchSchema.parse({}).view).toBeUndefined()
		expect(membershipSearchSchema.parse({ view: "carousel" }).view).toBeUndefined()
	})
})

describe("resolveMembershipView", () => {
	it("gives an explicit ?view= top precedence", () => {
		expect(resolveMembershipView("list", "grid")).toBe("list")
	})

	it("prefers the remembered choice over the default", () => {
		expect(resolveMembershipView(undefined, "list")).toBe("list")
	})

	it("defaults to grid when nothing was chosen or remembered", () => {
		// Benefits carry artwork and blurbs — cards sell them while browsing.
		expect(resolveMembershipView(undefined)).toBe("grid")
		expect(resolveMembershipView(undefined, null)).toBe("grid")
	})
})
