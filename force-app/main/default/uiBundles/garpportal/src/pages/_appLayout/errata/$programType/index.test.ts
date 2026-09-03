import { isRedirect } from "@tanstack/react-router"
import { describe, expect, it } from "vitest"

import { Route } from "./index"

type RedirectOptions = {
	to?: string
	params?: Record<string, string>
	replace?: boolean
}

function run(programType: string) {
	try {
		Route.options.beforeLoad?.({ params: { programType } } as never)
	} catch (thrown) {
		expect(isRedirect(thrown)).toBe(true)
		return (thrown as { options: RedirectOptions }).options
	}
	return null
}

describe("/errata/$programType — legacy alias redirect", () => {
	it("forwards to the programme-nested errata page, replacing the entry", () => {
		const options = run("frm")
		expect(options?.to).toBe("/programs/$programType/errata")
		expect(options?.params).toEqual({ programType: "frm" })
		expect(options?.replace).toBe(true)
	})

	it("translates the legacy `rai` slug to `riskai`", () => {
		// MyGarp's address used `rai`; the programme route only knows `riskai`.
		expect(run("rai")?.params).toEqual({ programType: "riskai" })
	})

	it("normalizes case and whitespace before matching the alias", () => {
		expect(run(" RAI ")?.params).toEqual({ programType: "riskai" })
		expect(run("SCR")?.params).toEqual({ programType: "scr" })
	})

	it("passes any other slug through untranslated", () => {
		expect(run("scr")?.params).toEqual({ programType: "scr" })
		expect(run("riskai")?.params).toEqual({ programType: "riskai" })
	})
})
