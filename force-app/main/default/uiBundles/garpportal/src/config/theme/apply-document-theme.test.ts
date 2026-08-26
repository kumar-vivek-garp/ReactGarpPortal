import { describe, expect, it, vi, afterEach } from "vitest"

import {
	applyDocumentTheme,
	parsePersistedTheme,
	resolveAppearanceMode,
} from "./apply-document-theme"

const SUPPRESSOR_SELECTOR = "style[data-suppress-transitions]"

afterEach(() => {
	document.documentElement.className = ""
	document.documentElement.removeAttribute("data-theme")
	document.documentElement.style.colorScheme = ""
	// Suppressors from real-timer tests remove themselves asynchronously;
	// sweep them so they cannot leak into a later fake-timer test.
	document.head
		.querySelectorAll(SUPPRESSOR_SELECTOR)
		.forEach((node) => node.remove())
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

	it("suspends transitions for the swap, then lifts the suppression", () => {
		vi.useFakeTimers()
		try {
			applyDocumentTheme({ mode: "light", palette: "default" })
			vi.runAllTimers()
			document.head
				.querySelectorAll(SUPPRESSOR_SELECTOR)
				.forEach((node) => node.remove())

			applyDocumentTheme({ mode: "dark", palette: "default" })
			const suppressor = document.head.querySelector(SUPPRESSOR_SELECTOR)
			expect(suppressor?.textContent).toContain("transition:none!important")

			vi.runAllTimers()
			expect(document.head.querySelector(SUPPRESSOR_SELECTOR)).toBeNull()
		} finally {
			vi.useRealTimers()
		}
	})

	it("does not suspend transitions when re-asserting the current theme", () => {
		vi.useFakeTimers()
		try {
			applyDocumentTheme({ mode: "dark", palette: "default" })
			vi.runAllTimers()
			document.head
				.querySelectorAll(SUPPRESSOR_SELECTOR)
				.forEach((node) => node.remove())

			// Same theme again — boot/rehydrate path — must not inject a suppressor.
			applyDocumentTheme({ mode: "dark", palette: "default" })
			expect(document.head.querySelector(SUPPRESSOR_SELECTOR)).toBeNull()
		} finally {
			vi.useRealTimers()
		}
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
