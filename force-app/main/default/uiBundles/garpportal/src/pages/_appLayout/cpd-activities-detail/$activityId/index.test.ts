import { isRedirect } from "@tanstack/react-router"
import { describe, expect, it } from "vitest"

import { Route } from "./index"

type RedirectOptions = {
	to?: string
	search?: { activityId?: string }
	replace?: boolean
}

function run(activityId: string) {
	let thrown: unknown = null
	try {
		Route.options.beforeLoad?.({ params: { activityId } } as never)
	} catch (error) {
		thrown = error
	}
	expect(isRedirect(thrown)).toBe(true)
	return (thrown as { options: RedirectOptions }).options
}

describe("/cpd-activities-detail/$activityId — legacy redirect", () => {
	it("forwards to the browse page scoped by search param, replacing the entry", () => {
		const options = run("a0X123")
		expect(options.to).toBe("/cpd/activities")
		expect(options.search).toEqual({ activityId: "a0X123" })
		expect(options.replace).toBe(true)
	})

	it("drops a blank id instead of forwarding an empty scope", () => {
		expect(run("   ").search).toEqual({ activityId: undefined })
	})
})
