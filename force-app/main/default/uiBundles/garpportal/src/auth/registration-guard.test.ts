import { QueryClient } from "@tanstack/react-query"
import { describe, expect, it } from "vitest"

import type { CurrentUser } from "@/api/auth/current-user"
import { authQueryKeys } from "@/api/auth/query-options"
import type { RegistrationSearch } from "@/config/registration"
import {
	redirectGuestToPublicForm,
	redirectMemberToPortalForm,
} from "@/auth/registration-guard"

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

/**
 * Seeded rather than fetched: both guards read the cache synchronously when it
 * is populated, which is the path every navigation after the first one takes.
 */
function clientWith(user: CurrentUser | null) {
	const queryClient = new QueryClient()
	queryClient.setQueryData(authQueryKeys.currentUser, user)
	return queryClient
}

/** Every key is present after validation, so start from a full blank set. */
const NO_SEARCH: RegistrationSearch = {
	regCode: undefined,
	teamCode: undefined,
	stripe_return: undefined,
	oid: undefined,
	on: undefined,
}

function run(
	guard: typeof redirectGuestToPublicForm,
	user: CurrentUser | null,
	search: Partial<RegistrationSearch> = {},
) {
	try {
		guard({
			context: { queryClient: clientWith(user) },
			params: { programType: "frm" },
			search: { ...NO_SEARCH, ...search },
		})
	} catch (thrown) {
		// `redirect()` returns a wrapper; the destination sits under `options`.
		return (thrown as { options: RedirectTarget }).options
	}
	return null
}

const PAID: Partial<RegistrationSearch> = {
	stripe_return: "1",
	oid: "801",
	on: "W1",
}

describe("redirectGuestToPublicForm (member route)", () => {
	it("sends a visitor with no session to the public form", () => {
		const target = run(redirectGuestToPublicForm, null)
		expect(target?.to).toBe("/registration/$programType")
		expect(target?.params).toEqual({ programType: "frm" })
	})

	it("carries the registration code across the bounce", () => {
		// A marketing link is `/programs/frm/register?regCode=X`. Losing the code
		// on the way to the public form silently reprices the whole order.
		const target = run(redirectGuestToPublicForm, null, { regCode: "TEAM24" })
		expect(target?.search).toMatchObject({ regCode: "TEAM24" })
	})

	it("leaves a member where they are", () => {
		expect(run(redirectGuestToPublicForm, MEMBER)).toBeNull()
	})

	it("never redirects a payment return, even for a guest", () => {
		// The order is already charged; redirecting drops `oid`/`on` and the
		// candidate loses the only confirmation they get.
		expect(run(redirectGuestToPublicForm, null, PAID)).toBeNull()
	})
})

describe("redirectMemberToPortalForm (public route)", () => {
	it("sends a signed-in member to the in-portal form", () => {
		const target = run(redirectMemberToPortalForm, MEMBER)
		expect(target?.to).toBe("/programs/$programType/register")
		expect(target?.params).toEqual({ programType: "frm" })
	})

	it("leaves a guest where they are", () => {
		expect(run(redirectMemberToPortalForm, null)).toBeNull()
	})

	it("never redirects a payment return, even for a member", () => {
		expect(run(redirectMemberToPortalForm, MEMBER, PAID)).toBeNull()
	})
})

describe("the two guards together", () => {
	it("cannot bounce the same visitor back and forth", () => {
		// Both guards firing on one visitor is a redirect loop. Exactly one of
		// them may act, for any session and either route.
		for (const user of [null, MEMBER]) {
			const acted = [
				run(redirectGuestToPublicForm, user),
				run(redirectMemberToPortalForm, user),
			].filter(Boolean)
			expect(acted).toHaveLength(1)
		}
	})
})
