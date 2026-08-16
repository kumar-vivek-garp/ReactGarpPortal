export type { AppearanceMode, ThemePaletteId, ThemePersistedState } from "./types"
export { THEME_STORAGE_KEY } from "./types"
export {
	DEFAULT_THEME_PALETTE,
	THEME_PALETTES,
	isThemePaletteId,
} from "./palettes"
export {
	applyDocumentTheme,
	parsePersistedTheme,
	prefersColorSchemeDark,
	resolveAppearanceMode,
} from "./apply-document-theme"
