/** Appearance preference (independent of color palette). */
export type AppearanceMode = "light" | "dark" | "system"

/**
 * Color palette id. v1 ships `default` only — add `blue` / `red` / `green`
 * here when CSS packs land under `[data-theme=…]`.
 */
export type ThemePaletteId = "default"

export const THEME_STORAGE_KEY = "garpportal-theme"

export type ThemePersistedState = {
	mode: AppearanceMode
	palette: ThemePaletteId
}
