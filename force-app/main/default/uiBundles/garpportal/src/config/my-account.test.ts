import { describe, expect, it } from "vitest"

import { myAccountSearchSchema } from "./my-account"

describe("myAccountSearchSchema", () => {
	it("accepts every declared tab", () => {
		expect(myAccountSearchSchema.parse({ tab: "order-history" }).tab).toBe(
			"order-history",
		)
		expect(myAccountSearchSchema.parse({ tab: "contact-preferences" }).tab).toBe(
			"contact-preferences",
		)
	})

	it("pins an absent or unknown tab to account-information", () => {
		// Unlike Programs, this page has no smart default to compute — a deep
		// link must always land somewhere renderable.
		expect(myAccountSearchSchema.parse({}).tab).toBe("account-information")
		expect(myAccountSearchSchema.parse({ tab: "bogus" }).tab).toBe(
			"account-information",
		)
		expect(myAccountSearchSchema.parse({ tab: 3 }).tab).toBe(
			"account-information",
		)
	})

	it("keeps the orders filter optional and forgiving", () => {
		expect(myAccountSearchSchema.parse({ orders: "unpaid" }).orders).toBe(
			"unpaid",
		)
		expect(myAccountSearchSchema.parse({}).orders).toBeUndefined()
		expect(myAccountSearchSchema.parse({ orders: "everything" }).orders).toBeUndefined()
	})

	it("passes a string status through", () => {
		expect(myAccountSearchSchema.parse({ status: "setup-complete" }).status).toBe(
			"setup-complete",
		)
	})

	it("REJECTS the whole search when status arrives as a number", () => {
		// Actual current behavior, asserted as-is: `status` is the one param in
		// this schema with no `.catch`, so `?status=123` — which the router
		// JSON-parses into the NUMBER 123 — fails validation outright instead of
		// degrading. This is the same trap class registration-forms §7 documents
		// for `oid`/`on`; flagged as a suspected source bug, not fixed here.
		const result = myAccountSearchSchema.safeParse({ status: 123 })
		expect(result.success).toBe(false)
	})
})
