import { QueryClient } from "@tanstack/react-query"
import { describe, expect, it } from "vitest"

import type { CurrentUser } from "@/api/auth/current-user"
import { authQueryKeys } from "@/api/auth/query-options"
import type { RegistrationSearch } from "@/config/registration"
import { redirectMemberToPortalForm } from "@/auth/registration-guard"
import {
	isMembershipProgramSlug,
	MEMBERSHIP_MEMBER_REGISTRATION_ROUTE,
	publicRegistrationFallback,
} from "@/lib/registration-paths"

/**
 * The membership programme's twin is not under `/programs`. Both directions
 * of that exception, plus the invariants the exam guard already keeps: the
 * search survives, the payment legs are never bounced, a guest stays put.
 * `registration-guard.test.ts` holds the exam matrix and is over the size cap.
 */

type RedirectTarget = {
	to?: string
	params?: Record<string, string>
	search?: RegistrationSearch
}

const MEMBER: CurrentUser = {
	id: "005",
	name: "Ada Lovelace",
	garpId: "123",
	contactId: "003",
	photoUrl: null,
}

const NO_SEARCH: RegistrationSearch = {
	regCode: undefined,
	teamCode: undefined,
	stripe_return: undefined,
	oid: undefined,
	on: undefined,
	checkout_cancelled: undefined,
	resume: undefined,
	track_cta: undefined,
}

function clientWith(user: CurrentUser | null) {
	const queryClient = new QueryClient()
	queryClient.setQueryData(authQueryKeys.currentUser, user)
	return queryClient
}

function run(
	user: CurrentUser | null,
	search: Partial<RegistrationSearch> = {},
	programType = "membership",
): RedirectTarget | null {
	try {
		redirectMemberToPortalForm({
			context: { queryClient: clientWith(user) },
			params: { programType },
			search: { ...NO_SEARCH, ...search },
		})
		return null
	} catch (thrown) {
		// `redirect()` returns a wrapper; the destination sits under `options`.
		return (thrown as { options: RedirectTarget }).options
	}
}

describe("redirectMemberToPortalForm — the membership slug", () => {
	it("sends a member to /membership/register, not under /programs", () => {
		const target = run(MEMBER)
		expect(target?.to).toBe(MEMBERSHIP_MEMBER_REGISTRATION_ROUTE)
		expect(target?.to).toBe("/membership/register")
		// A static route: no `$programType` to fill in.
		expect(target?.params).toBeUndefined()
	})

	it("carries the search — regCode and the attribution tag both survive", () => {
		const target = run(MEMBER, {
			regCode: "TEAM24",
			track_cta: "PortalMyAccountPage",
		})
		expect(target?.search?.regCode).toBe("TEAM24")
		expect(target?.search?.track_cta).toBe("PortalMyAccountPage")
	})

	it("recognises the wire type and any casing as the same programme", () => {
		expect(run(MEMBER, {}, "mem")?.to).toBe("/membership/register")
		expect(run(MEMBER, {}, "MEMBERSHIP")?.to).toBe("/membership/register")
		expect(run(MEMBER, {}, " Mem ")?.to).toBe("/membership/register")
	})

	it("leaves every other slug on the programmes twin", () => {
		expect(run(MEMBER, {}, "frm")?.to).toBe("/programs/$programType/register")
		expect(run(MEMBER, {}, "frm")?.params).toEqual({ programType: "frm" })
	})

	it("never bounces a payment return or a cancelled checkout", () => {
		expect(run(MEMBER, { stripe_return: "1", oid: "801", on: "W1" })).toBeNull()
		expect(run(MEMBER, { checkout_cancelled: "1", oid: "801" })).toBeNull()
		expect(
			run(MEMBER, { checkout_cancelled: "1", oid: "a0H", resume: "a0H" }),
		).toBeNull()
	})

	it("does bounce a bare resume — the member route rebuilds the same row", () => {
		const target = run(MEMBER, { resume: "a0H" })
		expect(target?.to).toBe("/membership/register")
		expect(target?.search?.resume).toBe("a0H")
	})

	it("leaves a guest on the public form", () => {
		expect(run(null)).toBeNull()
	})
})

describe("publicRegistrationFallback — the membership twin", () => {
	it("maps /membership/register back to the public membership form", () => {
		expect(publicRegistrationFallback("/membership/register")).toEqual({
			kind: "program",
			programType: "membership",
		})
		expect(publicRegistrationFallback("/membership/register/")).toEqual({
			kind: "program",
			programType: "membership",
		})
	})

	it("does not capture the benefits page or anything deeper", () => {
		expect(publicRegistrationFallback("/membership")).toBeNull()
		expect(publicRegistrationFallback("/membership/")).toBeNull()
		expect(publicRegistrationFallback("/membership/register/extra")).toBeNull()
		expect(publicRegistrationFallback("/membership/registers")).toBeNull()
	})

	it("the two directions agree — no bounce loop", () => {
		// Member on the public form → the member twin; guest on the member
		// twin → a public path the exam guard maps straight back.
		const memberTarget = run(MEMBER)
		expect(memberTarget?.to).toBe("/membership/register")
		const fallback = publicRegistrationFallback("/membership/register")
		expect(fallback?.kind).toBe("program")
		expect(fallback && "programType" in fallback && fallback.programType).toBe(
			"membership",
		)
	})
})

describe("isMembershipProgramSlug", () => {
	it("accepts the address slug and the wire type, in any casing", () => {
		for (const slug of ["membership", "mem", "MEM", " Membership "]) {
			expect(isMembershipProgramSlug(slug)).toBe(true)
		}
	})

	it("rejects everything else, including near misses", () => {
		for (const slug of ["frm", "affiliate", "memb", "memberships", ""]) {
			expect(isMembershipProgramSlug(slug)).toBe(false)
		}
	})
})
