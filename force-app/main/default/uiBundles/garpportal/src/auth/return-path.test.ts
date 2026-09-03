import { describe, expect, it } from "vitest"

import { getReturnPath } from "@/auth/return-path"

describe("getReturnPath", () => {
	it("returns the bare pathname when there is no search", () => {
		expect(getReturnPath({ pathname: "/programs", searchStr: "" })).toBe(
			"/programs",
		)
	})

	it("appends a search string that already carries its question mark", () => {
		expect(
			getReturnPath({
				pathname: "/registration/frm",
				searchStr: "?regCode=TEAM24",
			}),
		).toBe("/registration/frm?regCode=TEAM24")
	})

	it("adds the question mark when the search string lacks one", () => {
		// The router's `searchStr` shape has flip-flopped between the two forms
		// across versions — this branch is why either works.
		expect(
			getReturnPath({ pathname: "/registration/frm", searchStr: "regCode=X" }),
		).toBe("/registration/frm?regCode=X")
	})

	it("tolerates a missing searchStr at runtime", () => {
		// The type promises a string, but the `?.` guard exists because a hand-built
		// location (tests, guards) may omit it.
		expect(
			getReturnPath({
				pathname: "/dashboard",
				searchStr: undefined as unknown as string,
			}),
		).toBe("/dashboard")
	})

	it("never doubles the question mark", () => {
		const path = getReturnPath({
			pathname: "/events",
			searchStr: "?tab=upcoming",
		})
		expect(path.match(/\?/g)).toHaveLength(1)
	})
})
