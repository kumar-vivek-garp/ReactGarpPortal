import { afterEach, beforeEach, describe, expect, it, vi } from "vitest"

const hoisted = vi.hoisted(() => ({
	systemResolvesTo: "light" as "light" | "dark",
}))

// vi.mock (not MSW): applyDocumentTheme mutates <html> with no HTTP boundary and
// is fully covered by apply-document-theme.test.ts — here we only assert the
// store drives it and trusts its return value.
vi.mock("@/config/theme/apply-document-theme", async (importOriginal) => {
	const actual = await importOriginal<
		typeof import("@/config/theme/apply-document-theme")
	>()
	return {
		...actual,
		applyDocumentTheme: vi.fn(
			({ mode }: { mode: "light" | "dark" | "system" }) =>
				mode === "system" ? hoisted.systemResolvesTo : mode,
		),
	}
})

import { THEME_STORAGE_KEY, applyDocumentTheme } from "@/config/theme"
import {
	bootstrapThemeFromStore,
	subscribeSystemColorScheme,
	useThemeStore,
} from "@/store/theme-store"

const applied = vi.mocked(applyDocumentTheme)

beforeEach(() => {
	hoisted.systemResolvesTo = "light"
	useThemeStore.setState({ mode: "system", palette: "default", resolved: "light" })
	window.localStorage.clear()
	applied.mockClear()
})

describe("toggleMode", () => {
	it("flips system mode to the opposite of the last resolved value", () => {
		useThemeStore.setState({ mode: "system", resolved: "light" })

		useThemeStore.getState().toggleMode()

		expect(useThemeStore.getState().mode).toBe("dark")
		expect(useThemeStore.getState().resolved).toBe("dark")
		expect(applied).toHaveBeenCalledWith({ mode: "dark", palette: "default" })
	})

	it("flips system mode to light when the resolved value was dark", () => {
		useThemeStore.setState({ mode: "system", resolved: "dark" })

		useThemeStore.getState().toggleMode()

		expect(useThemeStore.getState().mode).toBe("light")
		expect(useThemeStore.getState().resolved).toBe("light")
	})

	it("flips an explicit light mode to dark and back", () => {
		useThemeStore.setState({ mode: "light", resolved: "light" })

		useThemeStore.getState().toggleMode()
		expect(useThemeStore.getState().mode).toBe("dark")

		useThemeStore.getState().toggleMode()
		expect(useThemeStore.getState().mode).toBe("light")
	})
})

describe("setMode / setPalette", () => {
	it("applies the new mode to the document and records what it resolved to", () => {
		hoisted.systemResolvesTo = "dark"

		useThemeStore.getState().setMode("system")

		expect(applied).toHaveBeenCalledWith({ mode: "system", palette: "default" })
		// `resolved` comes from applyDocumentTheme's return, not an assumption.
		expect(useThemeStore.getState().resolved).toBe("dark")
	})

	it("re-applies the current mode when the palette changes", () => {
		useThemeStore.setState({ mode: "dark", resolved: "dark" })

		useThemeStore.getState().setPalette("default")

		expect(applied).toHaveBeenCalledWith({ mode: "dark", palette: "default" })
	})
})

describe("persistence", () => {
	it("persists mode and palette but never the resolved value", () => {
		useThemeStore.getState().setMode("dark")

		const raw = window.localStorage.getItem(THEME_STORAGE_KEY)
		expect(raw).not.toBeNull()
		const parsed = JSON.parse(raw as string) as { state: unknown }
		// toEqual is exact: an extra `resolved` key would fail this.
		expect(parsed.state).toEqual({ mode: "dark", palette: "default" })
	})

	it("re-applies the persisted theme to the document on rehydrate", async () => {
		window.localStorage.setItem(
			THEME_STORAGE_KEY,
			JSON.stringify({ state: { mode: "dark", palette: "default" }, version: 0 }),
		)
		applied.mockClear()

		await useThemeStore.persist.rehydrate()

		expect(applied).toHaveBeenCalledWith({ mode: "dark", palette: "default" })
		expect(useThemeStore.getState().mode).toBe("dark")
		expect(useThemeStore.getState().resolved).toBe("dark")
	})
})

describe("subscribeSystemColorScheme", () => {
	type Listener = () => void
	const listeners = new Set<Listener>()
	const originalMatchMedia = window.matchMedia

	beforeEach(() => {
		listeners.clear()
		window.matchMedia = ((query: string) => ({
			matches: false,
			media: query,
			addEventListener: (_: string, fn: Listener) => listeners.add(fn),
			removeEventListener: (_: string, fn: Listener) => listeners.delete(fn),
		})) as unknown as typeof window.matchMedia
	})

	afterEach(() => {
		window.matchMedia = originalMatchMedia
	})

	it("re-applies the theme when the OS scheme changes in system mode", () => {
		const unsubscribe = subscribeSystemColorScheme()
		hoisted.systemResolvesTo = "dark"
		applied.mockClear()

		listeners.forEach((fn) => fn())

		expect(applied).toHaveBeenCalledWith({ mode: "system", palette: "default" })
		expect(useThemeStore.getState().resolved).toBe("dark")
		unsubscribe()
	})

	it("ignores OS scheme changes when an explicit mode is set", () => {
		useThemeStore.setState({ mode: "dark", resolved: "dark" })
		const unsubscribe = subscribeSystemColorScheme()
		applied.mockClear()

		listeners.forEach((fn) => fn())

		expect(applied).not.toHaveBeenCalled()
		unsubscribe()
	})

	it("removes its listener on unsubscribe", () => {
		const unsubscribe = subscribeSystemColorScheme()
		expect(listeners.size).toBe(1)

		unsubscribe()

		expect(listeners.size).toBe(0)
	})
})

describe("bootstrapThemeFromStore", () => {
	it("applies the current store state and refreshes the stale resolved value", () => {
		hoisted.systemResolvesTo = "dark"
		useThemeStore.setState({ mode: "system", resolved: "light" })

		bootstrapThemeFromStore()

		expect(applied).toHaveBeenCalledWith({ mode: "system", palette: "default" })
		expect(useThemeStore.getState().resolved).toBe("dark")
	})
})
