import type {
	ExamAdmin,
	ExamSetupIdInfo,
	ExamSetupIdInput,
	ExamSetupIdSaveResult,
	ExamSetupProgramType,
	ExamSetupSelectionInput,
	ExamSetupView,
	ExamSite,
} from "@/api/exam-setup"
import {
	EXAM_SETUP_FEES,
	EXAM_SETUP_ID_TYPES,
	EXAM_SETUP_PASSPORT_PATTERN,
} from "@/config/exam-setup"
import { toUsDateString } from "@/lib/osta-presentation"

/**
 * Everything the exam-setup page decides, as pure functions.
 *
 * The panel renders what these return and settles nothing itself — same split
 * as `program-detail-presentation` and `alert-bar-presentation`.
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

/** FRM is the only two-part programme; everything else sits once. */
export function isTwoPartProgram(programType: ExamSetupProgramType): boolean {
	return programType === "frm"
}

/* ===================== identity ===================== */

/**
 * Apex reads `Driver's License` out of the Contact as `Driver License` and
 * writes it back with the apostrophe. Our select options carry the apostrophe,
 * so an unnormalised read value matches no option and the control renders
 * blank — which reads to the member as "we lost your ID type".
 *
 * Matched on the stem rather than the exact string so either spelling lands.
 */
export function normalizeIdType(raw: string | null | undefined): string {
	const value = raw?.trim()
	if (!value) return ""
	// Apex matches this one on the stem — `idType.toLowerCase().contains('driver')`
	// — so "Driver License", "Drivers License" and "Driver's License" all mean
	// the same document. Mirroring that here keeps read and write agreeing.
	if (value.toLowerCase().includes("driver")) return "Driver's License"
	const match = EXAM_SETUP_ID_TYPES.find(
		(option) => option.toLowerCase() === value.toLowerCase(),
	)
	return match ?? value
}

/**
 * True when the number is acceptable for the chosen document.
 *
 * Only a passport has a shape to check. Anything else is required but
 * unconstrained, which is what the legacy does.
 */
export function isValidIdNumber(
	idType: string | null | undefined,
	idNumber: string | null | undefined,
	/** True when one is already stored, so blank means "leave it as it is". */
	alreadyOnFile = false,
): boolean {
	const value = idNumber?.trim() ?? ""
	if (!value) return alreadyOnFile
	if (normalizeIdType(idType) !== "Passport") return true
	return EXAM_SETUP_PASSPORT_PATTERN.test(value)
}

/** Empty means "the member left this alone" — omit it so Apex does not blank it. */
function omitEmpty(value: string | undefined): string | undefined {
	const trimmed = value?.trim()
	return trimmed ? trimmed : undefined
}

/**
 * Form values to the write shape.
 *
 * Two things this function exists to get right.
 *
 * **Dates.** The READ returns ISO `yyyy-MM-dd` (already what
 * `<input type="date">` binds to, so the form needs no conversion coming in)
 * while the WRITE wants `MM/dd/yyyy`. Only this direction converts. Reaching
 * for `toDateInputValue` on the read would blank both date fields, because it
 * expects `MM/dd/yyyy` as ITS input.
 *
 * **Empties are omitted, never sent.** Apex guards every field with
 * `if (i.field != null)`, and an empty string is not null — so posting `""`
 * for something the member never touched overwrites their Contact with blank.
 * That is exactly the data-loss bug we reported to the backend team about
 * `cvAddress`; it is not one to reproduce here. A field left empty simply does
 * not travel, and the stored value survives.
 */
export function toIdInput(values: {
	idName?: string
	idNumber?: string
	idType?: string
	/** ISO `yyyy-MM-dd` from the date input. */
	idExpireDate?: string
	mobilePhoneLocation?: string
	mobilePhoneNumber?: string
	ostaIDLocation?: string
	ostaGender?: string
	ostaFullNameInChinese?: string
	/** ISO `yyyy-MM-dd` from the date input. */
	ostaDateOfBirth?: string
	ostaPhoneNumber?: string
	ostaCurrentWorkingStatus?: string
	ostaCompany?: string
	ostaCurrentSchoolStatus?: string
	ostaSchool?: string
	ostaDegreeProgramName?: string
}): ExamSetupIdInput {
	const idNumber = omitEmpty(values.idNumber)
	return {
		idName: omitEmpty(values.idName),
		// Apex applies idType and the expiry only inside its `idNumber != null`
		// branch, so they travel with the number or not at all.
		idNumber,
		idType: idNumber ? normalizeIdType(values.idType) : undefined,
		idExpireDate:
			idNumber && values.idExpireDate
				? toUsDateString(values.idExpireDate)
				: undefined,
		mobilePhoneLocation: omitEmpty(values.mobilePhoneLocation),
		mobilePhoneNumber: omitEmpty(values.mobilePhoneNumber),
		ostaIDLocation: omitEmpty(values.ostaIDLocation),
		ostaGender: omitEmpty(values.ostaGender),
		ostaFullNameInChinese: omitEmpty(values.ostaFullNameInChinese),
		ostaDateOfBirth: values.ostaDateOfBirth
			? toUsDateString(values.ostaDateOfBirth)
			: undefined,
		ostaPhoneNumber: omitEmpty(values.ostaPhoneNumber),
		ostaCurrentWorkingStatus: omitEmpty(values.ostaCurrentWorkingStatus),
		ostaCompany: omitEmpty(values.ostaCompany),
		ostaCurrentSchoolStatus: omitEmpty(values.ostaCurrentSchoolStatus),
		ostaSchool: omitEmpty(values.ostaSchool),
		ostaDegreeProgramName: omitEmpty(values.ostaDegreeProgramName),
	}
}

/** True when the member already has an ID number stored. */
export function hasIdOnFile(
	info: ExamSetupIdInfo | null | undefined,
): boolean {
	return Boolean(info?.idNumber?.trim())
}

/**
 * The ID step's starting values.
 *
 * Dates pass through untouched — the read is already ISO.
 *
 * `idNumber` is **deliberately never seeded**, the same choice `osta-id-form`
 * makes. The read returns only the last five characters in the clear
 * (`ID_Number__c`; the whole number lives in `OSTA_Full_ID__c`), so echoing it
 * back on the next save would write those five characters over a real ID.
 * Leaving it blank means an untouched field is omitted entirely and the stored
 * number survives.
 */
export function idDefaultsFrom(info: ExamSetupIdInfo | null | undefined) {
	return {
		idName: info?.idName ?? "",
		idNumber: "",
		idType: normalizeIdType(info?.idType),
		idExpireDate: info?.idExpireDate ?? "",
		mobilePhoneLocation: info?.mobilePhoneLocation ?? "",
		mobilePhoneNumber: info?.mobilePhoneNumber ?? "",
		ostaIDLocation: info?.ostaIDLocation ?? "",
		ostaGender: info?.ostaGender ?? "",
		ostaFullNameInChinese: info?.ostaFullNameInChinese ?? "",
		ostaDateOfBirth: info?.ostaDateOfBirth ?? "",
		ostaPhoneNumber: info?.ostaPhoneNumber ?? "",
		ostaCurrentWorkingStatus: info?.ostaCurrentWorkingStatus ?? "",
		ostaCompany: info?.ostaCompany ?? "",
		ostaCurrentSchoolStatus: info?.ostaCurrentSchoolStatus ?? "",
		ostaSchool: info?.ostaSchool ?? "",
		ostaDegreeProgramName: info?.ostaDegreeProgramName ?? "",
	}
}

/* ===================== selection ===================== */

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
	adminId: string | null,
): ExamSite[] {
	if (!adminId) return []
	return admins?.find((admin) => admin.id === adminId)?.examSites ?? []
}

/** What the selects start on: wherever the member sits today. */
export function selectionDefaults(
	view: ExamSetupView | null | undefined,
): ExamSetupSelectionInput {
	const admin1 = currentAdmin(view?.examPart1SelectionInfo)
	const admin2 = currentAdmin(view?.examPart2SelectionInfo)
	return {
		selectedAdminPart1: admin1?.id ?? null,
		selectedSitePart1: currentSite(admin1)?.id ?? null,
		selectedAdminPart2: admin2?.id ?? null,
		selectedSitePart2: currentSite(admin2)?.id ?? null,
	}
}

/** True when this programme offers a part at all. */
export function hasPart(admins: ExamAdmin[] | null | undefined): boolean {
	return (admins?.length ?? 0) > 0
}

/* ===================== the fee gate ===================== */

export type ExamSetupFeeForecast = {
	amount: number
	reason: string
}

/**
 * Whether the chosen sitting costs money, decided without a server call.
 *
 * Only the ADMINISTRATION change is decidable here, and it is the expensive,
 * common one — 250 to move an FRM sitting, 150 for the single-part programmes.
 * Apex holds both as literals, so there is nothing to look up.
 *
 * **The OSTA fees deliberately are not forecast.** Apex decides those from
 * `Exam_Site__r.Site__r.Is_OSTA_Information_Required__c`, and the site list on
 * the wire carries only `{ id, name, isSelected }` — no flag, and a name is not
 * a country. Guessing from the name would gate the wrong members, so a
 * site-only change goes through and Apex answers `Pay Fees` if it turns out to
 * carry one. `examSetupPayFeesFallback` handles that second line.
 */
export function predictFee(
	programType: ExamSetupProgramType,
	view: ExamSetupView | null | undefined,
	selection: ExamSetupSelectionInput,
): ExamSetupFeeForecast | null {
	const admin1 = currentAdmin(view?.examPart1SelectionInfo)
	const admin2 = currentAdmin(view?.examPart2SelectionInfo)

	const moved1 =
		admin1?.id != null &&
		selection.selectedAdminPart1 != null &&
		admin1.id !== selection.selectedAdminPart1
	const moved2 =
		admin2?.id != null &&
		selection.selectedAdminPart2 != null &&
		admin2.id !== selection.selectedAdminPart2

	if (!moved1 && !moved2) return null

	const amount =
		programType === "frm"
			? EXAM_SETUP_FEES.frmDeferral
			: EXAM_SETUP_FEES.singlePartDeferral

	const parts = [moved1 ? "Part I" : null, moved2 ? "Part II" : null].filter(
		Boolean,
	)

	return {
		amount,
		reason:
			parts.length && isTwoPartProgram(programType)
				? `Moving ${parts.join(" and ")} to a different exam administration`
				: "Moving your exam to a different administration",
	}
}

/** True when nothing was changed — the submit button has nothing to do. */
export function hasSelectionChanges(
	view: ExamSetupView | null | undefined,
	selection: ExamSetupSelectionInput,
): boolean {
	const defaults = selectionDefaults(view)
	return (
		defaults.selectedAdminPart1 !== selection.selectedAdminPart1 ||
		defaults.selectedSitePart1 !== selection.selectedSitePart1 ||
		defaults.selectedAdminPart2 !== selection.selectedAdminPart2 ||
		defaults.selectedSitePart2 !== selection.selectedSitePart2
	)
}

/** Both parts landing on one administration earns the travel warning. */
export function isSameAdministration(
	selection: ExamSetupSelectionInput,
): boolean {
	return (
		selection.selectedAdminPart1 != null &&
		selection.selectedAdminPart1 === selection.selectedAdminPart2
	)
}

/* ===================== outcomes ===================== */

export type ExamSetupOutcome =
	| "complete"
	| "scheduling"
	| "pay-fees"
	| "unknown"

/**
 * Where a save lands.
 *
 * An unrecognised `nextScreen` resolves to `complete` rather than throwing —
 * Apex is free to add a fourth and a member who has already been written to
 * should see a confirmation, not an error. `unknown` is reserved for a missing
 * value, which means the save did not report at all.
 */
export function outcomeFrom(
	result: ExamSetupIdSaveResult | null | undefined,
): ExamSetupOutcome {
	const next = result?.nextScreen?.trim()
	if (!next) return "unknown"
	if (next === "Pay Fees" || result?.paymentRequired === true) return "pay-fees"
	if (next === "Check Authorization" || result?.schedulingRequired === true) {
		return "scheduling"
	}
	return "complete"
}

/**
 * True when a save came back wanting payment despite the gate.
 *
 * Reachable only through an OSTA site change, which cannot be forecast (see
 * `predictFee`). It matters because by this point Apex HAS raised an
 * `Exam_Registration_Modification__c`, so the copy must say the change is
 * pending rather than repeat the pre-save "nothing has happened yet" wording.
 */
export function examSetupPayFeesFallback(
	result: ExamSetupIdSaveResult | null | undefined,
): { modificationId: string | null } | null {
	if (outcomeFrom(result) !== "pay-fees") return null
	return { modificationId: result?.examModificationId ?? null }
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

/**
 * Whether the administration select is editable for a part.
 *
 * `allowAdminMod*` false does NOT hide the part — the site under it may still
 * be changeable, which is a free change and the whole point of the page for a
 * member who only needs to move across town.
 */
export function canChangeAdmin(
	view: ExamSetupView | null | undefined,
	part: 1 | 2,
): boolean {
	return (part === 1 ? view?.allowAdminModPart1 : view?.allowAdminModPart2) === true
}
