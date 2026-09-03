import { isRedirect } from "@tanstack/react-router"
import { describe, expect, it } from "vitest"

import { DEFAULT_MEMBERSHIP_TAB } from "@/config/membership"

import { Route } from "./index"

describe("/member-resources — legacy redirect", () => {
	it("forwards to /membership on its default tab, replacing the entry", () => {
		let thrown: unknown = null
		try {
			Route.options.beforeLoad?.({} as never)
		} catch (error) {
			thrown = error
		}
		expect(isRedirect(thrown)).toBe(true)
		const options = (
			thrown as {
				options: { to?: string; search?: { tab?: string }; replace?: boolean }
			}
		).options
		expect(options.to).toBe("/membership")
		expect(options.search).toEqual({ tab: DEFAULT_MEMBERSHIP_TAB })
		expect(options.replace).toBe(true)
	})
})
