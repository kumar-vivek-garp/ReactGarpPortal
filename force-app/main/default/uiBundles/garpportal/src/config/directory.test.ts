import { describe, expect, it } from "vitest"

import { directorySearchSchema } from "./directory"

describe("directorySearchSchema", () => {
	it("passes a search term through", () => {
		expect(directorySearchSchema.parse({ q: "Ada Lovelace" }).q).toBe(
			"Ada Lovelace",
		)
	})

	it("leaves an absent term undefined", () => {
		expect(directorySearchSchema.parse({}).q).toBeUndefined()
	})

	it("degrades a non-string term instead of throwing", () => {
		// The router JSON-parses search values, so `?q=2024` — a member searching
		// by a numeric company name or year — arrives as a NUMBER. It degrades to
		// no query rather than taking the route down; the member just retypes.
		expect(directorySearchSchema.parse({ q: 2024 }).q).toBeUndefined()
	})

	it("strips unknown params — filters live in component state, not the URL", () => {
		const parsed = directorySearchSchema.parse({ q: "GARP", industries: ["x"] })
		expect("industries" in parsed).toBe(false)
	})
})
