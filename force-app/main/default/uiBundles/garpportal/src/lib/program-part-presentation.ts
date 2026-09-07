import type { ExamPartInfo, ProgramDetail } from "@/api/programs"
import { formatDateTime, formatLongDate } from "@/lib/account-format"
import { resolveExperienceHref } from "@/lib/program-card-links"

/**
 * Pure rules for ONE exam-part card. Ported from GarpAppv1's
 * `PortalProgramDetail` (ExamPartCard / PartBody / examFormatLabel), which is
 * the behaviour reference — the copy is the legacy's, the layout is ours.
 *
 * Page-level rules (actions, the unpaid-change alert, which parts render) live
 * in `program-detail-presentation.ts`; this file must not import from it.
 */

/** Legacy result sentences keyed by Apex `result`. */
const RESULT_COPY: Record<string, string> = {
	Pass: "Congratulations! You are almost there to getting certified!",
	Fail: "We regret to inform you, your result did not meet the requirement to pass.",
	"No-Show": "We have no record of you attending this exam.",
	"Not Graded": "Your Exam was not graded.",
	"Not Available": "Your exam result is not available.",
}

/** The caption the legacy prints under Take Exam. */
export const TAKE_EXAM_NOTE =
	"Select 'Take Exam' to check in 30 minutes prior to the appointment time, or sign in through your exam provider's website."

export type PartFactIcon =
	| "format"
	| "provider"
	| "date"
	| "site"
	| "payment"
	| "results"

export type PartFact = {
	icon: PartFactIcon
	label: string
	value: string | null
	/** Shown, muted, when `value` is empty. Omit to hide an empty fact. */
	emptyLabel?: string
	/** The value becomes an external link when set. */
	href?: string | null
}

export function resultCopy(result: string | null | undefined): string | null {
	if (!result?.trim()) return null
	return RESULT_COPY[result] ?? result
}

/** Fail, No-Show and Not Graded all leave the exam to be sat again. */
export function didNotPass(result: string | null | undefined): boolean {
	return result === "Fail" || result === "No-Show" || result === "Not Graded"
}

function longDate(iso: string | null | undefined): string | null {
	return formatLongDate(iso?.slice(0, 10))
}

/**
 * An unpaid exam change blocks every other action on the sitting — a second
 * change cannot be requested while the first is unpaid.
 */
export function isPartBlocked(part: ExamPartInfo): boolean {
	return Boolean(part.unpaidDeferralOrderId?.trim())
}

/**
 * The warning under an unpaid change — the legacy's, with the scheduling
 * deadline as the pay-by date when the service supplies one.
 */
export function unpaidChangeMessage(part: ExamPartInfo): string {
	const deadline = longDate(part.schedulingDeadline)
	return deadline
		? `You must pay before ${deadline} to complete this request.`
		: "Pay the pending order to complete this request."
}

/**
 * The Edit link changes the sitting, so it only shows while a deferral is
 * actually open AND there is no unpaid change already outstanding.
 */
export function canEditPart(part: ExamPartInfo): boolean {
	return part.isDeferralOpen === true && !isPartBlocked(part)
}

/**
 * Derived rather than printed: an FRM sitting is always in person, and
 * everything else is in person unless the format says Remote. Printing
 * `examFormat` raw showed "Remote" or nothing at all.
 */
export function examFormatLabel(
	part: ExamPartInfo,
	detail: ProgramDetail,
): string | null {
	const isFrm = detail.programType?.trim().toUpperCase() === "FRM"
	if (isFrm) return "In-Person"
	if (!part.schedulingExamDateTimeSelected) return null
	return part.examFormat === "Remote" ? "Online Proctored" : "In-Person"
}

/**
 * The administration a card is headed by: the one deferred TO while deferred,
 * nothing once the registration has expired without a sitting.
 */
export function partAdministration(part: ExamPartInfo): string | null {
	if (part.examPartState === "SchedulingClosedNeverScheduled") return null
	if (part.examPartState === "Deferred") {
		return (
			part.deferredAdminName?.trim() ||
			part.examAttemptAdminName?.trim() ||
			null
		)
	}
	return part.examAttemptAdminName?.trim() || null
}

function examWhen(part: ExamPartInfo): string | null {
	const when = formatDateTime(part.schedulingExamDateTimeSelected)
	const zone = part.schedulingExamDateTimeZoneSelected?.trim()
	return when && zone ? `${when} (${zone})` : when
}

/**
 * The fact rows for a state. Five states replace the standard Format /
 * Provider / Date / Site block wholesale rather than adding to it, because
 * none of the scheduling rows apply to them yet, or any more.
 */
export function partFacts(
	part: ExamPartInfo,
	detail: ProgramDetail,
): PartFact[] {
	switch (part.examPartState) {
		case "Unpaid":
			return [
				{ icon: "payment", label: "Payment status", value: "Unpaid" },
				{
					icon: "date",
					label: "Complete payment by",
					value: longDate(part.unpaidOrderPayByDate),
					emptyLabel: "Date to be announced",
				},
			]
		case "AwaitingSchedulingToOpen":
			return [
				{
					icon: "date",
					label: "Scheduling opens",
					value: longDate(part.schedulingAwaitingToOpenOpenDate),
					emptyLabel: "Date to be announced",
				},
			]
		case "Deferred":
			return [
				{
					icon: "date",
					label: "Scheduling opens",
					value: longDate(part.deferredExamSetupOpenDate),
					emptyLabel: "Date to be announced",
				},
			]
		case "SchedulingClosedNeverScheduled":
			return []
		case "SchedulingClosedAwaitingResults":
			return [
				{ icon: "results", label: "Exam results", value: "Coming soon" },
				{
					icon: "date",
					label: "Results released",
					value: longDate(part.resultsAvailableDateTime),
					emptyLabel: "Date to be announced",
				},
			]
		case "SchedulingClosedResultsAvailable":
			return [
				{
					icon: "results",
					label: "Exam results",
					value: part.result?.trim() || null,
					emptyLabel: "Not available",
				},
			]
		default:
			return [
				{
					icon: "format",
					label: "Exam format",
					value: examFormatLabel(part, detail),
					emptyLabel: "Not available",
				},
				{
					icon: "provider",
					label: "Exam provider",
					value: part.schedulingExamProviderName?.trim() || null,
					emptyLabel: "Not assigned",
					// The provider name becomes the way in once a sitting is booked.
					href:
						part.schedulingIsComplete === true
							? resolveExperienceHref(part.schedulingExamAccessURL)
							: null,
				},
				{
					icon: "date",
					label: "Exam date",
					value: examWhen(part),
					emptyLabel: "Not scheduled",
				},
				{
					icon: "site",
					label: "Exam site",
					value: part.schedulingExamLocationSelected?.trim() || null,
					emptyLabel: "Not selected",
				},
			]
	}
}

/** The reopen line the legacy prints wherever registering again is the answer. */
function registerAgainLine(detail: ProgramDetail): string {
	const reopens = longDate(detail.nextRegistrationOpenDate)
	return reopens
		? `Register again on ${reopens}.`
		: "Register again when exam results are released."
}

/**
 * The sentences under the card title, in order. The legacy's copy string for
 * string, including the two result-state lines that tell the member what to
 * register for next and when the window opens.
 */
export function partMessages(
	part: ExamPartInfo,
	detail: ProgramDetail,
): string[] {
	switch (part.examPartState) {
		case "Unpaid":
			return ["Your registration is not yet paid."]
		case "Deferred": {
			const to = part.deferredAdminName?.trim()
			return [`Your exam has been deferred${to ? ` to ${to}` : ""}.`]
		}
		case "AwaitingSchedulingToOpen":
			return [
				`Exam setup opens ${longDate(part.schedulingAwaitingToOpenOpenDate) ?? "soon"}.`,
			]
		case "SchedulingOpen": {
			if (part.schedulingIsComplete) return ["Your exam is scheduled."]
			const by = longDate(part.schedulingDeadline)
			return [by ? `Schedule before ${by}.` : "Exam setup is open."]
		}
		case "SchedulingClosedNeverScheduled":
			return ["Your registration has expired.", registerAgainLine(detail)]
		case "SchedulingClosedAwaitingToTakeExam":
			return ["You are scheduled to sit this exam."]
		case "SchedulingClosedAwaitingResults":
			return [
				part.resultsAvailableStatement?.trim() ||
					"Your exam results are being prepared.",
			]
		case "SchedulingClosedResultsAvailable": {
			const lines: string[] = []
			const copy = resultCopy(part.result)
			if (copy) lines.push(copy)
			const canAddPartII = detail.currentRegistrationCanAddPartII === true
			const type = detail.programType?.trim().toUpperCase() || "the"
			if (part.result === "Pass" && canAddPartII) {
				lines.push(`Take the ${type} Exam Part II next.`)
			}
			// The reopen date whenever the member has something left to register
			// for and the window is shut.
			const reopens = longDate(detail.nextRegistrationOpenDate)
			if (
				detail.currentRegistrationIsOpen !== true &&
				reopens &&
				(didNotPass(part.result) || canAddPartII)
			) {
				lines.push(`Registration will open on ${reopens}.`)
			}
			return lines
		}
		default:
			return []
	}
}

/**
 * The badge belongs to a SITTING that was passed: a part is only badged once
 * its result is available AND it is a pass. Links the badge page where the
 * service gives one, the image otherwise.
 */
export function partBadgeUrl(part: ExamPartInfo): string | null {
	if (part.examPartState !== "SchedulingClosedResultsAvailable") return null
	if (part.result !== "Pass") return null
	if (!part.badgeURL?.trim()) return null
	return resolveExperienceHref(part.badgePageURL ?? part.badgeURL)
}
