import { afterEach, beforeEach, describe, expect, it, vi } from "vitest"

/**
 * `dismissed` is module state (idempotence across HMR), so each test that
 * needs a fresh "not yet dismissed" world imports a fresh module instance.
 */
async function freshDismiss() {
	vi.resetModules()
	const mod = await import("@/lib/boot-splash")
	return mod.dismissBootSplash
}

function mountSplash() {
	const splash = document.createElement("div")
	splash.id = "boot-splash"
	document.body.appendChild(splash)
	return splash
}

beforeEach(() => {
	vi.useFakeTimers()
})

afterEach(() => {
	vi.useRealTimers()
	document.getElementById("boot-splash")?.remove()
})

describe("dismissBootSplash", () => {
	it("fades the splash, hides it from AT, and removes it after the fade", async () => {
		const dismiss = await freshDismiss()
		const splash = mountSplash()

		dismiss()

		expect(splash.classList.contains("boot-splash--done")).toBe(true)
		expect(splash.getAttribute("aria-hidden")).toBe("true")
		expect(splash.getAttribute("aria-busy")).toBe("false")
		expect(splash.isConnected).toBe(true)

		vi.advanceTimersByTime(200)
		expect(splash.isConnected).toBe(false)
	})

	it("is idempotent — a second call after dismissal changes nothing", async () => {
		const dismiss = await freshDismiss()
		mountSplash()
		dismiss()
		vi.advanceTimersByTime(200)

		// HMR / layout remount path: no splash left, flag already set.
		expect(() => dismiss()).not.toThrow()
		expect(document.getElementById("boot-splash")).toBeNull()
	})

	it("leaves a splash alone that something else already removed mid-fade", async () => {
		const dismiss = await freshDismiss()
		const splash = mountSplash()

		dismiss()
		splash.remove()

		expect(() => vi.advanceTimersByTime(200)).not.toThrow()
		expect(splash.isConnected).toBe(false)
	})

	it("marks itself done when no splash element exists at all", async () => {
		const dismiss = await freshDismiss()

		expect(() => dismiss()).not.toThrow()

		// Once marked, a splash mounted later is never touched.
		const late = mountSplash()
		dismiss()
		expect(late.classList.contains("boot-splash--done")).toBe(false)
	})
})
