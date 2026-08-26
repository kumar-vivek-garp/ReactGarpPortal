import { DEFAULT_THEME_PALETTE, isThemePaletteId } from "./palettes"
import type { AppearanceMode, ThemePaletteId } from "./types"

export type ApplyDocumentThemeInput = {
	mode: AppearanceMode
	palette: ThemePaletteId
}

/** Resolve light/dark from preference + system. */
export function resolveAppearanceMode(
	mode: AppearanceMode,
	preferDark = prefersColorSchemeDark(),
): "light" | "dark" {
	if (mode === "system") return preferDark ? "dark" : "light"
	return mode
}

export function prefersColorSchemeDark(): boolean {
	if (typeof window === "undefined" || typeof window.matchMedia !== "function") {
		return false
	}
	return window.matchMedia("(prefers-color-scheme: dark)").matches
}

/**
 * Suspend every CSS transition for the single frame a theme swap repaints in.
 *
 * Hover affordances all over the app carry `transition-colors`, so flipping
 * `.dark` makes those elements *animate* to the new palette over ~150ms while
 * everything else snaps — the chrome appears to lag the page. next-themes'
 * `disableTransitionOnChange` fixes this exact artefact the same way: inject
 * `transition: none !important`, apply the theme, force a restyle so the swap
 * lands while suppressed, then re-enable on the next tick.
 */
function withTransitionsSuspended(apply: () => void): void {
	const style = document.createElement("style")
	style.setAttribute("data-suppress-transitions", "")
	style.appendChild(
		document.createTextNode(
			"*,*::before,*::after{transition:none!important}",
		),
	)
	document.head.appendChild(style)

	apply()

	// Force the recalc now, while transitions are off.
	void window.getComputedStyle(document.body).transition
	window.setTimeout(() => {
		// `remove()` over `removeChild`: a no-op if something else (another
		// rapid toggle, a test sweep) already detached this suppressor.
		style.remove()
	}, 1)
}

/**
 * Apply mode + palette to `<html>` (`.dark` class + `data-theme`).
 * Safe to call from the FOUC script (mirrored) and from the Zustand store.
 */
export function applyDocumentTheme({
	mode,
	palette,
}: ApplyDocumentThemeInput): "light" | "dark" {
	const root = document.documentElement
	const resolved = resolveAppearanceMode(mode)
	const nextPalette = isThemePaletteId(palette) ? palette : DEFAULT_THEME_PALETTE

	const changes =
		!root.classList.contains(resolved) ||
		root.getAttribute("data-theme") !== nextPalette

	const apply = () => {
		root.classList.remove("light", "dark")
		root.classList.add(resolved)
		root.setAttribute("data-theme", nextPalette)
		root.style.colorScheme = resolved
	}

	// Only an actual swap suspends transitions — the boot/rehydrate calls that
	// re-assert the current theme must not cut short an in-flight hover fade.
	if (changes) withTransitionsSuspended(apply)
	else apply()

	return resolved
}

export function parsePersistedTheme(raw: string | null): {
	mode: AppearanceMode
	palette: ThemePaletteId
} | null {
	if (!raw) return null
	try {
		const parsed = JSON.parse(raw) as {
			state?: { mode?: unknown; palette?: unknown }
			mode?: unknown
			palette?: unknown
		}
		// Zustand persist wraps as `{ state: { … }, version }`
		const source = parsed.state ?? parsed
		const mode =
			source.mode === "light" ||
			source.mode === "dark" ||
			source.mode === "system"
				? source.mode
				: null
		if (!mode) return null
		const palette = isThemePaletteId(source.palette)
			? source.palette
			: DEFAULT_THEME_PALETTE
		return { mode, palette }
	} catch {
		return null
	}
}
