import { describe, expect, it } from "vitest"

import { stripProgramFormalName } from "./program-formal-name"

describe("stripProgramFormalName", () => {
	it("is empty for nothing", () => {
		expect(stripProgramFormalName(null)).toBe("")
		expect(stripProgramFormalName(undefined)).toBe("")
		expect(stripProgramFormalName("")).toBe("")
	})

	it("turns a superscripted &reg; into unicode ®", () => {
		expect(
			stripProgramFormalName("Financial Risk Manager (FRM<sup>&reg;</sup>)"),
		).toBe("Financial Risk Manager (FRM®)")
	})

	it("turns a superscripted &trade; into unicode ™", () => {
		expect(stripProgramFormalName("RAI<sup>&trade;</sup> Program")).toBe(
			"RAI™ Program",
		)
	})

	it("accepts the numeric entity forms", () => {
		expect(stripProgramFormalName("FRM<sup>&#174;</sup>")).toBe("FRM®")
		expect(stripProgramFormalName("RAI<sup>&#8482;</sup>")).toBe("RAI™")
	})

	it("converts bare entities without a sup wrapper", () => {
		expect(stripProgramFormalName("FRM&reg; and RAI&trade;")).toBe("FRM® and RAI™")
	})

	it("is case-insensitive about the markup", () => {
		expect(stripProgramFormalName("FRM<SUP>&REG;</SUP>")).toBe("FRM®")
	})

	it("tolerates whitespace inside the sup", () => {
		expect(stripProgramFormalName("FRM<sup> &reg; </sup>")).toBe("FRM®")
	})

	it("strips any other tag but keeps its text", () => {
		expect(stripProgramFormalName("<em>Sustainability</em> <b>and</b> Climate")).toBe(
			"Sustainability and Climate",
		)
	})

	it("decodes the basic text entities", () => {
		expect(stripProgramFormalName("Risk&nbsp;&amp;&nbsp;AI")).toBe("Risk & AI")
		expect(stripProgramFormalName("&lt;draft&gt;")).toBe("<draft>")
	})

	it("collapses runs of whitespace and trims the ends", () => {
		expect(stripProgramFormalName("  Financial   Risk\n Manager  ")).toBe(
			"Financial Risk Manager",
		)
	})
})
