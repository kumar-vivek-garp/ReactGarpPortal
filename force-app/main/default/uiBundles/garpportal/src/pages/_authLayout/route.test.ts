import { isRedirect } from "@tanstack/react-router"
import { describe, expect, it } from "vitest"

import type { CurrentUser } from "@/api/auth/current-user"
import { currentUserWireHandlers } from "@/testing/msw/handlers/auth"
import { server } from "@/testing/msw/server"
import { createTestQueryClient } from "@/testing/query-client"

import { Route } from "./route"

const MEMBER: CurrentUser = {
	id: "005B",
	name: "Grace Hopper",
	garpId: "G-456",
	contactId: "003B",
	photoUrl: "/photo.png",
}

/**
 * The reverse guard reads only `location.searchStr` (raw, so a `//evil`
 * startUrl cannot hide behind the router's search parsing) — pathname is
 * fixed to the login page's own address.
 */
function run(user: CurrentUser | null | undefined, searchStr = "") {
	try {
		return {
			result: Route.options.beforeLoad?.({
				context: { queryClient: createTestQueryClient(user) },
				location: { pathname: "/Login", searchStr, search: {} },
			} as never),
			thrown: null as unknown,
		}
	} catch (thrown) {
		return { result: undefined as unknown, thrown }
	}
}

function redirectHref(thrown: unknown) {
	expect(isRedirect(thrown)).toBe(true)
	return (thrown as { options: { href?: string } }).options.href
}

describe("_authLayout guard — guest stays", () => {
	it("lets a guest see the login page, synchronously on a cache hit", () => {
		const { result, thrown } = run(null)
		expect(thrown).toBeNull()
		expect(result).toBeUndefined()
		expect(result).not.toBeInstanceOf(Promise)
	})
})

describe("_authLayout guard — signed-in visitor is moved on", () => {
	it("goes to /dashboard when no startUrl is present", () => {
		expect(redirectHref(run(MEMBER).thrown)).toBe("/dashboard")
	})

	it("honours a safe relative startUrl", () => {
		expect(redirectHref(run(MEMBER, "?startUrl=/programs/frm").thrown)).toBe(
			"/programs/frm",
		)
	})

	it("accepts a searchStr without its leading question mark", () => {
		// TanStack's searchStr has carried both shapes across versions; the
		// guard normalizes rather than trusting one.
		expect(redirectHref(run(MEMBER, "startUrl=/cpd").thrown)).toBe("/cpd")
	})

	it.each([
		["protocol-relative", "?startUrl=//evil.example"],
		["absolute URL", "?startUrl=https://evil.example/phish"],
		["garbage scheme", "?startUrl=javascript:alert(1)"],
		["backslash path", "?startUrl=/foo%5Cbar"],
	])("falls back to /dashboard for an unsafe startUrl (%s)", (_kind, searchStr) => {
		expect(redirectHref(run(MEMBER, searchStr).thrown)).toBe("/dashboard")
	})

	it("redirects synchronously on a cache hit", () => {
		// A sync throw is caught by run()'s try/catch; an async one would
		// escape it and `thrown` would stay null.
		expect(isRedirect(run(MEMBER).thrown)).toBe(true)
	})
})

describe("_authLayout guard — cache empty (identity served over the wire)", () => {
	it("leaves a guest on the login page", async () => {
		server.use(...currentUserWireHandlers(null))
		await expect(run(undefined).result).resolves.toBeUndefined()
	})

	it("moves a member on, still honouring the startUrl", async () => {
		server.use(...currentUserWireHandlers(MEMBER))
		let thrown: unknown = null
		try {
			await run(undefined, "?startUrl=/membership").result
		} catch (error) {
			thrown = error
		}
		expect(redirectHref(thrown)).toBe("/membership")
	})
})
