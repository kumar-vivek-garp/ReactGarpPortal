import type { ErrataFormView, ErrataSubmission } from "@/api/errata"
import {
	ERRATA_ALLOWED_UPLOAD_EXTENSIONS,
	ERRATA_ALLOWED_UPLOAD_TYPES,
	ERRATA_MAX_UPLOAD_BYTES,
	ERRATA_MAX_UPLOAD_LABEL,
	ERRATA_SHEET_URLS,
} from "@/config/errata"
import { validateUpload } from "@/lib/upload-validation"

/** Every field the report form edits. */
export type ErrataFormValues = {
	/** The map key from `errataPicklistOption`. */
	studyMaterial: string
	/** The dependent value inside that key. */
	book: string
	pageNumber: string
	errorDescription: string
	correction: string
}

export const EMPTY_ERRATA_FORM: ErrataFormValues = {
	studyMaterial: "",
	book: "",
	pageNumber: "",
	errorDescription: "",
	correction: "",
}

/** The study materials on offer, alphabetically — the map carries no order. */
export function errataMaterialOptions(
	view: ErrataFormView | null | undefined,
): string[] {
	return Object.keys(view?.errataPicklistOption ?? {}).sort((a, b) =>
		a.localeCompare(b),
	)
}

/** The books inside one study material, or none when it is unknown. */
export function errataBookOptions(
	view: ErrataFormView | null | undefined,
	studyMaterial: string,
): string[] {
	const books = view?.errataPicklistOption?.[studyMaterial]
	return Array.isArray(books) ? books : []
}

/**
 * Whether a chosen book still belongs to the chosen material.
 *
 * Drives the cascade's clear-on-change. Leaving a stale dependent value
 * selected is how a report gets filed against a section that does not exist in
 * the material it names — and the server would accept it, because both halves
 * are free-form strings by the time they reach Apex.
 */
export function isBookInMaterial(
	view: ErrataFormView | null | undefined,
	studyMaterial: string,
	book: string,
): boolean {
	if (!book) return true
	return errataBookOptions(view, studyMaterial).includes(book)
}

/**
 * Whether the chosen material is a practice exam.
 *
 * Only changes a label: the legacy asks for a *question* number on a practice
 * exam and a *page* number everywhere else, because a practice exam has no
 * pages. GarpAppv1 dropped the distinction; it costs one conditional.
 */
export function isPracticeExamMaterial(studyMaterial: string): boolean {
	return /practice\s*exam/i.test(studyMaterial)
}

/** "What question number was the error on?" / "What page was the error on?" */
export function errataPageLabel(studyMaterial: string): string {
	return isPracticeExamMaterial(studyMaterial)
		? "What question number was the error on?"
		: "What page was the error on?"
}

/**
 * The published sheet for a programme, or null when GARP publishes none.
 *
 * No endpoint returns these — see `ERRATA_SHEET_URLS`. RAIJ and ICBRR have no
 * sheet, and null is what tells the page to say so rather than offer a dead
 * download.
 */
export function errataSheetUrl(programType: string): string | null {
	return ERRATA_SHEET_URLS[programType.trim().toLowerCase()] ?? null
}

/**
 * Builds the `submitErrata` body.
 *
 * This exists to pin the inversion. `studyMaterial` carries the map KEY and
 * `book` carries the DEPENDENT value — the opposite of what the picklist
 * fields are named — and Apex then swaps them again on the way into
 * `Book_Practice_Exam__c` and `Section__c`. Reports are triaged on those two
 * fields, so getting it wrong misfiles every report with a cheerful 200.
 *
 * Nothing is spread in; every field is named. `correction` is the only
 * optional one and goes as null rather than an empty string.
 */
export function toErrataSubmission(
	programType: string,
	values: ErrataFormValues,
): ErrataSubmission {
	const text = (value: string) => value.trim()
	return {
		programType: text(programType).toUpperCase(),
		studyMaterial: text(values.studyMaterial),
		book: text(values.book),
		pageNumber: text(values.pageNumber),
		errorDescription: text(values.errorDescription),
		correction: text(values.correction) || null,
	}
}

/** Why a chosen supporting file cannot be uploaded, or null when it is fine. */
export function validateErrataUpload(file: {
	name: string
	size: number
	type: string
}): string | null {
	return validateUpload(file, {
		maxBytes: ERRATA_MAX_UPLOAD_BYTES,
		maxLabel: ERRATA_MAX_UPLOAD_LABEL,
		allowedTypes: ERRATA_ALLOWED_UPLOAD_TYPES,
		allowedExtensions: ERRATA_ALLOWED_UPLOAD_EXTENSIONS,
	})
}
