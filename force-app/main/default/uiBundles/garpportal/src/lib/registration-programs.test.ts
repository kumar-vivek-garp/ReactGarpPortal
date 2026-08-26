import { describe, expect, it } from "vitest"

import { EXAM_PROGRAMS } from "@/config/registration"
import {
	canonicalProgramSlug,
	resolveExamProgram,
} from "@/lib/registration-programs"

describe("canonicalProgramSlug", () => {
	it("resolves the legacy rai alias to the key the module accepts", () => {
		// `load('rai')` throws `Unsupported registration type` — the alias is
		// what keeps the legacy public URL from dead-ending on a load error.
		expect(canonicalProgramSlug("rai")).toBe("riskai")
	})

	it("leaves a canonical slug alone", () => {
		expect(canonicalProgramSlug("riskai")).toBe("riskai")
		expect(canonicalProgramSlug("scr")).toBe("scr")
	})

	it("normalises case and surrounding whitespace", () => {
		expect(canonicalProgramSlug(" RAI ")).toBe("riskai")
		expect(canonicalProgramSlug("SCR")).toBe("scr")
	})

	it("passes an unknown slug through rather than guessing", () => {
		expect(canonicalProgramSlug("micro")).toBe("micro")
	})
})

describe("resolveExamProgram", () => {
	it("resolves every built programme", () => {
		for (const key of ["frm", "scr", "riskai", "raij", "frr25", "ffr", "frr"]) {
			expect(resolveExamProgram(key)?.registrationType).toBe(key)
		}
	})

	it("keeps the catalogue's own label for the FRR courses", () => {
		// GARP_Portal_Program__mdt calls frr25 "FRR Series" and frr "FRR" — two
		// different programmes, and the listing links to both by those names.
		expect(resolveExamProgram("frr25")?.abbrevName).toBe("FRR Series")
		expect(resolveExamProgram("frr")?.abbrevName).toBe("FRR Course")
	})

	it("resolves the alias to the same entry as the canonical slug", () => {
		expect(resolveExamProgram("rai")).toBe(EXAM_PROGRAMS.riskai)
	})

	it("returns null for a programme whose form is not built", () => {
		// Not an error: the dispatcher gives these a placeholder page.
		for (const key of ["mem", "micro", "erp"]) {
			expect(resolveExamProgram(key)).toBeNull()
		}
	})

	it("returns null for nonsense", () => {
		expect(resolveExamProgram("")).toBeNull()
		expect(resolveExamProgram("not-a-programme")).toBeNull()
	})

	it("carries a heading, byline and policy URL for every entry", () => {
		for (const program of Object.values(EXAM_PROGRAMS)) {
			expect(program.heading.highlight).toBeTruthy()
			expect(program.abbrevName).toBeTruthy()
			expect(program.publicByLine).toBeTruthy()
			expect(program.examPolicyUrl).toMatch(/^https:\/\/www\.garp\.org\//)
		}
	})
})
