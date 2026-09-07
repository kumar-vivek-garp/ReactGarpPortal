import type {
	ExamAdmin,
	ExamSetupFee,
	ExamSetupIdInfo,
	ExamSetupIdInput,
	ExamSetupIdSaveResult,
	ExamSetupProgramType,
	ExamSetupSelectionInput,
	ExamSetupView,
	ExamSite,
} from "@/api/exam-setup"
import {
	EXAM_SETUP_ID_TYPES,
	EXAM_SETUP_MESSAGES,
} from "@/config/exam-setup"
import type { MegaMenuHeading } from "@/config/navigation/types"
import { toUsDateString } from "@/lib/osta-presentation"
import { resolveExamProgram } from "@/lib/registration-programs"

/**
 * Everything the exam-setup wizard decides, as pure functions.
 *
 * The components render what these return and settle nothing themselves — same
 * split as `program-detail-presentation` and `alert-bar-presentation`.
 */

/* ===================== programme type ===================== */

const EXAM_SETUP_PROGRAM_TYPES: readonly ExamSetupProgramType[] = [
	"frm",
	"erp",
	"scr",
	"raij",
	"rai",
	"riskai",
]

/** The route slug, if Apex would accept it. `null` means show the unsupported state. */
export function examSetupProgramTypeFromSlug(
	slug: string | null | undefined,
): ExamSetupProgramType | null {
	const cleaned = slug?.trim().toLowerCase()
	if (!cleaned) return null
	return (EXAM_SETUP_PROGRAM_TYPES as readonly string[]).includes(cleaned)
		? (cleaned as ExamSetupProgramType)
		: null
}

/**
 * Whether the government-ID block applies.
 *
 * Keyed off the programme, not off `idInfo.isIDRequired`. Apex populates that
 * flag from the same fact (`RPT_Exam_Program__c` containing FRM) but enforces
 * nothing with it, and the reference implementation branches on the slug — so
 * the two would only ever disagree by accident.
 */
export function isFrmProgram(programType: string): boolean {
	return programType.toLowerCase() === "frm"
}

/* ===================== identity ===================== */

const ID_TYPE_VALUES = EXAM_SETUP_ID_TYPES.map((option) => option.value)

/**
 * Apex reads `Driver's License` out of the Contact as `Driver License` and
 * writes it back with the apostrophe. Our radio values are the lowercase wire
 * strings, so an unnormalised read value matches no option and the control
 * renders with nothing selected — which reads to the member as "we lost your
 * ID type", and then saves whatever they pick over a document they never
 * changed.
 *
 * Matched on the stem rather than the exact string, mirroring Apex's own
 * `idType.toLowerCase().contains('driver')`, so every spelling lands.
 */
export function normalizeIdType(raw: string | null | undefined): string {
	const value = raw?.trim().toLowerCase()
	if (!value) return ""
	if (value.includes("driver")) return "driver license"
	const match = ID_TYPE_VALUES.find((option) => option === value)
	return match ?? value
}

/* ===================== form values ===================== */

/** What the ID step's `useForm` holds. Dates are ISO here; converted on submit. */
export type ExamSetupIdFormValues = {
	idName: string
	idType: string
	idNumber: string
	idNumberConfirm: string
	idExpireDate: string
	mobilePhoneLocation: string
	mobilePhoneNumber: string
	ostaIDLocation: string
	ostaConsent: boolean
	ostaFullNameInChinese: string
	ostaDateOfBirth: string
	ostaGender: string
	ostaPhoneNumber: string
	ostaCurrentWorkingStatus: string
	ostaCompany: string
	ostaCurrentSchoolStatus: string
	ostaSchool: string
	ostaDegreeProgramName: string
}

/**
 * The ID step's starting values.
 *
 * Dates pass through untouched — the read is already ISO `yyyy-MM-dd`, which is
 * what `<input type="date">` binds to.
 *
 * `idNumberConfirm` is seeded from the same stored value as `idNumber` so an
 * untouched ID does not read as a mismatch.
 *
 * The consent tick always starts clear: a tick recorded against a disclosure
 * the candidate did not read this time is worthless.
 */
export function idDefaultsFrom(
	info: ExamSetupIdInfo | null | undefined,
): ExamSetupIdFormValues {
	return {
		idName: info?.idName ?? "",
		idType: normalizeIdType(info?.idType),
		idNumber: info?.idNumber ?? "",
		idNumberConfirm: info?.idNumber ?? "",
		idExpireDate: info?.idExpireDate ?? "",
		mobilePhoneLocation: info?.mobilePhoneLocation ?? "",
		mobilePhoneNumber: info?.mobilePhoneNumber ?? "",
		ostaIDLocation: info?.ostaIDLocation ?? "",
		ostaConsent: false,
		ostaFullNameInChinese: info?.ostaFullNameInChinese ?? "",
		ostaDateOfBirth: info?.ostaDateOfBirth ?? "",
		ostaGender: info?.ostaGender ?? "",
		ostaPhoneNumber: info?.ostaPhoneNumber ?? "",
		ostaCurrentWorkingStatus: info?.ostaCurrentWorkingStatus ?? "",
		ostaCompany: info?.ostaCompany ?? "",
		ostaCurrentSchoolStatus: info?.ostaCurrentSchoolStatus ?? "",
		ostaSchool: info?.ostaSchool ?? "",
		ostaDegreeProgramName: info?.ostaDegreeProgramName ?? "",
	}
}

/* ===================== validation ===================== */

export type ExamSetupIdErrors = Partial<
	Record<keyof ExamSetupIdFormValues, string>
>

/**
 * The ID step's rules.
 *
 * Everything here is client-side by necessity: Apex writes each field only when
 * it is non-null and **rejects nothing**, so `isIDRequired` is a hint and this
 * function is the only thing standing between a blank answer and a Contact
 * record that will not get the candidate into an exam hall.
 *
 * The mobile pair shares one message, reported against `mobilePhoneLocation`
 * because the two controls sit in one labelled group and a message under each
 * would say the same thing twice.
 */
export function validateIdStep(
	values: ExamSetupIdFormValues,
	context: { isFrm: boolean; isOSTA: boolean },
): ExamSetupIdErrors {
	const errors: ExamSetupIdErrors = {}

	if (!values.idName.trim()) errors.idName = EXAM_SETUP_MESSAGES.idName
	if (!values.mobilePhoneLocation || !values.mobilePhoneNumber.trim()) {
		errors.mobilePhoneLocation = EXAM_SETUP_MESSAGES.mobile
	}

	if (!context.isFrm) return errors

	if (!values.idType) errors.idType = EXAM_SETUP_MESSAGES.idType
	if (!values.idNumber.trim()) errors.idNumber = EXAM_SETUP_MESSAGES.idNumber
	if (values.idNumber !== values.idNumberConfirm) {
		errors.idNumberConfirm = EXAM_SETUP_MESSAGES.idNumberConfirm
	}
	if (!values.idExpireDate) {
		errors.idExpireDate = EXAM_SETUP_MESSAGES.idExpireDate
	}

	if (!context.isOSTA) return errors

	if (!values.ostaIDLocation) {
		errors.ostaIDLocation = EXAM_SETUP_MESSAGES.ostaIDLocation
	}
	if (!values.ostaConsent) {
		errors.ostaConsent = EXAM_SETUP_MESSAGES.ostaConsent
	}
	if (!values.ostaFullNameInChinese.trim()) {
		errors.ostaFullNameInChinese = EXAM_SETUP_MESSAGES.ostaFullNameInChinese
	}
	if (!values.ostaDateOfBirth) {
		errors.ostaDateOfBirth = EXAM_SETUP_MESSAGES.ostaDateOfBirth
	}
	if (!values.ostaGender) errors.ostaGender = EXAM_SETUP_MESSAGES.ostaGender
	if (!values.ostaPhoneNumber.trim()) {
		errors.ostaPhoneNumber = EXAM_SETUP_MESSAGES.ostaPhoneNumber
	}

	return errors
}

/**
 * The selection step's rule, as one banner message or `null`.
 *
 * Only the administration is checked. The site is not: it is hidden entirely
 * until an administration with open sites is chosen, so there is nothing the
 * member could be asked to fix.
 */
export function validateSelectionStep(
	selection: ExamSetupSelection,
	context: { hasPart1: boolean; twoPart: boolean },
): string | null {
	if (context.hasPart1 && !selection.a1) {
		return EXAM_SETUP_MESSAGES.selectAdmin
	}
	if (context.twoPart && !selection.a2) {
		return EXAM_SETUP_MESSAGES.selectAdminPart2
	}
	return null
}

/* ===================== payload ===================== */

/** Empty means "not supplied" — Apex skips a null, but would write a `""`. */
function orNull(value: string): string | null {
	const trimmed = value.trim()
	return trimmed ? trimmed : null
}

/**
 * Form values to the write shape.
 *
 * **Which keys travel depends on the programme, not on what was typed.** The
 * name and mobile always go; the government-ID trio only for FRM; the OSTA
 * block only for an FRM candidate whose centre demands it. Sending an OSTA
 * field for a member who has no China sitting would write data the exam centre
 * never asked for.
 *
 * **Dates convert here and only here.** The read hands back ISO `yyyy-MM-dd`
 * (already what the date input binds to, so nothing converts on the way in);
 * the write wants `MM/dd/yyyy`.
 */
export function toIdInput(
	values: ExamSetupIdFormValues,
	context: { isFrm: boolean; isOSTA: boolean },
): ExamSetupIdInput {
	return {
		idName: values.idName,
		mobilePhoneLocation: values.mobilePhoneLocation,
		mobilePhoneNumber: values.mobilePhoneNumber,
		...(context.isFrm
			? {
					idType: values.idType,
					idNumber: values.idNumber,
					idExpireDate: toUsDateString(values.idExpireDate),
				}
			: {}),
		...(context.isFrm && context.isOSTA
			? {
					ostaIDLocation: values.ostaIDLocation,
					ostaGender: values.ostaGender,
					ostaFullNameInChinese: values.ostaFullNameInChinese,
					ostaDateOfBirth: toUsDateString(values.ostaDateOfBirth),
					ostaPhoneNumber: values.ostaPhoneNumber,
					ostaCurrentWorkingStatus: orNull(values.ostaCurrentWorkingStatus),
					ostaCompany: orNull(values.ostaCompany),
					ostaCurrentSchoolStatus: orNull(values.ostaCurrentSchoolStatus),
					ostaSchool: orNull(values.ostaSchool),
					ostaDegreeProgramName: orNull(values.ostaDegreeProgramName),
				}
			: {}),
	}
}

/* ===================== selection ===================== */

/** The selects' own shape — plain strings, so a Radix `value` is never undefined. */
export type ExamSetupSelection = {
	a1: string
	s1: string
	a2: string
	s2: string
}

export const EMPTY_SELECTION: ExamSetupSelection = {
	a1: "",
	s1: "",
	a2: "",
	s2: "",
}

/** The administration the member sits in today, per `isSelected`. */
export function currentAdmin(
	admins: ExamAdmin[] | null | undefined,
): ExamAdmin | null {
	return admins?.find((admin) => admin.isSelected) ?? null
}

/** The site the member sits at today, within one administration. */
export function currentSite(
	admin: ExamAdmin | null | undefined,
): ExamSite | null {
	return admin?.examSites?.find((site) => site.isSelected) ?? null
}

export function sitesFor(
	admins: ExamAdmin[] | null | undefined,
	adminId: string,
): ExamSite[] {
	if (!adminId) return []
	return admins?.find((admin) => admin.id === adminId)?.examSites ?? []
}

/** What the selects start on: wherever the member sits today. */
export function selectionDefaults(
	view: ExamSetupView | null | undefined,
): ExamSetupSelection {
	const admin1 = currentAdmin(view?.examPart1SelectionInfo)
	const admin2 = currentAdmin(view?.examPart2SelectionInfo)
	return {
		a1: admin1?.id ?? "",
		s1: currentSite(admin1)?.id ?? "",
		a2: admin2?.id ?? "",
		s2: currentSite(admin2)?.id ?? "",
	}
}

/** Blank means "no choice for this part", which Apex reads as `null`. */
export function toSelectionInput(
	selection: ExamSetupSelection,
): ExamSetupSelectionInput {
	return {
		selectedAdminPart1: selection.a1 || null,
		selectedSitePart1: selection.s1 || null,
		selectedAdminPart2: selection.a2 || null,
		selectedSitePart2: selection.s2 || null,
	}
}

/** True when this programme offers a part at all. */
export function hasPart(admins: ExamAdmin[] | null | undefined): boolean {
	return (admins?.length ?? 0) > 0
}

/* ===================== summary ===================== */

/** One part of the sitting, as chosen right now and as it stands on record. */
export type SittingPartSummary = {
	label: string
	admin: { chosen: string | null; current: string | null; changed: boolean }
	site: { chosen: string | null; current: string | null; changed: boolean }
}

function nameOf(
	admins: ExamAdmin[] | null | undefined,
	adminId: string,
): string | null {
	if (!adminId) return null
	return admins?.find((admin) => admin.id === adminId)?.name ?? null
}

function siteNameOf(
	admins: ExamAdmin[] | null | undefined,
	adminId: string,
	siteId: string,
): string | null {
	if (!siteId) return null
	return sitesFor(admins, adminId).find((site) => site.id === siteId)?.name ?? null
}

function partSummary(
	label: string,
	admins: ExamAdmin[] | null | undefined,
	adminId: string,
	siteId: string,
): SittingPartSummary {
	const current = currentAdmin(admins)
	const currentSiteName = currentSite(current)?.name ?? null
	const chosenAdmin = nameOf(admins, adminId)
	const chosenSite = siteNameOf(admins, adminId, siteId)
	return {
		label,
		admin: {
			chosen: chosenAdmin,
			current: current?.name ?? null,
			changed: current?.id != null && adminId !== "" && adminId !== current.id,
		},
		site: {
			chosen: chosenSite,
			current: currentSiteName,
			changed:
				currentSite(current)?.id != null && siteId !== "" && siteId !== currentSite(current)?.id,
		},
	}
}

/**
 * What the rail and the bar show: each offered part, the choice as it stands
 * now, and whether that is a change from the sitting on record. A part the
 * programme does not offer is simply absent.
 */
export function sittingSummary(
	view: ExamSetupView | null | undefined,
	selection: ExamSetupSelection,
): SittingPartSummary[] {
	const parts: SittingPartSummary[] = []
	const twoPart = hasPart(view?.examPart2SelectionInfo)
	if (hasPart(view?.examPart1SelectionInfo)) {
		parts.push(
			partSummary(
				twoPart ? "Part I" : "Your exam",
				view?.examPart1SelectionInfo,
				selection.a1,
				selection.s1,
			),
		)
	}
	if (twoPart) {
		parts.push(
			partSummary("Part II", view?.examPart2SelectionInfo, selection.a2, selection.s2),
		)
	}
	return parts
}

/**
 * The sitting in one line for the sticky bar — `May 2026 · London`, or per
 * part for FRM. `null` while nothing is chosen, so the bar shows an em-dash
 * rather than an empty string that collapses its height.
 */
export function sittingLine(parts: SittingPartSummary[]): string | null {
	const lines = parts
		.filter((part) => part.admin.chosen)
		.map((part) => {
			const where = part.site.chosen ? ` · ${part.site.chosen}` : ""
			const prefix = parts.length > 1 ? `${part.label} ` : ""
			return `${prefix}${part.admin.chosen}${where}`
		})
	return lines.length ? lines.join(" / ") : null
}

/** True when anything differs from the sitting on record. */
export function hasSelectionChanges(parts: SittingPartSummary[]): boolean {
	return parts.some((part) => part.admin.changed || part.site.changed)
}

/* ===================== heading ===================== */

/**
 * The page title, in the registration form's shape — the certification in
 * full with the acronym tinted through `MegaMenuHeadingText`, so it matches
 * the nav exactly. Reuses the registration heading with its suffix swapped;
 * a programme with no registration form yet (ERP) gets a plain fallback in
 * the same shape rather than a bare slug.
 */
export function examSetupHeading(slug: string): MegaMenuHeading {
	const program = resolveExamProgram(slug)
	if (program) {
		return { ...program.heading, suffix: ") Exam Setup" }
	}
	return {
		prefix: "",
		highlight: slug.trim().toUpperCase() || "Exam",
		highlightToken: "garp-saffron",
		suffix: " Exam Setup",
	}
}

/* ===================== fees ===================== */

/** Refunds count against the total, so a net credit shows as one. */
export function examSetupFeesTotal(
	fees: ExamSetupFee[] | null | undefined,
): number {
	return (fees ?? []).reduce((sum, fee) => {
		const amount = fee.amount ?? 0
		return sum + (fee.type === "refund" ? -amount : amount)
	}, 0)
}

/* ===================== outcomes ===================== */

export type ExamSetupOutcome = "pay-fees" | "scheduling" | "complete"

/**
 * Where a save lands.
 *
 * An unrecognised `nextScreen` resolves to `complete` rather than throwing —
 * Apex is free to add a fourth, and a member who has already been written to
 * should see a confirmation, not an error.
 */
export function outcomeFrom(
	result: ExamSetupIdSaveResult | null | undefined,
): ExamSetupOutcome {
	const next = result?.nextScreen?.trim()
	if (next === "Pay Fees") return "pay-fees"
	if (next === "Check Authorization") return "scheduling"
	return "complete"
}

/* ===================== view state ===================== */

export type ExamSetupViewState =
	| "ready"
	| "unsupported"
	| "pendingReschedule"
	| "noAdmins"
	| "unavailable"

/**
 * Which of the page's five states to render, from the Apex status code.
 *
 * 502 is the one that must not fall through to a generic error: it means an
 * unpaid reschedule order already exists, and re-offering the form would let
 * the member raise a second one against the same sitting.
 */
export function examSetupViewStateFromStatus(
	status: number | null | undefined,
): ExamSetupViewState {
	if (status === 200) return "ready"
	if (status === 501) return "unsupported"
	if (status === 502) return "pendingReschedule"
	return "unavailable"
}

/** `ready` only when at least one part actually has an administration to offer. */
export function examSetupViewState(
	view: ExamSetupView | null | undefined,
): ExamSetupViewState {
	if (!view) return "unavailable"
	const state = examSetupViewStateFromStatus(view.statusCode)
	if (state !== "ready") return state
	return hasPart(view.examPart1SelectionInfo) ||
		hasPart(view.examPart2SelectionInfo)
		? "ready"
		: "noAdmins"
}
