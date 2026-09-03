import { isRedirect } from "@tanstack/react-router"
import { describe, expect, it } from "vitest"

import { AFFILIATE_REGISTRATION_ROUTE } from "@/lib/registration-paths"

import { Route } from "./index"

describe("/affiliate — legacy forward to the sign-up form", () => {
	it("always redirects to the affiliate registration route", () => {
		let thrown: unknown = null
		try {
			Route.options.beforeLoad?.({} as never)
		} catch (error) {
			thrown = error
		}
		expect(isRedirect(thrown)).toBe(true)
		expect((thrown as { options: { to?: string } }).options.to).toBe(
			AFFILIATE_REGISTRATION_ROUTE,
		)
	})

	it("mounts no chrome of its own — beforeLoad throws before any render", () => {
		expect(Route.options.component).toBeUndefined()
	})
})
