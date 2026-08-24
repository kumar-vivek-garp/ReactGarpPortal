import { describe, expect, it } from "vitest"

import type { ErrataFormView } from "@/api/errata"
import {
	EMPTY_ERRATA_FORM,
	errataBookOptions,
	errataMaterialOptions,
	errataPageLabel,
	errataSheetUrl,
	isBookInMaterial,
	isPracticeExamMaterial,
	toErrataSubmission,
	validateErrataUpload,
} from "./errata-presentation"

function view(
	options: Record<string, string[]> | null,
): ErrataFormView {
	return {
		statusMessage: "Success",
		statusCode: 200,
		errataPicklistOption: options,
	}
}

const OPTIONS = view({
	"FRM Part I Books": ["Foundations of Risk Management", "Quantitative Analysis"],
	"FRM Practice Exams": ["2025 Part I Practice Exam"],
})

describe("toErrataSubmission", () => {
	/**
	 * The trap this function exists for.
	 *
	 * The form's "study material" is the picklist MAP KEY and its "book" is the
	 * DEPENDENT value — the opposite of what the Apex fields are named — and
	 * Apex swaps them again into `Book_Practice_Exam__c` / `Section__c`. Reports
	 * are triaged on those two, so an inversion misfiles every report with a
	 * cheerful 200 and nothing to notice.
	 */
	it("sends the map key as studyMaterial and the dependent as book", () => {
		const body = toErrataSubmission("frm", {
			...EMPTY_ERRATA_FORM,
			studyMaterial: "FRM Part I Books",
			book: "Quantitative Analysis",
			pageNumber: "142",
			errorDescription: "The variance formula is wrong.",
		})
		expect(body.studyMaterial).toBe("FRM Part I Books")
		expect(body.book).toBe("Quantitative Analysis")
	})

	it("names every field and adds nothing else", () => {
		const body = toErrataSubmission("frm", {
			studyMaterial: "m",
			book: "b",
			pageNumber: "1",
			errorDescription: "d",
			correction: "c",
		})
		expect(Object.keys(body).sort()).toEqual([
			"book",
			"correction",
			"errorDescription",
			"pageNumber",
			"programType",
			"studyMaterial",
		])
	})

	/** Apex matches on the upper-cased form (and spells Risk AI as RISKAI). */
	it("upper-cases the programme type", () => {
		expect(toErrataSubmission("riskai", EMPTY_ERRATA_FORM).programType).toBe(
			"RISKAI",
		)
	})

	/** The only optional field; everything else is a client-side required. */
	it("sends a blank correction as null, not an empty string", () => {
		expect(
			toErrataSubmission("frm", { ...EMPTY_ERRATA_FORM, correction: "   " })
				.correction,
		).toBeNull()
	})

	it("trims every value", () => {
		const body = toErrataSubmission("frm", {
			...EMPTY_ERRATA_FORM,
			studyMaterial: "  m  ",
			pageNumber: " 12 ",
		})
		expect(body.studyMaterial).toBe("m")
		expect(body.pageNumber).toBe("12")
	})
})

describe("the cascade", () => {
	it("lists study materials alphabetically — the map carries no order", () => {
		expect(
			errataMaterialOptions(
				view({ Zebra: ["z"], Alpha: ["a"], Middle: ["m"] }),
			),
		).toEqual(["Alpha", "Middle", "Zebra"])
	})

	it("returns the books inside one material, and none for an unknown one", () => {
		expect(errataBookOptions(OPTIONS, "FRM Practice Exams")).toEqual([
			"2025 Part I Practice Exam",
		])
		expect(errataBookOptions(OPTIONS, "Nothing")).toEqual([])
	})

	/**
	 * Both halves are free-form strings by the time Apex sees them, so a book
	 * left over from the previous material would be accepted and the report
	 * filed against a section that material does not contain.
	 */
	it("detects a book that no longer belongs to the chosen material", () => {
		expect(
			isBookInMaterial(OPTIONS, "FRM Practice Exams", "Quantitative Analysis"),
		).toBe(false)
		expect(
			isBookInMaterial(OPTIONS, "FRM Part I Books", "Quantitative Analysis"),
		).toBe(true)
	})

	it("treats an empty book as fine — nothing is stale yet", () => {
		expect(isBookInMaterial(OPTIONS, "FRM Part I Books", "")).toBe(true)
	})

	/** A valid 200 for a programme whose labels match no search term. */
	it("survives an empty or absent option map", () => {
		expect(errataMaterialOptions(view({}))).toEqual([])
		expect(errataMaterialOptions(view(null))).toEqual([])
		expect(errataMaterialOptions(null)).toEqual([])
	})
})

describe("the page-number label", () => {
	/** A practice exam has no pages, so the legacy asks for a question number. */
	it("asks for a question number on a practice exam", () => {
		expect(isPracticeExamMaterial("FRM Practice Exams")).toBe(true)
		expect(errataPageLabel("FRM Practice Exams")).toContain("question number")
	})

	it("asks for a page number everywhere else", () => {
		expect(isPracticeExamMaterial("FRM Part I Books")).toBe(false)
		expect(errataPageLabel("FRM Part I Books")).toContain("page")
	})
})

describe("errataSheetUrl", () => {
	it("returns the published sheet for the programmes that have one", () => {
		expect(errataSheetUrl("frm")).toContain("FRM%20Errata")
		expect(errataSheetUrl("SCR")).toContain("SCR%20Errata")
		expect(errataSheetUrl("riskai")).toContain("RAI%20Errata")
		// The marketing site spells Risk AI as RAI; links arrive with both.
		expect(errataSheetUrl("rai")).toBe(errataSheetUrl("riskai"))
	})

	/** GARP publishes no Japanese sheet — null is what stops a dead download. */
	it("returns null for a programme with no published sheet", () => {
		expect(errataSheetUrl("raij")).toBeNull()
		expect(errataSheetUrl("icbrr")).toBeNull()
		expect(errataSheetUrl("")).toBeNull()
	})
})

describe("validateErrataUpload", () => {
	const file = (over: Partial<{ name: string; size: number; type: string }> = {}) => ({
		name: "screenshot.png",
		size: 1024,
		type: "image/png",
		...over,
	})

	it("accepts an allowed file", () => {
		expect(validateErrataUpload(file())).toBeNull()
	})

	/** 2 MB is the legacy's ceiling; Apex enforces nothing at all. */
	it("refuses a file over 2 MB", () => {
		expect(validateErrataUpload(file({ size: 2 * 1024 * 1024 + 1 }))).toContain(
			"2 MB",
		)
	})

	it("refuses a type GARP does not accept", () => {
		expect(
			validateErrataUpload(file({ name: "clip.mp4", type: "video/mp4" })),
		).not.toBeNull()
	})

	/** Browsers report an empty `type` for several accepted formats. */
	it("accepts an allowed extension when the browser reports no MIME type", () => {
		expect(validateErrataUpload(file({ name: "notes.doc", type: "" }))).toBeNull()
	})
})
