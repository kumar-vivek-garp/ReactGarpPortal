import { describe, expect, it } from "vitest"

import { errataFormQueryOptions, errataQueryKeys } from "@/api/errata/query-options"

describe("errataFormQueryOptions", () => {
	it("keys by the uppercased trimmed programme", () => {
		const options = errataFormQueryOptions(" frm ")
		expect(options.queryKey).toEqual(["errata", "form", "FRM"])
		expect(options.queryKey).toEqual(errataQueryKeys.form("frm"))
		expect(options.enabled).toBe(true)
		// Org picklists, not member data — cached longer than the default.
		expect(options.staleTime).toBe(5 * 60_000)
	})

	it("disables itself for a blank programme", () => {
		expect(errataFormQueryOptions("   ").enabled).toBe(false)
	})
})
