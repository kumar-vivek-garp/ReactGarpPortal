import { describe, expect, it } from "vitest"

import { helpCenterSearchSchema } from "./help-center"

describe("helpCenterSearchSchema", () => {
	it("accepts both declared tabs", () => {
		expect(helpCenterSearchSchema.parse({ tab: "get-help" }).tab).toBe(
			"get-help",
		)
		expect(helpCenterSearchSchema.parse({ tab: "requests" }).tab).toBe(
			"requests",
		)
	})

	it("pins an absent or unknown tab to get-help", () => {
		expect(helpCenterSearchSchema.parse({}).tab).toBe("get-help")
		expect(helpCenterSearchSchema.parse({ tab: "bogus" }).tab).toBe("get-help")
		// The router JSON-parses search values, so a numeric ?tab= arrives as a
		// number — it must degrade, not throw.
		expect(helpCenterSearchSchema.parse({ tab: 1 }).tab).toBe("get-help")
	})

	it("strips unknown params", () => {
		const parsed = helpCenterSearchSchema.parse({ tab: "requests", case: "42" })
		expect("case" in parsed).toBe(false)
	})
})
