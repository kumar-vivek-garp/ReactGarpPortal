import { BookX } from "lucide-react"

/**
 * Static config for Curriculum Errata.
 *
 * Copy is ours. The legacy's own text ships "error or discrepency" and buries
 * the instructions in a wall of prose; the rules it describes are unchanged.
 */

export const ERRATA_TITLE = "Curriculum errata"

/**
 * Programmes that offer errata, as route slugs.
 *
 * Apex entitles a member holding an activated contract on FRM, SCR, RiskAI,
 * RAIJ or ICBRR. Anything else — FRR, FRR25, micro courses — has no errata
 * route, matching the legacy's own gate on the programme rail.
 */
export const ERRATA_PROGRAM_SLUGS = [
	"frm",
	"scr",
	"riskai",
	"rai",
	"raij",
	"icbrr",
] as const

/**
 * The published errata sheets.
 *
 * Hard-coded because **no endpoint returns them** — legacy and GarpAppv1 both
 * carry the same literal `garp.org` links. Keyed by route slug.
 *
 * RAIJ is deliberately absent: GARP publishes no Japanese sheet, so that
 * programme gets real copy rather than a link to a 404. ICBRR likewise.
 */
export const ERRATA_SHEET_URLS: Record<string, string> = {
	frm: "https://www.garp.org/hubfs/Curriculum%20Errata/FRM%20Errata%20PDF.pdf",
	scr: "https://www.garp.org/hubfs/Curriculum%20Errata/SCR%20Errata%20PDF.pdf",
	riskai: "https://www.garp.org/hubfs/Curriculum%20Errata/RAI%20Errata%20PDF.pdf",
	rai: "https://www.garp.org/hubfs/Curriculum%20Errata/RAI%20Errata%20PDF.pdf",
}

export const ERRATA_INTRO =
	"Found an error or discrepancy in the curriculum? Check the published sheet first — most known issues are already listed there — then tell us what you found."

/** What a member is asked to include, from the legacy's own instructions. */
export const ERRATA_CHECKLIST = [
	"The exam and part, and the chapter number",
	"The section title or number, and the page it appears on",
	"What is wrong, in as much detail as you can give",
	"What you think the correction should be",
] as const

export const ERRATA_NO_ACCESS = {
	icon: BookX,
	title: "Errata reporting isn't available on your account",
	message:
		"Reporting an error needs an active enrollment in a program with published curriculum. If you believe this is wrong, contact Member Services.",
} as const

export const ERRATA_NO_OPTIONS = {
	icon: BookX,
	title: "No study material listed yet",
	message:
		"There is nothing to report against for this program yet. Please check back once the curriculum is published.",
} as const

/**
 * Client-side upload limits.
 *
 * Apex validates nothing. 2 MB is the legacy's own ceiling, kept so a member
 * is not told a file is fine here and refused downstream.
 */
export const ERRATA_MAX_UPLOAD_BYTES = 2 * 1024 * 1024
export const ERRATA_MAX_UPLOAD_LABEL = "2 MB"

export const ERRATA_ALLOWED_UPLOAD_EXTENSIONS = [
	".jpg", ".jpeg", ".png", ".pdf", ".doc", ".docx", ".xls", ".xlsx", ".txt",
] as const

export const ERRATA_ALLOWED_UPLOAD_TYPES = [
	"image/jpeg",
	"image/png",
	"application/pdf",
	"application/msword",
	"application/vnd.openxmlformats-officedocument.wordprocessingml.document",
	"application/vnd.ms-excel",
	"application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
	"text/plain",
] as const

export const ERRATA_UPLOAD_ACCEPT = ERRATA_ALLOWED_UPLOAD_EXTENSIONS.join(",")
