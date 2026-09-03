import { afterEach, describe, expect, it, vi } from "vitest"

import { LOGOUT_URL } from "@/auth/constants"
import {
	buildExperienceLogoutUrl,
	getPostLogoutReturnUrl,
	resolveReturnUrl,
} from "@/auth/logout"
import type { SfdcEnv } from "@/auth/sfdc-env"

/**
 * Only the pure URL builders are tested here. `logoutToSalesforce` ends in
 * `window.location.replace`, which jsdom exposes as a LegacyUnforgeable
 * property that cannot be spied on or replaced — its navigation tail belongs
 * to the layer-3 e2e smoke, not to this file.
 */

function stubEnv(env: SfdcEnv | undefined) {
	vi.stubGlobal("SFDC_ENV", env)
}

afterEach(() => {
	vi.unstubAllGlobals()
})

describe("getPostLogoutReturnUrl", () => {
	// jsdom's origin under Vitest is http://localhost:3000.
	it("returns the origin root when no SFDC_ENV is present", () => {
		stubEnv(undefined)
		expect(getPostLogoutReturnUrl()).toBe("http://localhost:3000/")
	})

	it("appends the site base path with a trailing slash", () => {
		stubEnv({ basePath: "/garpportal" })
		expect(getPostLogoutReturnUrl()).toBe("http://localhost:3000/garpportal/")
	})

	it("does not double a trailing slash already on the base path", () => {
		stubEnv({ basePath: "/garpportal/" })
		expect(getPostLogoutReturnUrl()).toBe("http://localhost:3000/garpportal/")
	})

	it("collapses repeated trailing slashes", () => {
		stubEnv({ basePath: "/garpportal///" })
		expect(getPostLogoutReturnUrl()).toBe("http://localhost:3000/garpportal/")
	})

	it("treats a bare-slash base path as the origin root", () => {
		// `basePath: "/"` strips to "" and must not become "http://…//".
		stubEnv({ basePath: "/" })
		expect(getPostLogoutReturnUrl()).toBe("http://localhost:3000/")
	})

	it("treats an empty base path as the origin root", () => {
		stubEnv({ basePath: "" })
		expect(getPostLogoutReturnUrl()).toBe("http://localhost:3000/")
	})
})

describe("resolveReturnUrl", () => {
	it("falls back to the public site home when no override is given", () => {
		stubEnv({ basePath: "/garpportal" })
		expect(resolveReturnUrl()).toBe("http://localhost:3000/garpportal/")
	})

	it("passes an absolute https override through untouched", () => {
		expect(resolveReturnUrl("https://www.garp.org/about")).toBe(
			"https://www.garp.org/about",
		)
	})

	it("passes an absolute http override through untouched", () => {
		expect(resolveReturnUrl("http://example.test/page")).toBe(
			"http://example.test/page",
		)
	})

	it("resolves a site-relative override against the origin", () => {
		expect(resolveReturnUrl("/dashboard")).toBe(
			"http://localhost:3000/dashboard",
		)
	})

	it("refuses a protocol-relative override (open-redirect shape)", () => {
		stubEnv(undefined)
		expect(resolveReturnUrl("//evil.test/phish")).toBe(
			"http://localhost:3000/",
		)
	})

	it("refuses a bare-word override", () => {
		stubEnv(undefined)
		expect(resolveReturnUrl("dashboard")).toBe("http://localhost:3000/")
	})
})

describe("buildExperienceLogoutUrl", () => {
	it("builds a domain-root logout path carrying retURL", () => {
		const built = buildExperienceLogoutUrl("http://localhost:3000/garpportal/")
		const url = new URL(built, "http://localhost:3000")
		expect(url.pathname).toBe(new URL(LOGOUT_URL, "http://localhost:3000").pathname)
		expect(url.searchParams.get("retURL")).toBe(
			"http://localhost:3000/garpportal/",
		)
	})

	it("returns a relative path+query, never an absolute URL", () => {
		const built = buildExperienceLogoutUrl("http://localhost:3000/")
		expect(built.startsWith("/")).toBe(true)
		expect(built).not.toContain("http://localhost:3000/secur")
	})
})
