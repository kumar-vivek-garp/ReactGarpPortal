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
 * Apply mode + palette to `<html>` (`.dark` class + `data-theme`).
 * Safe to call from the FOUC script (mirrored) and from the Zustand store.
 */
export function applyDocumentTheme({
	mode,
	palette,
}: ApplyDocumentThemeInput): "light" | "dark" {
	const root = document.documentElement
	const resolved = resolveAppearanceMode(mode)

	root.classList.remove("light", "dark")
	root.classList.add(resolved)

	const nextPalette = isThemePaletteId(palette) ? palette : DEFAULT_THEME_PALETTE
	root.setAttribute("data-theme", nextPalette)

	root.style.colorScheme = resolved
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
