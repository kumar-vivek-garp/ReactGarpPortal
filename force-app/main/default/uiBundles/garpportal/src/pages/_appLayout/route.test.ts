import { isRedirect } from "@tanstack/react-router"
import { describe, expect, it } from "vitest"

import type { CurrentUser } from "@/api/auth/current-user"
import { authQueryKeys } from "@/api/auth/query-options"
import { currentUserWireHandlers } from "@/testing/msw/handlers/auth"
import { server } from "@/testing/msw/server"
import { createTestQueryClient } from "@/testing/query-client"

import { Route } from "./route"

type RedirectOptions = {
	to?: string
	params?: Record<string, string>
	search?: Record<string, unknown>
}

const MEMBER: CurrentUser = {
	id: "005A",
	name: "Ada Lovelace",
	garpId: "G-123",
	contactId: "003A",
	photoUrl: "/photo.png",
}

function guardLocation(
	pathname: string,
	search: Record<string, unknown> = {},
	searchStr = "",
) {
	return { pathname, searchStr, search, href: `${pathname}${searchStr}` }
}

/** Invoke the layout guard exactly as the router would, minus the router. */
function runGuard(
	user: CurrentUser | null | undefined,
	location: ReturnType<typeof guardLocation>,
) {
	const queryClient = createTestQueryClient(user)
	return {
		queryClient,
		invoke: () =>
			Route.options.beforeLoad?.({
				context: { queryClient },
				location,
			} as never),
	}
}

function catchSync(invoke: () => unknown) {
	try {
		return { result: invoke(), thrown: null as unknown }
	} catch (thrown) {
		return { result: undefined as unknown, thrown }
	}
}

async function catchAsync(promise: unknown) {
	try {
		await promise
		return null as unknown
	} catch (thrown) {
		return thrown
	}
}

describe("_appLayout guard — member in cache (sync path)", () => {
	it("passes through without redirecting", () => {
		const { result, thrown } = catchSync(
			runGuard(MEMBER, guardLocation("/dashboard")).invoke,
		)
		expect(thrown).toBeNull()
		expect(result).toBeUndefined()
	})

	it("stays synchronous on a cache hit — the anti-flash contract", () => {
		// An async beforeLoad always returns a Promise, which flashes
		// AppRoutePending on every sidebar click. A cache hit must return a
		// plain value so the router can proceed in the same tick.
		const { result } = catchSync(
			runGuard(MEMBER, guardLocation("/programs")).invoke,
		)
		expect(result).not.toBeInstanceOf(Promise)
	})
})

describe("_appLayout guard — guest in cache", () => {
	it("redirects a normal path to Login, carrying a startUrl", () => {
		const { thrown } = catchSync(
			runGuard(null, guardLocation("/dashboard", { foo: "1" }, "?foo=1")).invoke,
		)
		expect(isRedirect(thrown)).toBe(true)
		const options = (thrown as { options: RedirectOptions }).options
		expect(options.to).toBe("/Login")
		expect(options.search).toEqual({ startUrl: "/dashboard?foo=1" })
	})

	it("throws synchronously on a cache hit — no pending flash on the bounce", () => {
		// catchSync only sees a synchronous throw; a rejected Promise would
		// escape it and fail the isRedirect assertion below.
		const { thrown } = catchSync(runGuard(null, guardLocation("/cpd")).invoke)
		expect(isRedirect(thrown)).toBe(true)
	})

	it("hands a member program registration path to its public twin, search intact", () => {
		const { thrown } = catchSync(
			runGuard(
				null,
				guardLocation(
					"/programs/frm/register",
					{ regCode: "TEAM24" },
					"?regCode=TEAM24",
				),
			).invoke,
		)
		expect(isRedirect(thrown)).toBe(true)
		const options = (thrown as { options: RedirectOptions }).options
		expect(options.to).toBe("/registration/$programType")
		expect(options.params).toEqual({ programType: "frm" })
		// A regCode lost on the bounce silently reprices the order.
		expect(options.search).toEqual({ regCode: "TEAM24" })
	})

	it.each([
		["event", "/events/event/a2h5d002/register", "/registration/event/$eventId", "a2h5d002"],
		["webcast", "/events/webcast/a2h5d000/register", "/registration/webcast/$eventId", "a2h5d000"],
		["chaptermeeting", "/events/chaptermeeting/a2h5d001/register", "/registration/chaptermeeting/$eventId", "a2h5d001"],
	])("hands the %s member event path to its public twin", (_variant, pathname, to, eventId) => {
		const { thrown } = catchSync(runGuard(null, guardLocation(pathname)).invoke)
		expect(isRedirect(thrown)).toBe(true)
		const options = (thrown as { options: RedirectOptions }).options
		expect(options.to).toBe(to)
		expect(options.params).toEqual({ eventId })
	})

	it("does not treat a non-registration programme subpage as a twin", () => {
		const { thrown } = catchSync(
			runGuard(null, guardLocation("/programs/frm/results")).invoke,
		)
		const options = (thrown as { options: RedirectOptions }).options
		expect(options.to).toBe("/Login")
	})
})

describe("_appLayout guard — cache empty (async, identity served over the wire)", () => {
	it("returns a Promise: the not-yet-fetched path is the async one", async () => {
		server.use(...currentUserWireHandlers(MEMBER))
		const { invoke } = runGuard(undefined, guardLocation("/dashboard"))
		const pending = invoke()
		expect(pending).toBeInstanceOf(Promise)
		await pending
	})

	it("lets a member through and caches the identity for the next navigation", async () => {
		server.use(...currentUserWireHandlers(MEMBER))
		const { queryClient, invoke } = runGuard(
			undefined,
			guardLocation("/dashboard"),
		)
		await expect(invoke()).resolves.toBeUndefined()
		// The follow-up contract: the fetch primed the cache, so the next
		// beforeLoad takes the synchronous branch.
		expect(
			queryClient.getQueryData<CurrentUser | null>(authQueryKeys.currentUser),
		).toMatchObject({ id: "005A", contactId: "003A" })
	})

	it("redirects a guest to Login once the wire answers", async () => {
		server.use(...currentUserWireHandlers(null))
		const { invoke } = runGuard(undefined, guardLocation("/dashboard"))
		const thrown = await catchAsync(invoke())
		expect(isRedirect(thrown)).toBe(true)
		expect((thrown as { options: RedirectOptions }).options.to).toBe("/Login")
	})

	it("still hands a guest's registration path to the public twin, regCode intact", async () => {
		server.use(...currentUserWireHandlers(null))
		const { invoke } = runGuard(
			undefined,
			guardLocation("/programs/scr/register", { regCode: "T1" }, "?regCode=T1"),
		)
		const thrown = await catchAsync(invoke())
		expect(isRedirect(thrown)).toBe(true)
		const options = (thrown as { options: RedirectOptions }).options
		expect(options.to).toBe("/registration/$programType")
		expect(options.params).toEqual({ programType: "scr" })
		expect(options.search).toEqual({ regCode: "T1" })
	})
})
