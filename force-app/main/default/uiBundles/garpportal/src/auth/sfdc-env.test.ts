import { afterEach, describe, expect, it, vi } from "vitest"

import { siteBasePath } from "./sfdc-env"

afterEach(() => {
	vi.unstubAllGlobals()
})

describe("siteBasePath", () => {
	it("is empty when the bundle runs with no SFDC_ENV — local Vite", () => {
		expect(siteBasePath()).toBe("")
	})

	it("returns the org mount path without a trailing slash", () => {
		vi.stubGlobal("SFDC_ENV", { basePath: "/lwr/application/ai/c-app/" })
		expect(siteBasePath()).toBe("/lwr/application/ai/c-app")
		vi.stubGlobal("SFDC_ENV", { basePath: "/lwr/x///" })
		expect(siteBasePath()).toBe("/lwr/x")
	})

	it("treats a missing basePath as the root", () => {
		vi.stubGlobal("SFDC_ENV", {})
		expect(siteBasePath()).toBe("")
	})
})
