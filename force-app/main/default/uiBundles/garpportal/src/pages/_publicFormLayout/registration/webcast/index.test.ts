import { isNotFound } from "@tanstack/react-router"
import { describe, expect, it } from "vitest"

import { Route } from "./index"

describe("/registration/webcast — no event picker, by decision", () => {
	it("throws notFound so the bare path cannot fall into $programType", () => {
		// Without this static index, `/registration/webcast` would render a
		// bogus "WEBCAST Registration" exam placeholder from the dynamic route.
		let thrown: unknown = null
		try {
			Route.options.beforeLoad?.({} as never)
		} catch (error) {
			thrown = error
		}
		expect(isNotFound(thrown)).toBe(true)
	})
})
