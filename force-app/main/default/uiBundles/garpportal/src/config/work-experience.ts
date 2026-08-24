import { BriefcaseBusiness } from "lucide-react"

/**
 * Static config for Work Experience (the "Certification CV" flow).
 *
 * Copy is ours, not the legacy's — its own strings carry several typos
 * ("Manage Work Expierence", "We have recieved you information") and bury the
 * requirement in a paragraph. The rules they describe are unchanged.
 */

export const WORK_EXPERIENCE_TITLE = "Work Experience"

/** Programmes that carry a CV requirement. Apex accepts only these two. */
export const CV_PROGRAM_SLUGS = ["frm", "erp"] as const

/** The three progressive sections, in order. */
export const CV_SECTIONS = [
	{
		key: "experience",
		title: "Your experience",
		description:
			"Add each role you want counted. GARP reviews the last ten years.",
	},
	{
		key: "address",
		title: "Where to post your certificate",
		description: "We post your certificate here once your CV is approved.",
	},
	{
		key: "review",
		title: "Review & submit",
		description: "Check everything over, then send it to GARP for review.",
	},
] as const

export type CvSectionKey = (typeof CV_SECTIONS)[number]["key"]

export const CV_ZERO_STATE = {
	icon: BriefcaseBusiness,
	title: "No experience added yet",
	message:
		"Add the roles that show your risk management experience. You need 24 months in total.",
} as const

/** Shown when the programme has no CV requirement for this member. */
export const CV_UNAVAILABLE_STATE = {
	icon: BriefcaseBusiness,
	title: "No work experience requirement",
	message:
		"This programme has no work experience to submit. It appears once you have passed the exam.",
} as const

/**
 * Client-side upload ceiling.
 *
 * Apex enforces nothing at all. The platform caps an Attachment body at 5 MB
 * and base64 inflates a file by about a third, so anything much over 4 MB
 * fails as an opaque 500 with no usable message. Refusing it here gives the
 * member something they can act on.
 */
export const CV_MAX_UPLOAD_BYTES = 4 * 1024 * 1024
export const CV_MAX_UPLOAD_LABEL = "4 MB"

export const CV_ALLOWED_UPLOAD_TYPES = [
	"application/pdf",
	"application/msword",
	"application/vnd.openxmlformats-officedocument.wordprocessingml.document",
	"text/plain",
	"image/jpeg",
	"image/png",
] as const

/** Extensions are checked too — `file.type` is empty for some .doc files. */
export const CV_ALLOWED_UPLOAD_EXTENSIONS = [
	".pdf", ".doc", ".docx", ".txt", ".jpg", ".jpeg", ".png",
] as const

export const CV_UPLOAD_ACCEPT = CV_ALLOWED_UPLOAD_EXTENSIONS.join(",")

/**
 * GARP's minimum for a work-experience description.
 *
 * Enforced client-side only, as the legacy did — **Apex checks nothing**, so a
 * shorter description reaching the server by any other route is accepted. The
 * form pairs this with a live character count; a hard floor with no feedback
 * is what made the legacy's version frustrating.
 */
export const CV_DESCRIPTION_MIN_LENGTH = 400
export const CV_DESCRIPTION_MAX_LENGTH = 131_000

export const CV_MONTHS = [
	{ value: "1", label: "January" },
	{ value: "2", label: "February" },
	{ value: "3", label: "March" },
	{ value: "4", label: "April" },
	{ value: "5", label: "May" },
	{ value: "6", label: "June" },
	{ value: "7", label: "July" },
	{ value: "8", label: "August" },
	{ value: "9", label: "September" },
	{ value: "10", label: "October" },
	{ value: "11", label: "November" },
	{ value: "12", label: "December" },
] as const

/**
 * Newest first, back to 1970 — the range the legacy offered.
 *
 * Takes the current year so the list is deterministic in tests rather than
 * depending on when they run.
 */
export function cvYearOptions(currentYear: number): string[] {
	const years: string[] = []
	for (let year = currentYear; year >= 1970; year--) years.push(String(year))
	return years
}
