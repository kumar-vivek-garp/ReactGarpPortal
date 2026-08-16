import { create } from "zustand"
import { persist } from "zustand/middleware"

import {
	DEFAULT_THEME_PALETTE,
	THEME_STORAGE_KEY,
	applyDocumentTheme,
	prefersColorSchemeDark,
	resolveAppearanceMode,
	type AppearanceMode,
	type ThemePaletteId,
} from "@/config/theme"

type ThemeState = {
	mode: AppearanceMode
	palette: ThemePaletteId
	/** Last applied light/dark (kept in sync for Sonner / toggles). */
	resolved: "light" | "dark"
	setMode: (mode: AppearanceMode) => void
	setPalette: (palette: ThemePaletteId) => void
	/** Flip light ↔ dark; if system, pick the opposite of the resolved mode. */
	toggleMode: () => void
}

function syncDocument(
	mode: AppearanceMode,
	palette: ThemePaletteId,
): "light" | "dark" {
	if (typeof document === "undefined") {
		return resolveAppearanceMode(mode, false)
	}
	return applyDocumentTheme({ mode, palette })
}

export const useThemeStore = create<ThemeState>()(
	persist(
		(set, get) => ({
			mode: "system",
			palette: DEFAULT_THEME_PALETTE,
			resolved: "light",
			setMode: (mode) => {
				const resolved = syncDocument(mode, get().palette)
				set({ mode, resolved })
			},
			setPalette: (palette) => {
				const resolved = syncDocument(get().mode, palette)
				set({ palette, resolved })
			},
			toggleMode: () => {
				const { mode, palette, resolved } = get()
				const current =
					mode === "system"
						? resolved
						: resolveAppearanceMode(mode, prefersColorSchemeDark())
				const next: AppearanceMode = current === "dark" ? "light" : "dark"
				const applied = syncDocument(next, palette)
				set({ mode: next, resolved: applied })
			},
		}),
		{
			name: THEME_STORAGE_KEY,
			partialize: (state) => ({ mode: state.mode, palette: state.palette }),
			onRehydrateStorage: () => (state) => {
				if (!state) return
				const resolved = syncDocument(state.mode, state.palette)
				useThemeStore.setState({ resolved })
			},
		},
	),
)

/** Keep `.dark` in sync when OS preference changes and mode is `system`. */
export function subscribeSystemColorScheme(): () => void {
	if (typeof window === "undefined" || !window.matchMedia) {
		return () => undefined
	}
	const mq = window.matchMedia("(prefers-color-scheme: dark)")
	const onChange = () => {
		const { mode, palette } = useThemeStore.getState()
		if (mode !== "system") return
		const resolved = syncDocument(mode, palette)
		useThemeStore.setState({ resolved })
	}
	mq.addEventListener("change", onChange)
	return () => mq.removeEventListener("change", onChange)
}

/** Apply current store state once at boot (covers Vite first paint after FOUC). */
export function bootstrapThemeFromStore(): void {
	const { mode, palette } = useThemeStore.getState()
	const resolved = syncDocument(mode, palette)
	useThemeStore.setState({ resolved })
}
