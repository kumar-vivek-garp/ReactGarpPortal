import { programTypeSlug } from "@/lib/program-card-links"

/**
 * Per-program brand surfaces for the Programs listing.
 *
 * Every value resolves through a `--color-*` token declared in
 * `src/styles/theme.css` — no hex, no stock Tailwind palette. Brand hues are
 * full-saturation, so they are applied at low alpha as a wash that fades to
 * transparent: strong enough to give each program an identity, weak enough that
 * it never fights the logo artwork, and it degrades sanely over `bg-card` in
 * dark mode.
 *
 * Class strings are written out in full on purpose — Tailwind's scanner cannot
 * see dynamically composed class names, so `from-${token}/15` would be dropped
 * from the build.
 */
export type ProgramBrandSurface = {
	/** Wash behind the logo / thumbnail. */
	surface: string
	/** Tinted background for the program code chip. */
	chip: string
}

const NEUTRAL_SURFACE: ProgramBrandSurface = {
	surface: "bg-muted/40",
	chip: "bg-muted text-foreground",
}

/**
 * Hue choices are semantic where the palette allows it: SCR is Sustainability &
 * Climate, ERP is Energy, and `rai-orange` is the token named for Risk AI.
 */
const PROGRAM_SURFACES: Record<string, ProgramBrandSurface> = {
	frm: {
		surface: "bg-linear-to-b from-garp-cyan/15 to-transparent",
		chip: "bg-garp-cyan/15 text-foreground",
	},
	scr: {
		surface: "bg-linear-to-b from-success-green/15 to-transparent",
		chip: "bg-success-green/15 text-foreground",
	},
	erp: {
		surface: "bg-linear-to-b from-garp-saffron/15 to-transparent",
		chip: "bg-garp-saffron/15 text-foreground",
	},
	rai: {
		surface: "bg-linear-to-b from-rai-orange/15 to-transparent",
		chip: "bg-rai-orange/15 text-foreground",
	},
	riskai: {
		surface: "bg-linear-to-b from-rai-orange/15 to-transparent",
		chip: "bg-rai-orange/15 text-foreground",
	},
	raij: {
		surface: "bg-linear-to-b from-rai-blue/15 to-transparent",
		chip: "bg-rai-blue/15 text-foreground",
	},
	frr: {
		surface: "bg-linear-to-b from-bright-purple/15 to-transparent",
		chip: "bg-bright-purple/15 text-foreground",
	},
	ffr: {
		surface: "bg-linear-to-b from-bright-purple/15 to-transparent",
		chip: "bg-bright-purple/15 text-foreground",
	},
}

/**
 * Brand surface for a program type; neutral muted for anything unmapped.
 *
 * Program types can carry a year suffix (`FRR25`), so an exact miss retries
 * against the base code before giving up — otherwise each new intake year would
 * silently fall back to grey.
 */
export function programBrandSurface(
	programType: string | null | undefined,
): ProgramBrandSurface {
	if (!programType?.trim()) return NEUTRAL_SURFACE

	const slug = programTypeSlug(programType)
	const exact = PROGRAM_SURFACES[slug]
	if (exact) return exact

	const base = slug.replace(/\d+$/, "")
	return PROGRAM_SURFACES[base] ?? NEUTRAL_SURFACE
}
