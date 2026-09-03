import { isRedirect } from "@tanstack/react-router"
import { describe, expect, it } from "vitest"

import { Route } from "./index"

describe("/ — root redirect", () => {
	it("always forwards to /dashboard", () => {
		let thrown: unknown = null
		try {
			Route.options.beforeLoad?.({} as never)
		} catch (error) {
			thrown = error
		}
		expect(isRedirect(thrown)).toBe(true)
		expect((thrown as { options: { to?: string } }).options.to).toBe(
			"/dashboard",
		)
	})

	it("renders nothing itself", () => {
		expect(Route.options.component).toBeUndefined()
	})
})
