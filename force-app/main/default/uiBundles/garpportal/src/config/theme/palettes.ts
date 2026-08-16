import type { ThemePaletteId } from "./types"

export type ThemePaletteMeta = {
	id: ThemePaletteId
	label: string
	/** When false, UI pickers should hide this id until CSS packs exist. */
	enabled: boolean
}

/**
 * Registry for future accent packs (blue / red / green).
 * Only `default` is enabled in v1 — no store rewrite needed to add more.
 */
export const THEME_PALETTES: ThemePaletteMeta[] = [
	{ id: "default", label: "Default", enabled: true },
	// Future:
	// { id: "blue", label: "Blue", enabled: false },
	// { id: "red", label: "Red", enabled: false },
	// { id: "green", label: "Green", enabled: false },
]

export const DEFAULT_THEME_PALETTE: ThemePaletteId = "default"

export function isThemePaletteId(value: unknown): value is ThemePaletteId {
	return value === "default"
}
