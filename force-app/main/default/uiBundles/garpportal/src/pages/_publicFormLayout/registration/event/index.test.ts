import { isNotFound } from "@tanstack/react-router"
import { describe, expect, it } from "vitest"

import { Route } from "./index"

describe("/registration/event — no event picker, by decision", () => {
	it("throws notFound so the bare path cannot fall into $programType", () => {
		let thrown: unknown = null
		try {
			Route.options.beforeLoad?.({} as never)
		} catch (error) {
			thrown = error
		}
		expect(isNotFound(thrown)).toBe(true)
	})
})
