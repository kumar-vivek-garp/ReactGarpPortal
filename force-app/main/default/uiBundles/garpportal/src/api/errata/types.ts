import type { MemberPortalEnvelope } from "@/api/account/types"

/**
 * Types mirroring `GARP_Portal_ErrataService`.
 *
 * A member who finds a mistake in a book reports it here. The form's options
 * are the dependent picklist on `Errata__c` — `Section__c` controls
 * `Book_Practice_Exam__c` — filtered server-side to the programme being
 * reported against.
 */

/**
 * `GET errataForm?programType=` — the cascade's options.
 *
 * `errataPicklistOption` maps each **study material** (the map key) to the
 * **books** inside it. It can legitimately come back empty for a programme
 * whose picklist labels do not match the server's search term; that is a valid
 * 200, not a failure.
 */
export type ErrataFormView = {
	statusMessage: string | null
	statusCode: number
	errataPicklistOption: Record<string, string[]> | null
}

/**
 * `POST submitErrata` body.
 *
 * **`studyMaterial` and `book` are inverted relative to their names.** The map
 * KEY goes in `studyMaterial`; the DEPENDENT value goes in `book`. Apex then
 * writes them the other way round again — `Book_Practice_Exam__c` takes
 * `studyMaterial`, `Section__c` takes `book` — and says so in its own comment:
 * "the two halves the other way round from their names. Reproduced — reports
 * are triaged on these."
 *
 * Build this with `toErrataSubmission()`; never hand-assemble it.
 */
export type ErrataSubmission = {
	programType: string
	/** The map key from `errataPicklistOption`. */
	studyMaterial: string
	/** The dependent value inside that key. */
	book: string
	/** Free text — a page number, or a question number for a practice exam. */
	pageNumber: string
	errorDescription: string
	/** The only optional field; Apex 501s on any of the others. */
	correction: string | null
}

export type ErrataSubmitResult = {
	statusMessage: string | null
	statusCode: number
	/** Needed by `attachErrataFile`; null when the insert failed. */
	errataId: string | null
}

export type ErrataAttachResult = {
	statusMessage: string | null
	statusCode: number
	fileId: string | null
}

export type { MemberPortalEnvelope }
