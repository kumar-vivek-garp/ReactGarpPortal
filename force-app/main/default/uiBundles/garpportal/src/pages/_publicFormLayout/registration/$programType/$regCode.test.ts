import { isRedirect } from "@tanstack/react-router"
import { describe, expect, it } from "vitest"

import type { RegistrationSearch } from "@/config/registration"

import { Route } from "./$regCode"

/** Post-validation search: every key present, unset ones `undefined`. */
const NO_SEARCH: RegistrationSearch = {
	regCode: undefined,
	teamCode: undefined,
	stripe_return: undefined,
	oid: undefined,
	on: undefined,
}

type RedirectOptions = {
	to?: string
	params?: Record<string, string>
	search?: RegistrationSearch
	replace?: boolean
}

function run(search: Partial<RegistrationSearch> = {}, programType = "frm") {
	try {
		Route.options.beforeLoad?.({
			params: { programType, regCode: "SEGMENT1" },
			search: { ...NO_SEARCH, ...search },
		} as never)
	} catch (thrown) {
		expect(isRedirect(thrown)).toBe(true)
		return (thrown as { options: RedirectOptions }).options
	}
	return null
}

describe("/registration/$programType/$regCode — legacy path-segment code", () => {
	it("folds the path segment into the query form of the canonical page", () => {
		const options = run()
		expect(options?.to).toBe("/registration/$programType")
		expect(options?.params).toEqual({ programType: "frm" })
		expect(options?.search?.regCode).toBe("SEGMENT1")
		// `replace` keeps Back from bouncing through the legacy address again.
		expect(options?.replace).toBe(true)
	})

	it("keeps the programme slug it arrived on", () => {
		expect(run({}, "scr")?.params).toEqual({ programType: "scr" })
	})

	it("prefers a regCode already present in the query — the more deliberate of the two", () => {
		expect(run({ regCode: "QUERY1" })?.search?.regCode).toBe("QUERY1")
	})

	it("prefers teamCode over the path segment when regCode is absent", () => {
		const options = run({ teamCode: "TEAM-X" })
		expect(options?.search?.regCode).toBe("TEAM-X")
		// The original teamCode still travels with the rest of the search.
		expect(options?.search?.teamCode).toBe("TEAM-X")
	})

	it("keeps a payment return's params intact across the fold", () => {
		const options = run({ stripe_return: "1", oid: "801", on: "W1" })
		expect(options?.search).toMatchObject({
			stripe_return: "1",
			oid: "801",
			on: "W1",
			regCode: "SEGMENT1",
		})
	})
})
