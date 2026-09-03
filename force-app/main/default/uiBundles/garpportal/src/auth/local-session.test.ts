import { afterEach, describe, expect, it, vi } from "vitest"

import {
	clearLocalLogoutFlag,
	isLocallyLoggedOut,
	markLocallyLoggedOut,
} from "@/auth/local-session"

const FLAG = "garpportal:local-logged-out"

afterEach(() => {
	vi.restoreAllMocks()
	sessionStorage.removeItem(FLAG)
})

describe("the local logout flag", () => {
	it("round-trips: mark, read, clear", () => {
		expect(isLocallyLoggedOut()).toBe(false)

		markLocallyLoggedOut()
		expect(isLocallyLoggedOut()).toBe(true)

		clearLocalLogoutFlag()
		expect(isLocallyLoggedOut()).toBe(false)
	})

	it("reads only the exact sentinel value", () => {
		sessionStorage.setItem(FLAG, "yes")
		expect(isLocallyLoggedOut()).toBe(false)
	})

	/**
	 * Private-mode / blocked-storage browsers throw from every Storage call.
	 * The flag is a convenience, so all three helpers must swallow that.
	 */
	it("treats a throwing storage as logged in, without propagating", () => {
		vi.spyOn(Storage.prototype, "getItem").mockImplementation(() => {
			throw new Error("denied")
		})
		expect(isLocallyLoggedOut()).toBe(false)
	})

	it("ignores a storage that refuses writes", () => {
		vi.spyOn(Storage.prototype, "setItem").mockImplementation(() => {
			throw new Error("quota")
		})
		vi.spyOn(Storage.prototype, "removeItem").mockImplementation(() => {
			throw new Error("quota")
		})
		expect(() => markLocallyLoggedOut()).not.toThrow()
		expect(() => clearLocalLogoutFlag()).not.toThrow()
	})
})
