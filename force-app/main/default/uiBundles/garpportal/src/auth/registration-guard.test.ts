import { QueryClient } from "@tanstack/react-query"
import { describe, expect, it } from "vitest"

import type { CurrentUser } from "@/api/auth/current-user"
import { authQueryKeys } from "@/api/auth/query-options"
import type { RegistrationSearch } from "@/config/registration"
import {
	redirectMemberToDashboard,
	redirectMemberToPortalForm,
} from "@/auth/registration-guard"
import {
	AFFILIATE_REGISTRATION_ROUTE,
	publicRegistrationFallback,
} from "@/lib/registration-paths"
import { resolveExamProgram } from "@/lib/registration-programs"

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

/** Every key is present after validation, so start from a full blank set. */
const NO_SEARCH: RegistrationSearch = {
	regCode: undefined,
	teamCode: undefined,
	stripe_return: undefined,
	oid: undefined,
	on: undefined,
}

const PAID: Partial<RegistrationSearch> = {
	stripe_return: "1",
	oid: "801",
	on: "W1",
}

/**
 * Seeded rather than fetched: the guard reads the cache synchronously when it
 * is populated, which is the path every navigation after the first one takes.
 */
function clientWith(user: CurrentUser | null) {
	const queryClient = new QueryClient()
	queryClient.setQueryData(authQueryKeys.currentUser, user)
	return queryClient
}

function run(
	user: CurrentUser | null,
	search: Partial<RegistrationSearch> = {},
	programType = "frm",
) {
	try {
		redirectMemberToPortalForm({
			context: { queryClient: clientWith(user) },
			params: { programType },
			search: { ...NO_SEARCH, ...search },
		})
	} catch (thrown) {
		// `redirect()` returns a wrapper; the destination sits under `options`.
		return (thrown as { options: RedirectTarget }).options
	}
	return null
}

describe("publicRegistrationFallback", () => {
	it("offers the public form for a member registration path", () => {
		expect(publicRegistrationFallback("/programs/frm/register")).toEqual({
			programType: "frm",
		})
		// Trailing slash is the same route.
		expect(publicRegistrationFallback("/programs/scr/register/")).toEqual({
			programType: "scr",
		})
	})

	it("offers nothing for any other member path", () => {
		// If this ever matched too widely, `_appLayout` would stop sending people
		// to Login and start bouncing them at a registration form instead.
		for (const path of [
			"/programs",
			"/programs/frm",
			"/programs/frm/results",
			"/programs/frm/exam-setup",
			"/dashboard",
			"/registration/frm",
			"/programs/frm/register/extra",
		]) {
			expect(publicRegistrationFallback(path)).toBeNull()
		}
	})
})

describe("redirectMemberToPortalForm (public route)", () => {
	it("sends a signed-in member to the in-portal form", () => {
		const target = run(MEMBER)
		expect(target?.to).toBe("/programs/$programType/register")
		expect(target?.params).toEqual({ programType: "frm" })
	})

	it("carries the registration code across the bounce", () => {
		// A marketing link is `/registration/frm?regCode=X`. Losing the code on
		// the way to the member form silently reprices the whole order.
		const target = run(MEMBER, { regCode: "TEAM24" })
		expect(target?.search).toMatchObject({ regCode: "TEAM24" })
	})

	it("leaves a guest on the public form", () => {
		expect(run(null)).toBeNull()
	})

	it("never redirects a payment return, even for a member", () => {
		// The order is already charged; redirecting drops `oid`/`on` and the
		// candidate loses the only confirmation they get.
		expect(run(MEMBER, PAID)).toBeNull()
	})
})

describe("the two directions together", () => {
	it("cannot bounce the same visitor back and forth", () => {
		// A member is moved off the public route; a guest is moved off the member
		// route (by `_appLayout`, via publicRegistrationFallback). Exactly one of
		// those may act for any given session, or the two chase each other.
		const memberActsOnPublic = run(MEMBER) !== null
		const guestActsOnMember =
			publicRegistrationFallback("/programs/frm/register") !== null

		expect(memberActsOnPublic).toBe(true)
		expect(run(null)).toBeNull()
		expect(guestActsOnMember).toBe(true)
	})
})

describe("redirectMemberToDashboard (affiliate route)", () => {
	function runAffiliate(user: CurrentUser | null) {
		try {
			redirectMemberToDashboard({ context: { queryClient: clientWith(user) } })
		} catch (thrown) {
			return (thrown as { options: RedirectTarget }).options
		}
		return null
	}

	it("leaves a guest on the form", () => {
		// The whole point of the page: someone with no account, creating one.
		expect(runAffiliate(null)).toBeNull()
	})

	it("sends a signed-in member to their dashboard", () => {
		// They already have the account this form creates, and the programme
		// does not allow member public registration — the server would answer
		// their email `mustSignIn` anyway.
		expect(runAffiliate(MEMBER)?.to).toBe("/dashboard")
	})

	it("never sends anyone to a member twin of this form", () => {
		// There isn't one. If this ever pointed at `/programs/affiliate/register`
		// it would land on the exam dispatcher's placeholder.
		expect(runAffiliate(MEMBER)?.to).not.toContain("affiliate")
	})
})

describe("the affiliate route is static", () => {
	it("cannot be captured by the exam dispatcher's dynamic segment", () => {
		// TanStack Router sorts static ahead of dynamic, so `/registration/
		// affiliate` matches its own route — but the member-side fallback must
		// also refuse to claim it, or `_appLayout` would try to bounce it.
		expect(AFFILIATE_REGISTRATION_ROUTE).toBe("/registration/affiliate")
		expect(publicRegistrationFallback(AFFILIATE_REGISTRATION_ROUTE)).toBeNull()
		expect(publicRegistrationFallback("/programs/affiliate/register")).toEqual({
			programType: "affiliate",
		})
	})
})

describe("legacy slug aliases survive both guards", () => {
	it("keeps the slug the visitor arrived on", () => {
		// The guards route; they do not translate. `rai` is a live public
		// address, and rewriting it here would put the payment return through an
		// extra hop for no gain.
		const target = run(MEMBER, {}, "rai")
		expect(target?.params).toEqual({ programType: "rai" })
		expect(publicRegistrationFallback("/programs/rai/register")).toEqual({
			programType: "rai",
		})
	})

	it("hands that slug to a programme the module actually accepts", () => {
		// `load('rai')` throws `Unsupported registration type: rai`. Whichever
		// route the visitor lands on, the dispatcher resolves the alias before
		// the type reaches the wire.
		expect(resolveExamProgram("rai")?.registrationType).toBe("riskai")
	})
})
