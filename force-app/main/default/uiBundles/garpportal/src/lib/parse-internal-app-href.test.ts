import { describe, expect, it } from "vitest"

import { parseInternalAppHref } from "./parse-internal-app-href"

describe("parseInternalAppHref", () => {
	it("passes a plain path through with an empty search", () => {
		expect(parseInternalAppHref("/membership")).toEqual({
			pathname: "/membership",
			search: {},
		})
	})

	it("splits the query into a search object", () => {
		expect(parseInternalAppHref("/membership?tab=directory")).toEqual({
			pathname: "/membership",
			search: { tab: "directory" },
		})
	})

	it("keeps every parameter of a multi-param query", () => {
		expect(parseInternalAppHref("/my-account?tab=orders&sort=date")).toEqual({
			pathname: "/my-account",
			search: { tab: "orders", sort: "date" },
		})
	})

	it("lets the last value win for a repeated key", () => {
		expect(parseInternalAppHref("/x?tab=a&tab=b").search).toEqual({ tab: "b" })
	})

	it("decodes percent-escapes and pluses", () => {
		expect(parseInternalAppHref("/search?q=risk%20ai&who=a+b").search).toEqual({
			q: "risk ai",
			who: "a b",
		})
	})

	it("keeps an empty value as an empty string", () => {
		expect(parseInternalAppHref("/x?flag=").search).toEqual({ flag: "" })
	})

	it("resolves a bare query string to the root path", () => {
		expect(parseInternalAppHref("?tab=directory")).toEqual({
			pathname: "/",
			search: { tab: "directory" },
		})
	})

	it("trims surrounding whitespace from CMS-authored hrefs", () => {
		expect(parseInternalAppHref("  /membership?tab=directory ")).toEqual({
			pathname: "/membership",
			search: { tab: "directory" },
		})
	})
})
