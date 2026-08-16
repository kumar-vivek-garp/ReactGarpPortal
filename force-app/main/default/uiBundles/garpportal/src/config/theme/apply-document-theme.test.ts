import { describe, expect, it, vi, afterEach } from "vitest"

import {
	applyDocumentTheme,
	parsePersistedTheme,
	resolveAppearanceMode,
} from "./apply-document-theme"

afterEach(() => {
	document.documentElement.className = ""
	document.documentElement.removeAttribute("data-theme")
	document.documentElement.style.colorScheme = ""
	vi.restoreAllMocks()
})

describe("resolveAppearanceMode", () => {
	it("returns light/dark when fixed", () => {
		expect(resolveAppearanceMode("light", true)).toBe("light")
		expect(resolveAppearanceMode("dark", false)).toBe("dark")
	})

	it("follows system when mode is system", () => {
		expect(resolveAppearanceMode("system", true)).toBe("dark")
		expect(resolveAppearanceMode("system", false)).toBe("light")
	})
})

describe("applyDocumentTheme", () => {
	it("sets dark class and data-theme", () => {
		const resolved = applyDocumentTheme({ mode: "dark", palette: "default" })
		expect(resolved).toBe("dark")
		expect(document.documentElement.classList.contains("dark")).toBe(true)
		expect(document.documentElement.getAttribute("data-theme")).toBe("default")
		expect(document.documentElement.style.colorScheme).toBe("dark")
	})

	it("sets light class", () => {
		applyDocumentTheme({ mode: "light", palette: "default" })
		expect(document.documentElement.classList.contains("light")).toBe(true)
		expect(document.documentElement.classList.contains("dark")).toBe(false)
	})
})

describe("parsePersistedTheme", () => {
	it("reads zustand persist envelope", () => {
		expect(
			parsePersistedTheme(
				JSON.stringify({ state: { mode: "dark", palette: "default" }, version: 0 }),
			),
		).toEqual({ mode: "dark", palette: "default" })
	})

	it("returns null for garbage", () => {
		expect(parsePersistedTheme("nope")).toBeNull()
		expect(parsePersistedTheme(null)).toBeNull()
	})
})
