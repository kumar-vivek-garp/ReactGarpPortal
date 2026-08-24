import {
	CV_ALLOWED_UPLOAD_EXTENSIONS,
	CV_ALLOWED_UPLOAD_TYPES,
	CV_MAX_UPLOAD_BYTES,
	CV_MAX_UPLOAD_LABEL,
} from "@/config/work-experience"
import { joinStreet } from "@/api/personal-info/address-utils"
import { validateUpload } from "@/lib/upload-validation"
import type { AddressFormFields } from "@/api/personal-info/types"
import type {
	CvAddressPayload,
	CvExperienceInput,
	CvProgramType,
	CvStatus,
	CvView,
	WorkExperience,
} from "@/api/work-experience"

/**
 * Pure derivations for the Work Experience page.
 *
 * Every number shown to the member is computed by Apex — months, validity,
 * overlaps, the submission gate. Nothing here recomputes any of it; this
 * formats what the server said and decides what the page may show.
 */

/** What the page renders, derived from `CvView.status`. */
export type CvViewState = "empty" | "editing" | "submitted" | "closed"

/**
 * `null` is the approved / terminal case, not an error — Apex only names the
 * four in-flight states, so a certified member reports nothing at all.
 */
export function cvViewState(view: CvView | null | undefined): CvViewState {
	if (!view) return "empty"
	switch (view.status) {
		case "New":
			return "empty"
		case "In Progress":
		case "Failed Review":
			return "editing"
		case "Submitted":
			return "submitted"
		default:
			return "closed"
	}
}

/** Whether the member may still add, edit or remove entries. */
export function canEditCv(view: CvView | null | undefined): boolean {
	const state = cvViewState(view)
	return state === "empty" || state === "editing"
}

/**
 * Whether Submit may be offered.
 *
 * Follows the server's own `isValidExperienceSubmission`, which is computed
 * from valid months only. Apex re-checks on submit against the raw total, so a
 * 501 is still possible and must be handled — the two numbers are computed
 * differently even though they agree today.
 */
export function canSubmitCv(view: CvView | null | undefined): boolean {
	if (!view || !canEditCv(view)) return false
	return view.isValidExperienceSubmission === true
}

export type CvProgressPresentation = {
	logged: number
	required: number
	remaining: number
	percent: number
	label: string
}

/** "18 of 24 months logged" plus the numbers behind the bar. */
export function cvProgress(view: CvView | null | undefined): CvProgressPresentation {
	const logged = Math.max(0, view?.totalTimeAllotted ?? 0)
	const required = Math.max(0, view?.timeRequired ?? 0)
	const remaining = Math.max(0, required - logged)
	const percent =
		required <= 0 ? 100 : Math.min(100, Math.round((logged / required) * 100))
	return {
		logged,
		required,
		remaining,
		percent,
		/*
		 * "80 of 24 months logged" is nonsense once the bar is cleared, and a
		 * member well past the requirement is exactly who reads this line.
		 */
		label:
			remaining === 0
				? `${formatMonths(logged)} logged`
				: `${logged} of ${required} months logged`,
	}
}

/** "3 months" / "1 month" / "0 months". */
export function formatMonths(months: number | null | undefined): string {
	const value = typeof months === "number" && Number.isFinite(months) ? months : 0
	return `${value} ${value === 1 ? "month" : "months"}`
}

/** "Jan 2020 – Nov 2025", or "Jan 2020 – Present" for a current role. */
export function formatExperiencePeriod(
	experience: WorkExperience,
	formatter: (value: string | null) => string | null = shortMonthYear,
): string {
	const start = formatter(experience.startDate) ?? "—"
	if (experience.isCurrentPosition === true) return `${start} – Present`
	const end = formatter(experience.endDate)
	return end ? `${start} – ${end}` : start
}

/**
 * `MM/dd/yyyy` (what Apex sends) to "Jan 2020".
 *
 * Parsed by hand rather than with `new Date(value)` — that reads the string as
 * UTC and can shift a first-of-month back into the previous month for anyone
 * west of Greenwich.
 */
export function shortMonthYear(value: string | null): string | null {
	const raw = value?.trim()
	if (!raw) return null
	const parts = raw.split("/")
	if (parts.length !== 3) return null
	const month = Number(parts[0])
	const year = Number(parts[2])
	if (!month || !year || month < 1 || month > 12) return null
	return `${MONTH_LABELS[month - 1]} ${year}`
}

const MONTH_LABELS = [
	"Jan", "Feb", "Mar", "Apr", "May", "Jun",
	"Jul", "Aug", "Sep", "Oct", "Nov", "Dec",
] as const

export type CvRowTone = "valid" | "warning" | "invalid" | "neutral"

export type CvRowPresentation = {
	id: string | null
	title: string
	subtitle: string
	period: string
	monthsLabel: string
	tone: CvRowTone
	/** Apex's own sentence about this row, when it has one to say. */
	note: string | null
	/** Rendered separately and in a warning tone. */
	overlapNote: string | null
	attachmentCount: number
	needsDocuments: boolean
}

/**
 * One entry row.
 *
 * The legacy hid `validationMessage` and the overlap warning inside tooltips,
 * which are invisible on touch. Both are surfaced as text here.
 *
 * A part-time role is worth zero months and is still *valid* — Apex
 * short-circuits it — so zero months alone must not read as an error.
 */
export function buildCvRowPresentation(
	experience: WorkExperience,
): CvRowPresentation {
	const note = experience.validationMessage?.trim() || null
	const overlapNote = experience.overlapWarning?.message?.trim() || null
	const invalid = experience.isValidExperience === false

	let tone: CvRowTone = "neutral"
	if (invalid) tone = "invalid"
	else if (overlapNote) tone = "warning"
	else if ((experience.timeAllotted ?? 0) > 0) tone = "valid"

	const subtitleParts = [experience.title, experience.jobType].filter(
		(part): part is string => Boolean(part?.trim()),
	)

	return {
		id: experience.id,
		title: experience.company?.trim() || "Untitled experience",
		subtitle: subtitleParts.join(" · "),
		period: formatExperiencePeriod(experience),
		monthsLabel: formatMonths(experience.timeAllotted),
		tone,
		note,
		overlapNote,
		attachmentCount: experience.attachmentCount ?? 0,
		needsDocuments:
			experience.isExperienceAttachmentRequired === true &&
			experience.hasAttachments !== true,
	}
}

/** Whether a certificate delivery address has been given. */
export function hasDeliveryAddress(view: CvView | null | undefined): boolean {
	const address = view?.address
	if (!address) return false
	if (address.isEmpty === true) return false
	return Boolean(address.street?.trim() && address.city?.trim())
}

/** "12 Example Road, London, EC1A 1BB, United Kingdom". */
export function formatAddressLine(
	address: CvView["address"] | null | undefined,
): string | null {
	if (!address) return null
	const parts = [
		address.street,
		address.city,
		address.state,
		address.postalCode,
		address.country,
	]
		.map((part) => part?.trim())
		.filter((part): part is string => Boolean(part))
	return parts.length > 0 ? parts.join(", ") : null
}

/** `frm` / `erp` from a route slug, or null for a programme with no CV. */
export function cvProgramTypeFromSlug(
	slug: string | null | undefined,
): CvProgramType | null {
	const value = slug?.trim().toLowerCase()
	if (value === "frm") return "FRM"
	if (value === "erp") return "ERP"
	return null
}

/** Every field the entry form edits. */
export type CvExperienceFormValues = {
	company: string
	title: string
	manager: string
	startDateMonth: string
	startDateYear: string
	endDateMonth: string
	endDateYear: string
	isCurrentPosition: boolean
	jobFunction: string
	riskSpecialty: string
	jobType: string
	educationalRole: string
	description: string
}

/**
 * Builds the POST body.
 *
 * This exists to be a whitelist. Apex deserializes `experience` with a TYPED
 * `JSON.deserialize`, so a single key it does not declare — `programRequirement`,
 * `timeAllotted`, `attachmentCount`, anything echoed back off a read — throws
 * and the request dies as an opaque HTTP 500 with no message. Nothing may be
 * spread into the result; every field is named.
 *
 * Dates go as month/year integers only. The string form is parsed with
 * locale-dependent `Date.parse`, and Apex picks its end-date branch by testing
 * `startDate`, so sending both modes throws.
 */
export function toExperienceInput(
	values: CvExperienceFormValues,
	experienceId?: string | null,
): CvExperienceInput {
	const numberOrNull = (value: string) => {
		const parsed = Number(value)
		return Number.isFinite(parsed) && parsed > 0 ? parsed : null
	}
	const textOrNull = (value: string) => value.trim() || null
	const current = values.isCurrentPosition === true

	return {
		...(experienceId?.trim() ? { id: experienceId.trim() } : {}),
		startDateMonth: numberOrNull(values.startDateMonth),
		startDateYear: numberOrNull(values.startDateYear),
		// Apex substitutes today for a current role, so sending a stale end date
		// persists a value the member did not mean. The legacy did exactly that.
		endDateMonth: current ? null : numberOrNull(values.endDateMonth),
		endDateYear: current ? null : numberOrNull(values.endDateYear),
		isCurrentPosition: current,
		company: textOrNull(values.company),
		title: textOrNull(values.title),
		description: textOrNull(values.description),
		manager: textOrNull(values.manager),
		jobFunction: textOrNull(values.jobFunction),
		riskSpecialty: textOrNull(values.riskSpecialty),
		jobType: textOrNull(values.jobType),
		// Only meaningful for Education/Training; cleared otherwise so a stale
		// value from a previous selection is never submitted.
		educationalRole: textOrNull(values.educationalRole),
	}
}

/** Seeds the form from a saved row. */
export function toExperienceFormValues(
	experience: WorkExperience | null | undefined,
): CvExperienceFormValues {
	const [startMonth, startYear] = splitMonthYear(experience?.startDate)
	const [endMonth, endYear] = splitMonthYear(experience?.endDate)
	return {
		company: experience?.company ?? "",
		title: experience?.title ?? "",
		manager: experience?.manager ?? "",
		startDateMonth: startMonth,
		startDateYear: startYear,
		endDateMonth: endMonth,
		endDateYear: endYear,
		isCurrentPosition: experience?.isCurrentPosition === true,
		jobFunction: experience?.jobFunction ?? "",
		riskSpecialty: experience?.riskSpecialty ?? "",
		jobType: experience?.jobType ?? "",
		educationalRole: experience?.educationalRole ?? "",
		description: experience?.description ?? "",
	}
}

/** `MM/dd/yyyy` to the month and year strings the selects bind to. */
function splitMonthYear(value: string | null | undefined): [string, string] {
	const parts = value?.trim().split("/")
	if (!parts || parts.length !== 3) return ["", ""]
	const month = Number(parts[0])
	const year = Number(parts[2])
	if (!month || !year) return ["", ""]
	return [String(month), String(year)]
}

export type CvStatusTone = "info" | "success" | "warning" | "neutral"

/** Headline copy for the current state, and the tone to show it in. */
export function cvStatusPresentation(status: CvStatus): {
	label: string
	tone: CvStatusTone
} {
	switch (status) {
		case "New":
			return { label: "Not started", tone: "info" }
		case "In Progress":
			return { label: "In progress", tone: "info" }
		case "Submitted":
			return { label: "Submitted for review", tone: "success" }
		case "Failed Review":
			return { label: "Needs changes", tone: "warning" }
		default:
			return { label: "Complete", tone: "success" }
	}
}

/** "1.4 MB" / "812 KB" / "1 byte". Sizes come back null on the upload response. */
export function formatFileSize(bytes: number | null | undefined): string | null {
	if (typeof bytes !== "number" || !Number.isFinite(bytes) || bytes < 0) {
		return null
	}
	if (bytes < 1024) return `${bytes} ${bytes === 1 ? "byte" : "bytes"}`
	if (bytes < 1024 * 1024) return `${Math.round(bytes / 1024)} KB`
	return `${(bytes / (1024 * 1024)).toFixed(1)} MB`
}

/**
 * Why a chosen CV document cannot be uploaded, or null when it is fine.
 *
 * A thin wrapper over the shared `validateUpload` — the rule is the same one
 * every Apex upload action needs and none of them enforce; only the ceiling
 * and the accepted formats differ per caller.
 */
export function validateCvUpload(file: {
	name: string
	size: number
	type: string
}): string | null {
	return validateUpload(file, {
		maxBytes: CV_MAX_UPLOAD_BYTES,
		maxLabel: CV_MAX_UPLOAD_LABEL,
		allowedTypes: CV_ALLOWED_UPLOAD_TYPES,
		allowedExtensions: CV_ALLOWED_UPLOAD_EXTENSIONS,
	})
}

/**
 * Builds the `cvAddress` body from the same nine fields My Account edits.
 *
 * Every field is named, and none is omitted on the grounds of being empty:
 * Apex assigns all seven Contact columns unconditionally, so a missing key is
 * written as null. `company` and `phone` in particular are absent from
 * `GET cv`, which is why the form is seeded from the personal-info payload —
 * seeding from the CV view alone would blank both on the member's Contact.
 */
export function toCvAddressPayload(
	values: AddressFormFields,
	osta?: CvOstaFormValues | null,
): CvAddressPayload {
	const text = (value: string) => value.trim() || null
	const payload: CvAddressPayload = {
		mailingAddress: {
			company: text(values.company),
			street: joinStreet(values.address1, values.address2, values.address3) || null,
			city: text(values.city),
			state: text(values.state),
			postalCode: text(values.postalCode),
			country: text(values.country),
			phone: text(values.phone),
		},
	}

	/*
	 * Sent only for an OSTA candidate. Apex writes the six OSTA columns inside
	 * `if (input.ostaAddress != null)`, so passing an empty block would erase a
	 * China-sitting candidate's address rather than leave it alone.
	 *
	 * No `postalCode` and no `country`: `saveAddress` reads neither for the
	 * OSTA block, and `GET cv` hard-codes the country to "China" on the way
	 * out. Sending either would be ignored at best and misleading at worst.
	 */
	if (osta) {
		payload.ostaAddress = {
			street: text(osta.street),
			city: text(osta.city),
			state: text(osta.province),
			postalCode: null,
			country: null,
			district: text(osta.district),
			town: text(osta.town),
			phone: text(osta.phone),
		}
		payload.ostaRecipient = text(osta.recipient)
	}

	return payload
}

/** The Chinese-character delivery block, for OSTA candidates only. */
export type CvOstaFormValues = {
	recipient: string
	province: string
	city: string
	district: string
	town: string
	street: string
	phone: string
}

/** Seeds the OSTA block from `GET cv`. */
export function toCvOstaFormValues(
	view: CvView | null | undefined,
): CvOstaFormValues {
	return {
		recipient: view?.ostaRecipient ?? "",
		province: view?.ostaAddress?.state ?? "",
		city: view?.ostaAddress?.city ?? "",
		district: view?.ostaDistrict ?? "",
		town: view?.ostaTown ?? "",
		street: view?.ostaAddress?.street ?? "",
		phone: view?.ostaPhone ?? "",
	}
}

/**
 * Whether a value carries Chinese characters.
 *
 * The address is passed to the Chinese postal service, so it has to be in
 * Chinese — but the rule is "contains Han characters", not "contains nothing
 * else": building numbers, unit numbers and the occasional Latin abbreviation
 * are all normal in a real address. The legacy's validator rejected anything
 * with a non-Chinese character in it, which fails on a street number.
 */
export function hasChineseCharacters(value: string): boolean {
	return /[\u3400-\u4dbf\u4e00-\u9fff]/.test(value)
}

/**
 * Why the CV cannot be sent yet, or null when it can.
 *
 * The address half of this gate is ours alone — `cvSubmit` never looks at the
 * address, so without it a member can raise a review with nowhere to post the
 * certificate. The legacy's review screen had the same hole and submitted
 * regardless of `isValidExperienceSubmission` too.
 */
export function cvSubmitBlocker(view: CvView | null | undefined): string | null {
	if (!view) return "Your work experience is still loading."
	if (!canEditCv(view)) return "This CV has already been sent to GARP."
	if (!canSubmitCv(view)) {
		const { remaining } = cvProgress(view)
		return view.submissionMessage?.trim() ||
			(remaining > 0
				? `You need ${formatMonths(remaining)} more of qualifying experience.`
				: "Your experience does not yet meet the requirement.")
	}
	if (!hasDeliveryAddress(view)) {
		return "Add the address your certificate should be posted to."
	}
	return null
}
