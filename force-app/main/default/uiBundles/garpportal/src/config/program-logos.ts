import frmLogo from "@/assets/brand/programs/FRM.png"
import frrLogo from "@/assets/brand/programs/FRR.webp"
import raiLogo from "@/assets/brand/programs/RAI.webp"
import scrLogo from "@/assets/brand/programs/SCR.webp"

/**
 * Program card art self-hosted so HubSpot’s 14-day Cache-Control no longer
 * shows up in Lighthouse. API may still return HubSpot URLs — rewrite known
 * filenames to local Vite-hashed assets.
 */
export const GARP_HUB_ORIGIN = "https://www.garp.org"

const LOCAL_PROGRAM_LOGOS: Array<{ match: RegExp; src: string }> = [
	{ match: /\/SCR\.webp(?:\?|$)/i, src: scrLogo },
	{ match: /\/FRM\.png(?:\?|$)/i, src: frmLogo },
	{ match: /\/RAI\.webp(?:\?|$)/i, src: raiLogo },
	{ match: /\/FRR\.webp(?:\?|$)/i, src: frrLogo },
]

/** First-paint preload set for Programs / dashboard. */
export const COMMON_PROGRAM_LOGO_URLS = [scrLogo, frmLogo, raiLogo] as const

/** Map known HubSpot My Programs art to bundled assets; pass through otherwise. */
export function localizeProgramLogoUrl(
	url: string | null | undefined,
): string | undefined {
	const trimmed = url?.trim()
	if (!trimmed) return undefined

	const decoded = safeDecode(trimmed)
	for (const { match, src } of LOCAL_PROGRAM_LOGOS) {
		if (match.test(trimmed) || match.test(decoded)) return src
	}
	return trimmed
}

function safeDecode(value: string): string {
	try {
		return decodeURIComponent(value)
	} catch {
		return value
	}
}
