import { afterEach, beforeEach, describe, expect, it, vi } from "vitest"

import { clearCookie, readCookie } from "./cookies"

const EXPIRED = "Thu, 01 Jan 1970 00:00:01 GMT"

/** jsdom keeps its cookie jar across tests — start each one from nothing. */
function expireAll() {
	for (const part of document.cookie.split(";")) {
		const name = part.split("=")[0]?.trim()
		if (name) document.cookie = `${name}=; Path=/; Expires=${EXPIRED}`
	}
}

beforeEach(expireAll)
afterEach(() => {
	vi.unstubAllGlobals()
	expireAll()
})

describe("readCookie", () => {
	it("returns null when the cookie is absent", () => {
		expect(readCookie("missing")).toBeNull()
	})

	it("reads a cookie by name", () => {
		document.cookie = "session=abc123"
		expect(readCookie("session")).toBe("abc123")
	})

	it("finds a cookie that is not first in the list", () => {
		document.cookie = "first=1"
		document.cookie = "second=2"
		expect(readCookie("second")).toBe("2")
	})

	it("does not match a name that merely ends with the requested one", () => {
		// The `(?:^|; )` boundary: `xtoken` must never answer for `token`.
		document.cookie = "xtoken=wrong"
		expect(readCookie("token")).toBeNull()
	})

	it("escapes regex metacharacters in the name", () => {
		document.cookie = "aXb=wrong"
		document.cookie = "a.b=right"
		expect(readCookie("a.b")).toBe("right")
	})

	it("decodes percent-escaped values", () => {
		document.cookie = `next=${encodeURIComponent("/programs/frm register")}`
		expect(readCookie("next")).toBe("/programs/frm register")
	})

	it("returns the raw value when a percent-escape is malformed", () => {
		// decodeURIComponent throws on this; the cookie is still worth reading.
		document.cookie = "broken=%E0%A4%A"
		expect(readCookie("broken")).toBe("%E0%A4%A")
	})
})

describe("clearCookie", () => {
	it("removes a cookie set on the current host", () => {
		document.cookie = "utm=campaign"
		expect(readCookie("utm")).toBe("campaign")
		clearCookie("utm")
		expect(readCookie("utm")).toBeNull()
	})

	it("leaves other cookies alone", () => {
		document.cookie = "keep=me"
		document.cookie = "drop=me"
		clearCookie("drop")
		expect(readCookie("keep")).toBe("me")
		expect(readCookie("drop")).toBeNull()
	})
})

describe("without a document (SSR / node)", () => {
	it("reads null and clears without throwing", () => {
		// `typeof document === "undefined"` is true for a stubbed undefined value.
		vi.stubGlobal("document", undefined)
		expect(readCookie("anything")).toBeNull()
		expect(() => clearCookie("anything")).not.toThrow()
	})
})
