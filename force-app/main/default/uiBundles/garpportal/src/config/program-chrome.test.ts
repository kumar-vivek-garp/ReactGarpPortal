import { describe, expect, it } from "vitest"

import { programChrome } from "./program-chrome"

describe("programChrome", () => {
	it.each([
		["frm", "FRM", "canvas-frm"],
		["scr", "SCR", "canvas-scr"],
		["riskai", "RAI", "canvas-rai"],
	])("gives %s its full guest chrome", (slug, label, canvas) => {
		const chrome = programChrome(slug)

		expect(chrome?.label).toBe(label)
		// Literal, never composed: Tailwind's scanner cannot see `canvas-${slug}`,
		// so a composed name would be dropped from the build and the page would
		// silently keep the default background.
		expect(chrome?.canvas).toBe(canvas)
		// Bundled assets, not remote URLs — the Figma links expire in ~7 days.
		expect(chrome?.wordmark).toBeTruthy()
		expect(chrome?.seal).toBeTruthy()
		expect(chrome?.bannerArt).toBeTruthy()
	})

	/*
	 * RAI is keyed `riskai` because lookups arrive via `canonicalProgramSlug`,
	 * while its canvas class stays `canvas-rai`. The mismatch is deliberate;
	 * pinning it here so neither name gets "corrected" to match the other.
	 */
	it("keys RAI by its canonical slug while keeping the rai canvas class", () => {
		expect(programChrome("riskai")?.canvas).toBe("canvas-rai")
		// `rai` is the marketing address, not a key — callers canonicalise first.
		expect(programChrome("rai")).toBeUndefined()
	})

	/*
	 * The bar wash has to agree with the acronym tint in the title beside it.
	 * SCR is the one that catches a wrong reuse: `programBrandSurface("scr")`
	 * gives `success-green`, which would put a green wash under SCR's gold
	 * artwork and saffron acronym.
	 */
	it.each([
		["frm", "garp-cyan"],
		["scr", "garp-saffron"],
		["riskai", "rai-orange"],
	])("washes %s's member bar in its own brand hue", (slug, hue) => {
		expect(programChrome(slug)?.barWash).toBe(
			`bg-linear-to-b from-${hue}/12 to-transparent`,
		)
	})

	it("never washes the bar in a hue the title does not use", () => {
		expect(programChrome("scr")?.barWash).not.toContain("success-green")
	})

	/*
	 * The guest navbar follows the portal's toolbar tokens, so it is LIGHT in
	 * light mode — a knockout lockup alone would vanish on it. GARP publishes
	 * this lockup as raster only (no SVG in Figma or on garp.org), so the two
	 * published variants are swapped by theme rather than recoloured.
	 */
	it.each(["frm", "scr"])("pairs %s's knockout with a dark-ink variant", (slug) => {
		const chrome = programChrome(slug)
		expect(chrome?.wordmark).toBeTruthy()
		expect(chrome?.wordmarkInk).toBeTruthy()
		expect(chrome?.wordmarkInk).not.toBe(chrome?.wordmark)
	})

	/*
	 * RAI has no published dark-ink SHORT lockup — `GARP RAI Logo.png` is the
	 * stacked GARP-over-"RAI | Risk and AI" version, a different shape. The
	 * navbar darkens its knockout with a filter instead, which works because
	 * that knockout is 99% monochrome. Drop a real asset in and this flips.
	 */
	it("leaves RAI without an ink variant, so the navbar filters instead", () => {
		expect(programChrome("riskai")?.wordmark).toBeTruthy()
		expect(programChrome("riskai")?.wordmarkInk).toBeUndefined()
	})

	/* Only RAI's frame asks for 40px; the other two stay on `--text-title`. */
	it("overrides the title size for RAI alone", () => {
		expect(programChrome("riskai")?.titleSizeClass).toBe("app:text-banner")
		expect(programChrome("frm")?.titleSizeClass).toBeUndefined()
		expect(programChrome("scr")?.titleSizeClass).toBeUndefined()
	})

	it("is case- and whitespace-insensitive", () => {
		expect(programChrome("FRM")).toBe(programChrome("frm"))
		expect(programChrome("  scr  ")).toBe(programChrome("scr"))
	})

	/*
	 * `undefined` is the contract, not a gap: it is what holds the guest 404,
	 * `/registration/affiliate` and every programme with no frame in the
	 * redesign on today's GARP chrome, instead of painting them half-redesigned.
	 * `raij` is the live example — deferred by decision, no Figma frame.
	 */
	it("returns undefined for a programme with no designed chrome", () => {
		expect(programChrome("raij")).toBeUndefined()
		expect(programChrome("micro")).toBeUndefined()
		expect(programChrome("")).toBeUndefined()
		expect(programChrome(null)).toBeUndefined()
		expect(programChrome(undefined)).toBeUndefined()
	})

	it("falls back to the base code for a year-suffixed type", () => {
		expect(programChrome("frm25")).toBe(programChrome("frm"))
	})
})
