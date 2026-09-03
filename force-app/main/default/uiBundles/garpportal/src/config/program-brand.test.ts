import { describe, expect, it } from "vitest"

import { programBrandSurface } from "@/config/program-brand"

/** The unmapped fallback — derived, not hardcoded, so palette edits don't break this file. */
const neutral = programBrandSurface("no-such-program")

describe("programBrandSurface", () => {
	it("returns the neutral surface for blank or missing input", () => {
		expect(programBrandSurface(null)).toEqual(neutral)
		expect(programBrandSurface(undefined)).toEqual(neutral)
		expect(programBrandSurface("   ")).toEqual(neutral)
	})

	it("resolves a mapped program to a branded, non-neutral surface", () => {
		const frm = programBrandSurface("frm")

		expect(frm).not.toEqual(neutral)
		expect(frm.surface).toBeTruthy()
		expect(frm.chip).toBeTruthy()
	})

	it("is case-insensitive via the slug", () => {
		expect(programBrandSurface("FRM")).toEqual(programBrandSurface("frm"))
	})

	it("retries a year-suffixed type against its base code", () => {
		expect(programBrandSurface("FRR25")).toEqual(programBrandSurface("frr"))
		expect(programBrandSurface("scr26")).toEqual(programBrandSurface("scr"))
	})

	it("prefers an exact match over the year-stripped base", () => {
		// riskai maps directly; stripping digits would not change it, but the
		// exact table hit must win before any suffix handling runs.
		expect(programBrandSurface("riskai")).toEqual(programBrandSurface("rai"))
	})

	it("falls back to neutral when even the base code is unmapped", () => {
		expect(programBrandSurface("xyz25")).toEqual(neutral)
	})
})
