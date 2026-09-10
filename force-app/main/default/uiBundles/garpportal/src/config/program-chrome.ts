import frmBanner from "@/assets/brand/programs/chrome/frm-banner.jpg"
import frmSeal from "@/assets/brand/programs/chrome/frm-seal.png"
import frmWordmarkInk from "@/assets/brand/programs/chrome/frm-wordmark-ink.png"
import frmWordmark from "@/assets/brand/programs/chrome/frm-wordmark-knockout.png"
import raiBanner from "@/assets/brand/programs/chrome/rai-banner.jpg"
import raiSeal from "@/assets/brand/programs/chrome/rai-seal.png"
import raiWordmark from "@/assets/brand/programs/chrome/rai-wordmark-knockout.png"
import scrBanner from "@/assets/brand/programs/chrome/scr-banner.jpg"
import scrSeal from "@/assets/brand/programs/chrome/scr-seal.png"
import scrWordmarkInk from "@/assets/brand/programs/chrome/scr-wordmark-ink.png"
import scrWordmark from "@/assets/brand/programs/chrome/scr-wordmark-knockout.png"
import { programTypeSlug } from "@/lib/program-card-links"

/**
 * Per-programme chrome for the registration surfaces — the black navbar
 * wordmark, the banner artwork and seal, and the page canvas tint that the 2027
 * Reg Redesign puts around a public exam registration, plus the seal and wash
 * the signed-in bar wears.
 *
 * Guest and member draw from the same record, and take different parts of it: a
 * guest gets the wordmark, banner and canvas, a member gets the seal and
 * `barWash`. Keeping one row per programme is what stops the two audiences
 * disagreeing about what colour a programme is.
 *
 * Deliberately separate from the two neighbouring brand configs, because they
 * answer different questions:
 *
 * - `config/program-brand.ts` — the low-alpha washes behind programme *cards*
 *   in the Programs listing.
 * - `config/program-logos.ts` — rewriting inbound HubSpot card-art URLs to
 *   bundled copies, keyed by filename, not by slug.
 * - this file — the chrome a registration surface wears.
 *
 * Comparing the four 2027 frames showed the chrome is the ONLY thing that
 * varies between programmes: navbar wordmark, banner art, seal and canvas tint
 * change; the Sign In pill, the footer and every card inside the form are
 * identical. FRM, SCR and RAI are all built, and adding one was in fact three
 * assets and a row here — no new component either time.
 *
 * FRM-OSTA needs no row: it is the same form as FRM under different
 * conditions, not its own slug, so it already inherits FRM's chrome.
 *
 * **Banner art must be stored pre-cropped to the banner's 8.675 aspect**, and
 * each frame composites its art at a different vertical offset, so the crop is
 * per-programme (FRM 46/906, SCR 88/906, RAI 101/933 from the top of the
 * rendered art). See `registration-banner.tsx` for why an uncropped source
 * fails silently rather than loudly.
 *
 * Class strings are written out in full on purpose — Tailwind's scanner cannot
 * see dynamically composed class names, so `canvas-${slug}` would be dropped
 * from the build. Same constraint `program-brand.ts` documents.
 */
export type ProgramChrome = {
	/**
	 * Knockout lockup — white artwork, for a DARK surface.
	 *
	 * The guest navbar follows the portal's toolbar tokens, so it is light in
	 * light mode and this would vanish on it. `wordmarkInk` is the light-mode
	 * counterpart; the two are swapped by the `dark:` variant rather than by JS,
	 * so there is no flash on first paint.
	 */
	wordmark: string
	/**
	 * The same lockup in dark ink, for a LIGHT surface — navy eye plus the
	 * brand-coloured acronym. Published by GARP alongside the knockout at
	 * identical dimensions, so the pair swaps without the logo changing shape.
	 *
	 * Undefined where GARP has not published one. RAI is that case: only
	 * knockouts exist for its short lockup (`GARP RAI Logo.png` is the stacked
	 * GARP-over-"RAI | Risk and AI" version, a different shape). Its knockout is
	 * 99% monochrome white — 8 coloured pixels out of 915 — so the navbar
	 * darkens it with a filter instead, which is shape-exact and loses
	 * effectively nothing. Swap in a real asset here the moment one exists.
	 */
	wordmarkInk?: string
	/** Accessible name for the wordmark; it names the link that wraps it. */
	label: string
	/** Circular certification roundel shown beside the banner title. */
	seal: string
	/**
	 * Wide banner background. A raster, not a gradient: the artwork is
	 * painterly with a line pattern over it, and no CSS gradient reproduces it.
	 */
	bannerArt: string
	/** Literal canvas class — reassigns `--background`. See `layout.css`. */
	canvas: string
	/**
	 * Literal wash for the MEMBER registration / exam-setup sticky bar, where
	 * there is no room for a banner. A gradient is a `background-image`, so it
	 * composites over the bar's `bg-background` and the bar stays fully opaque —
	 * which it must, since cards scroll under it.
	 *
	 * Deliberately NOT `programBrandSurface()`, which is the obvious reuse and
	 * the wrong one: that map gives SCR `success-green`, which would put a green
	 * wash under SCR's gold artwork and saffron acronym. The hue here follows
	 * the programme's own `heading.highlightToken`, so the bar agrees with the
	 * title sitting on it. (That `program-brand.ts` and the nav disagree about
	 * SCR is a pre-existing inconsistency, not one this introduced.)
	 *
	 * Kept low — 12% — because the bar also carries the purple total and the
	 * purple submit, and those have to stay legible on it in both themes.
	 */
	barWash: string
	/**
	 * Literal desktop title-size class. Omit for the 30px `app:text-title` that
	 * FRM and SCR use; RAI's frame sets 40px and its title is short enough to
	 * carry it.
	 *
	 * Literal, like `canvas`, and for the same reason — Tailwind's scanner
	 * cannot see a composed class name.
	 */
	titleSizeClass?: string
}

const PROGRAM_CHROME: Record<string, ProgramChrome> = {
	frm: {
		wordmark: frmWordmark,
		wordmarkInk: frmWordmarkInk,
		label: "FRM",
		seal: frmSeal,
		bannerArt: frmBanner,
		canvas: "canvas-frm",
		barWash: "bg-linear-to-b from-garp-cyan/12 to-transparent",
	},
	scr: {
		wordmark: scrWordmark,
		wordmarkInk: scrWordmarkInk,
		label: "SCR",
		seal: scrSeal,
		bannerArt: scrBanner,
		canvas: "canvas-scr",
		barWash: "bg-linear-to-b from-garp-saffron/12 to-transparent",
	},
	/*
	 * Keyed `riskai`, NOT `rai`. `programChrome` is called with
	 * `canonicalProgramSlug`, which folds the live marketing address
	 * `/registration/rai` onto the `riskai` programme — a `rai` key would never
	 * be reached. The canvas class stays `canvas-rai` because that is what
	 * `layout.css` declares; the two names differing is intentional, so do not
	 * "fix" one to match the other.
	 *
	 * `raij` (the Japanese exam) is deliberately absent — it has no frame in the
	 * redesign, so it keeps the GARP chrome until one exists.
	 */
	riskai: {
		wordmark: raiWordmark,
		label: "RAI",
		seal: raiSeal,
		bannerArt: raiBanner,
		canvas: "canvas-rai",
		barWash: "bg-linear-to-b from-rai-orange/12 to-transparent",
		titleSizeClass: "app:text-banner",
	},
}

/**
 * Guest chrome for a programme type, or `undefined` when the programme has no
 * designed chrome yet.
 *
 * `undefined` is load-bearing rather than a gap: it is what keeps `PublicShell`
 * on today's GARP chrome — white toolbar, GARP wordmark, no banner, default
 * canvas — for the guest 404, `/registration/affiliate`, `raij`, and any
 * programme with no frame in the redesign. A neutral fallback record would
 * instead paint every one of those pages half-redesigned.
 *
 * Programme types can carry a year suffix (`FRR25`), so an exact miss retries
 * against the base code before giving up, matching `programBrandSurface`.
 */
export function programChrome(
	programType: string | null | undefined,
): ProgramChrome | undefined {
	if (!programType?.trim()) return undefined

	const slug = programTypeSlug(programType)
	const exact = PROGRAM_CHROME[slug]
	if (exact) return exact

	return PROGRAM_CHROME[slug.replace(/\d+$/, "")]
}
