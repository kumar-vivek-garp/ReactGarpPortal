import { isRedirect } from "@tanstack/react-router"
import { describe, expect, it } from "vitest"

import { Route } from "./index"

describe("/order-details/$orderNumber — legacy redirect", () => {
	it("forwards under My Account, carrying the order number, replacing the entry", () => {
		let thrown: unknown = null
		try {
			Route.options.beforeLoad?.({ params: { orderNumber: "12345" } } as never)
		} catch (error) {
			thrown = error
		}
		expect(isRedirect(thrown)).toBe(true)
		const options = (
			thrown as {
				options: { to?: string; params?: Record<string, string>; replace?: boolean }
			}
		).options
		expect(options.to).toBe("/my-account/orders/$orderNumber")
		expect(options.params).toEqual({ orderNumber: "12345" })
		expect(options.replace).toBe(true)
	})
})
