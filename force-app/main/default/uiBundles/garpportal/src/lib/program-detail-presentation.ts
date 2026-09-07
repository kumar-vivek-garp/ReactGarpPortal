import type {
	ExamPartInfo,
	ProgramDetail,
} from "@/api/programs"
import { formatDateTime, formatLongDate } from "@/lib/account-format"
import {
	certificateCopyCheckoutHref,
	programExamSetupHref,
	programOrderHref,
	programRegistrationPath,
	programResultsPath,
	programTypeSlug,
	programWorkExperiencePath,
	resolveExperienceHref,
} from "@/lib/program-card-links"
import { stripProgramFormalName } from "@/lib/program-formal-name"
import {
	didNotPass,
	isPartBlocked,
	partBadgeUrl,
	resultCopy,
	TAKE_EXAM_NOTE,
	unpaidChangeMessage,
} from "@/lib/program-part-presentation"
import type { StatusTone } from "@/lib/status-tone"

/**
 * Page-level rules for `/programs/$programType`, ported from GarpAppv1's
 * `PortalProgramDetail` — which flags gate which actions, and what the hero
 * says. Per-part card rules live in `program-part-presentation.ts`.
 */

export { resultCopy }

export type ProgramActionKind =
	| "schedule"
	| "setup"
	| "takeExam"
	| "viewOrder"
	| "viewPendingOrder"
	| "viewExamResults"
	| "workExperience"
	| "registerAgain"
	| "registerPartII"
	| "deferExam"
	| "digitalBadge"
	| "downloadCertificate"
	| "requestCertificate"
	| "directory"
	/* Course pages only — a course has an e-learning platform and an eBook
	   where an exam programme has sittings. */
	| "eLearning"
	| "eBook"

export type ProgramAction = {
	kind: ProgramActionKind
	label: string
	url: string
	isExternal: boolean
	newWindow?: boolean
	/** Primary actions are emphasized in the hero / next-step panel. */
	primary?: boolean
}

export type JourneyMilestoneStatus = "complete" | "current" | "upcoming" | "blocked"

export type JourneyMilestone = {
	/**
	 * Identity only — used as the list key, never branched on. Widened for
	 * courses, whose stops ("coursework") have no equivalent on the two-part
	 * exam journey; keeping the union closed would have meant labelling a
	 * course's coursework step "scheduling" to satisfy the type.
	 */
	id:
		| "registration"
		| "scheduling"
		| "exam"
		| "results"
		| "certification"
		| "coursework"
	label: string
	status: JourneyMilestoneStatus
	detail?: string | null
}

export type ProgramDetailPresentation = {
	displayName: string
	examLabel: string
	description: string | null
	administration: string | null
	statusLabel: string
	statusTone: StatusTone
	statusSummary: string
	nextStepTitle: string
	nextStepBody: string
	/**
	 * The Next-step card's tint. Usually follows `statusTone`; "danger" turns
	 * the card into a warning (an unpaid exam change blocking the sitting).
	 */
	nextStepTone: StatusTone
	/** Muted lines under the next-step body — the Take Exam caption, CV notes. */
	notes: string[]
	primaryAction: ProgramAction | null
	secondaryActions: ProgramAction[]
	milestones: JourneyMilestone[]
	isTwoPart: boolean
}

export function displayProgramName(
	detail: ProgramDetail | null | undefined,
): string {
	const info = detail?.programInformation
	return (
		stripProgramFormalName(info?.formalName) ||
		info?.informalName?.trim() ||
		info?.abbrevName?.trim() ||
		detail?.programType?.trim() ||
		"Program"
	)
}

function isTwoPartProgram(detail: ProgramDetail): boolean {
	const type = detail.programType?.trim().toUpperCase()
	return type === "FRM" || type === "ERP"
}

function programTypeLabel(detail: ProgramDetail): string {
	return detail.programType?.trim().toUpperCase() || "the"
}

/**
 * Which part cards the page renders, in order.
 *
 * A stale pass (older than 90 days) is old news and the legacy hides it. ERP
 * has no Part I card — its Part I is not sat through this portal. A one-part
 * programme never has a Part II.
 */
export function visibleExamParts(
	detail: ProgramDetail,
): Array<{ part: ExamPartInfo; partIndex: 1 | 2 }> {
	const parts: Array<{ part: ExamPartInfo; partIndex: 1 | 2 }> = []
	const isErp = programTypeSlug(detail.programType ?? "") === "erp"
	const p1 = detail.examPart1Info
	if (p1 && p1.isResultStale !== true && !isErp) {
		parts.push({ part: p1, partIndex: 1 })
	}
	const p2 = detail.examPart2Info
	if (p2 && p2.isResultStale !== true && isTwoPartProgram(detail)) {
		parts.push({ part: p2, partIndex: 2 })
	}
	return parts
}

/** The first visible part carrying an unpaid exam change, if any. */
export function pendingExamChange(
	detail: ProgramDetail,
): { part: ExamPartInfo; orderId: string } | null {
	for (const { part } of visibleExamParts(detail)) {
		const orderId = part.unpaidDeferralOrderId?.trim()
		if (orderId) return { part, orderId }
	}
	return null
}

/**
 * The part the hero summarises. A blocked sitting takes precedence — the
 * unpaid change is the one thing the member must act on — otherwise the first
 * visible part.
 */
export function activeExamPart(
	detail: ProgramDetail,
): ExamPartInfo | null {
	return (
		pendingExamChange(detail)?.part ??
		visibleExamParts(detail)[0]?.part ??
		null
	)
}

/**
 * Identity only matters while a sitting is actually in play: while it can
 * still be changed, or once the member is booked and waiting to sit it.
 * The legacy's `showIDInfo`.
 */
export function showIdInfo(detail: ProgramDetail): boolean {
	const awaiting = (part: ExamPartInfo | null) =>
		part?.examPartState === "SchedulingClosedAwaitingToTakeExam"
	return (
		detail.isAnyPartDeferalOpen === true ||
		detail.isAnyPartSchedulingOpen === true ||
		awaiting(detail.examPart1Info) ||
		awaiting(detail.examPart2Info)
	)
}

/**
 * In-app registration, as GarpAppv1 links its own form. `null` only when the
 * payload carries no programme type at all.
 */
function registrationUrl(detail: ProgramDetail): string | null {
	return programRegistrationPath(detail.programType ?? "")
}

function setupUrl(detail: ProgramDetail): string | null {
	return programExamSetupHref(detail.programType ?? "")
}

function registerAgainAction(
	detail: ProgramDetail,
	primary: boolean,
): ProgramAction | null {
	const url = registrationUrl(detail)
	if (!url) return null
	return {
		kind: "registerAgain",
		label: "Register Again",
		url,
		isExternal: false,
		primary,
	}
}

function viewResultsAction(
	detail: ProgramDetail,
	primary: boolean,
): ProgramAction | null {
	const url = programResultsPath(detail.programType ?? "")
	if (!url) return null
	return {
		kind: "viewExamResults",
		label: "View Exam Results",
		url,
		isExternal: false,
		primary,
	}
}

/**
 * Which buttons a results-available card offers — GarpAppv1's
 * `setExamButtonText`, reproduced per part.
 *
 * A pass that leaves Part II outstanding offers registration for it, a
 * non-pass offers a re-register while the window is open, and everything
 * falls back to the results page. "Not Available" gets nothing at all.
 */
export function resultActions(
	part: ExamPartInfo,
	detail: ProgramDetail,
): ProgramAction[] {
	if (part.result === "Not Available") return []

	const regOpen = detail.currentRegistrationIsOpen === true
	const results = viewResultsAction(detail, false)
	const regUrl = registrationUrl(detail)

	if (
		part.result === "Pass" &&
		detail.currentRegistrationCanAddPartII === true &&
		regOpen &&
		regUrl
	) {
		return [
			{
				kind: "registerPartII",
				label: "Register for Part II",
				url: regUrl,
				isExternal: false,
				primary: true,
			},
			...(results ? [results] : []),
		]
	}

	if (didNotPass(part.result) && regOpen) {
		const again = registerAgainAction(detail, true)
		if (again) return [again, ...(results ? [results] : [])]
	}

	const primaryResults = viewResultsAction(detail, true)
	return primaryResults ? [primaryResults] : []
}

/**
 * Every action a part offers, in the legacy's order. The single source for
 * the part card and, through the active part, the hero.
 *
 * An unpaid exam change blocks every other action on the sitting: only the
 * pending order is offered.
 */
export function partActions(
	part: ExamPartInfo,
	detail: ProgramDetail,
): ProgramAction[] {
	if (isPartBlocked(part)) {
		const url = programOrderHref(part.unpaidDeferralOrderId)
		return url
			? [
					{
						kind: "viewPendingOrder",
						label: "View Pending Order",
						url,
						isExternal: false,
						primary: true,
					},
				]
			: []
	}

	const actions: ProgramAction[] = []
	const setupHref = setupUrl(detail)

	if (part.showTakeExam === true) {
		const takeUrl = resolveExperienceHref(part.schedulingExamAccessURL)
		if (takeUrl) {
			actions.push({
				kind: "takeExam",
				label: "Take Exam",
				url: takeUrl,
				isExternal: true,
				newWindow: true,
				primary: true,
			})
		}
	} else if (part.isSchedulingOpen === true && setupHref) {
		// The wizard first; the provider SSO is only reached from inside that
		// flow, after selection and payment.
		actions.push({
			kind: part.schedulingIsComplete ? "setup" : "schedule",
			label: part.schedulingIsComplete ? "Exam Setup" : "Schedule Exam",
			url: setupHref,
			isExternal: false,
			primary: true,
		})
	}

	const orderUrl = programOrderHref(part.unpaidOrderId)
	if (part.examPartState === "Unpaid" && orderUrl) {
		actions.push({
			kind: "viewOrder",
			label: "View Order",
			url: orderUrl,
			isExternal: false,
			primary: actions.length === 0,
		})
	}

	// Never scheduled and the window has closed: re-register if it is open
	// AND Part I is still on offer.
	if (
		part.examPartState === "SchedulingClosedNeverScheduled" &&
		detail.currentRegistrationIsOpen === true &&
		detail.currentRegistrationCanRegPartI === true
	) {
		const again = registerAgainAction(detail, actions.length === 0)
		if (again) actions.push(again)
	}

	if (part.examPartState === "SchedulingClosedResultsAvailable") {
		actions.push(...resultActions(part, detail))
	}

	const badgeUrl = partBadgeUrl(part)
	if (badgeUrl) {
		actions.push({
			kind: "digitalBadge",
			label: "Digital Badge",
			url: badgeUrl,
			isExternal: true,
			newWindow: true,
			primary: false,
		})
	}

	return actions
}

/**
 * The legacy's "Manage Your Exam": deferral and adding Part II. Nothing while
 * an unpaid change exists — a second change cannot be requested while the
 * first is unpaid. Deferral is skipped when `existing` already reaches the
 * same wizard, so the card does not offer one page under two names.
 */
export function manageExamActions(
	detail: ProgramDetail,
	existing: ProgramAction[] = [],
): ProgramAction[] {
	if (pendingExamChange(detail)) return []

	const actions: ProgramAction[] = []
	const setupHref = setupUrl(detail)
	if (
		detail.isAnyPartDeferalOpen === true &&
		setupHref &&
		!existing.some((a) => a.url === setupHref)
	) {
		actions.push({
			kind: "deferExam",
			label: "Defer Exam",
			url: setupHref,
			isExternal: false,
		})
	}

	const regUrl = registrationUrl(detail)
	if (
		detail.currentRegistrationCanAddPartII === true &&
		detail.currentRegistrationIsOpen === true &&
		regUrl &&
		!existing.some((a) => a.kind === "registerPartII")
	) {
		actions.push({
			kind: "registerPartII",
			label: `Add ${programTypeLabel(detail)} Part II`,
			url: regUrl,
			isExternal: false,
		})
	}

	return actions
}

/**
 * Which certificate button a certified member gets is decided by programme,
 * not by whether a download URL happens to exist:
 *
 *     SCR · RiskAI · RAIJ   Download Certificate
 *     FRM · ERP             Request Copy of Certificate
 *
 * FRM and ERP certificates are not downloadable at all — a copy is ordered
 * through the legacy checkout. Testing `certificateDownloadURL` alone, which
 * is null for every FRM member, rendered neither.
 */
export function certificateAction(
	detail: ProgramDetail,
): ProgramAction | null {
	const slug = programTypeSlug(detail.programType ?? "")
	if (slug === "frm" || slug === "erp") {
		const url = certificateCopyCheckoutHref(slug)
		return url
			? {
					kind: "requestCertificate",
					label: "Request Copy of Certificate",
					url,
					isExternal: true,
					primary: true,
				}
			: null
	}
	const certUrl = resolveExperienceHref(detail.certificateDownloadURL)
	if (!certUrl) return null
	return {
		kind: "downloadCertificate",
		label: "Download Certificate",
		url: certUrl,
		isExternal: true,
		newWindow: true,
		primary: true,
	}
}

function completedActions(detail: ProgramDetail): ProgramAction[] {
	const actions: ProgramAction[] = []
	const certificate = certificateAction(detail)
	if (certificate) actions.push(certificate)
	const badgeUrl = resolveExperienceHref(detail.digitalBadgheURL)
	if (badgeUrl) {
		actions.push({
			kind: "digitalBadge",
			label: "Digital Badge",
			url: badgeUrl,
			isExternal: true,
			newWindow: true,
			primary: actions.length === 0,
		})
	}
	actions.push({
		kind: "directory",
		label: "Directory settings",
		url: "/membership?tab=directory",
		isExternal: false,
		primary: actions.length === 0,
	})
	const results = viewResultsAction(detail, false)
	if (results) actions.push(results)
	return actions
}

function partStatusSummary(
	part: ExamPartInfo,
	detail: ProgramDetail,
): { label: string; tone: StatusTone; summary: string } {
	switch (part.examPartState) {
		case "Unpaid":
			return {
				label: "Payment required",
				tone: "warning",
				summary: part.unpaidOrderPayByDate
					? `Your registration is not yet paid. Pay by ${formatLongDate(part.unpaidOrderPayByDate.slice(0, 10))}.`
					: "Your registration is not yet paid.",
			}
		case "Deferred":
			return {
				label: "Deferred",
				tone: "info",
				summary: [
					`Your exam has been deferred${part.deferredAdminName?.trim() ? ` to ${part.deferredAdminName.trim()}` : ""}.`,
					part.deferredExamSetupOpenDate
						? `Exam setup opens ${formatLongDate(part.deferredExamSetupOpenDate.slice(0, 10))}.`
						: null,
				]
					.filter(Boolean)
					.join(" "),
			}
		case "AwaitingSchedulingToOpen":
			return {
				label: "Setup opening soon",
				tone: "info",
				summary: `Exam setup opens ${formatLongDate(part.schedulingAwaitingToOpenOpenDate?.slice(0, 10)) ?? "soon"}.`,
			}
		case "SchedulingOpen":
			return {
				label: part.schedulingIsComplete
					? "Exam scheduled"
					: "Scheduling open",
				tone: part.schedulingIsComplete ? "success" : "info",
				summary: part.schedulingIsComplete
					? "Your exam is scheduled. You can still update your setup while the window is open."
					: part.schedulingDeadline
						? `Exam setup is open — schedule your exam before ${formatLongDate(part.schedulingDeadline.slice(0, 10))}.`
						: "Exam setup is open — schedule your exam.",
			}
		case "SchedulingClosedNeverScheduled":
			return {
				label: "Registration expired",
				tone: "danger",
				summary: detail.nextRegistrationOpenDate
					? `Your registration has expired. Register again on ${formatLongDate(detail.nextRegistrationOpenDate.slice(0, 10))}.`
					: detail.currentRegistrationIsOpen
						? "Your registration has expired. Registration is open — register again to continue."
						: "Your registration has expired. Register again when exam results are released.",
			}
		case "SchedulingClosedAwaitingToTakeExam":
			return {
				label: "Ready to take exam",
				tone: "success",
				summary: "You are scheduled to sit this exam.",
			}
		case "SchedulingClosedAwaitingResults":
			return {
				label: "Awaiting results",
				tone: "info",
				summary:
					part.resultsAvailableStatement?.trim() ||
					"Your exam results are being prepared.",
			}
		case "SchedulingClosedResultsAvailable":
			return {
				label: "Results available",
				tone: part.result === "Pass" ? "success" : "neutral",
				summary:
					resultCopy(part.result) ??
					part.result?.trim() ??
					"Your exam results are available.",
			}
		default:
			return {
				label: "In progress",
				tone: "neutral",
				summary: "Review your exam details and next steps below.",
			}
	}
}

function buildMilestones(
	detail: ProgramDetail,
	part: ExamPartInfo | null,
): JourneyMilestone[] {
	const state = detail.programState

	if (state === "Completed") {
		return [
			{
				id: "registration",
				label: "Registration",
				status: "complete",
			},
			{ id: "scheduling", label: "Scheduling", status: "complete" },
			{ id: "exam", label: "Exam", status: "complete" },
			{ id: "results", label: "Results", status: "complete" },
			{
				id: "certification",
				label: "Certification",
				status: "complete",
				detail: detail.programCompletedDate
					? `Completed ${formatLongDate(detail.programCompletedDate.slice(0, 10))}`
					: null,
			},
		]
	}

	if (state === "CVSubmission") {
		return [
			{
				id: "registration",
				label: "Registration",
				status: "complete",
			},
			{ id: "scheduling", label: "Scheduling", status: "complete" },
			{ id: "exam", label: "Exam", status: "complete" },
			{ id: "results", label: "Results", status: "complete" },
			{
				id: "certification",
				label: "Work experience",
				status: "current",
				detail: cvStatusCopy(detail.cvStatus),
			},
		]
	}

	if (state === "EnrollmentExpired" || !part) {
		return [
			{
				id: "registration",
				label: "Registration",
				status: "blocked",
				detail: "Your enrollment is no longer active.",
			},
			{ id: "scheduling", label: "Scheduling", status: "upcoming" },
			{ id: "exam", label: "Exam", status: "upcoming" },
			{ id: "results", label: "Results", status: "upcoming" },
		]
	}

	const milestones: JourneyMilestone[] = []

	switch (part.examPartState) {
		case "Unpaid":
			milestones.push(
				{
					id: "registration",
					label: "Registration",
					status: "current",
					detail: "Payment pending",
				},
				{ id: "scheduling", label: "Scheduling", status: "upcoming" },
				{ id: "exam", label: "Exam", status: "upcoming" },
				{ id: "results", label: "Results", status: "upcoming" },
			)
			break
		case "Deferred":
		case "AwaitingSchedulingToOpen":
			milestones.push(
				{
					id: "registration",
					label: "Registration",
					status: "complete",
				},
				{
					id: "scheduling",
					label: "Scheduling",
					status: "current",
					detail:
						part.examPartState === "Deferred"
							? "Deferred — setup opens later"
							: "Waiting for setup window",
				},
				{ id: "exam", label: "Exam", status: "upcoming" },
				{ id: "results", label: "Results", status: "upcoming" },
			)
			break
		case "SchedulingOpen":
			milestones.push(
				{
					id: "registration",
					label: "Registration",
					status: "complete",
				},
				{
					id: "scheduling",
					label: "Scheduling",
					status: "current",
					detail: part.schedulingIsComplete
						? "Scheduled — edits still open"
						: "Schedule your sitting",
				},
				{ id: "exam", label: "Exam", status: "upcoming" },
				{ id: "results", label: "Results", status: "upcoming" },
			)
			break
		case "SchedulingClosedNeverScheduled":
			milestones.push(
				{
					id: "registration",
					label: "Registration",
					status: "blocked",
					detail: "Expired without scheduling",
				},
				{ id: "scheduling", label: "Scheduling", status: "blocked" },
				{ id: "exam", label: "Exam", status: "upcoming" },
				{ id: "results", label: "Results", status: "upcoming" },
			)
			break
		case "SchedulingClosedAwaitingToTakeExam":
			milestones.push(
				{
					id: "registration",
					label: "Registration",
					status: "complete",
				},
				{ id: "scheduling", label: "Scheduling", status: "complete" },
				{
					id: "exam",
					label: "Exam",
					status: "current",
					detail: formatDateTime(part.schedulingExamDateTimeSelected),
				},
				{ id: "results", label: "Results", status: "upcoming" },
			)
			break
		case "SchedulingClosedAwaitingResults":
			milestones.push(
				{
					id: "registration",
					label: "Registration",
					status: "complete",
				},
				{ id: "scheduling", label: "Scheduling", status: "complete" },
				{ id: "exam", label: "Exam", status: "complete" },
				{
					id: "results",
					label: "Results",
					status: "current",
					detail: "Preparing your results",
				},
			)
			break
		case "SchedulingClosedResultsAvailable":
			milestones.push(
				{
					id: "registration",
					label: "Registration",
					status: "complete",
				},
				{ id: "scheduling", label: "Scheduling", status: "complete" },
				{ id: "exam", label: "Exam", status: "complete" },
				{
					id: "results",
					label: "Results",
					status: "current",
					detail: part.result ?? "Available",
				},
			)
			break
		default:
			milestones.push(
				{
					id: "registration",
					label: "Registration",
					status: "complete",
				},
				{ id: "scheduling", label: "Scheduling", status: "current" },
				{ id: "exam", label: "Exam", status: "upcoming" },
				{ id: "results", label: "Results", status: "upcoming" },
			)
	}

	return milestones
}

function splitActions(actions: ProgramAction[]): {
	primaryAction: ProgramAction | null
	secondaryActions: ProgramAction[]
} {
	const primary =
		actions.find((action) => action.primary) ?? actions[0] ?? null
	const secondary = actions.filter((action) => action !== primary)
	return { primaryAction: primary, secondaryActions: secondary }
}

/**
 * Friendly wording for the raw `Candidate_Requirement__c.Status__c`.
 *
 * The status itself is never shown. Legacy printed "Current status: Initial"
 * straight at the member; the vocabulary below is legacy's own mapping
 * ("Submission Received" / "Review Failed" / "Submission Needed"), reworded.
 */
function cvStatusCopy(cvStatus: string | null | undefined): string {
	switch (cvStatus?.trim()) {
		case "Ready For Review":
			return "Your submission has been received and is under review."
		case "Failed Review":
			return "We need more information before your submission can be approved."
		default:
			return "Submit your work experience to finish certification."
	}
}

/**
 * The work-experience card's copy, keyed on `cvStatus` — GarpAppv1's
 * `CvSubmissionCard`, minus its typos. The note is the consequence of missing
 * the window, which differs by programme.
 */
export function cvSubmissionCopy(detail: ProgramDetail): {
	heading: string
	body: string
	notes: string[]
} {
	const type = programTypeLabel(detail)
	switch (detail.cvStatus?.trim()) {
		case "Ready For Review":
			return {
				heading: "Submission received",
				body: "Thank you for submitting your work experience. Your submission has been received and is now under review.",
				notes: [],
			}
		case "Failed Review":
			return {
				heading: "Submission denied",
				body: "After a review of your submission we require some more information. You will be contacted shortly.",
				notes: [],
			}
		default: {
			const notes: string[] = []
			if (type === "FRM") {
				notes.push(
					"Please note: GARP requires candidates to submit their work experience within 10 years of sitting for the FRM Exam Part II, or else they will be required to re-enroll in the FRM Program as a new candidate.",
				)
			}
			if (type === "ERP") {
				notes.push(
					"Please note: GARP requires candidates to submit their work experience within 10 years of sitting for the ERP Exam Part II, or else their program will expire and they will not be able to complete certification.",
				)
			}
			return {
				heading: "Submission required",
				body: `Before you can become ${type === "ERP" ? "an" : "a certified"} ${type} you must submit two years of professional work experience. We will contact you in the event we require further information.`,
				notes,
			}
		}
	}
}

/**
 * Appends the work-experience entry point.
 *
 * Gated on `programState === "CVSubmission"`, which is what both reference
 * apps do — GarpAppv1 renders its CV card on exactly that condition, and
 * MyGarp on the equivalent `isAllPartsPassed && !isCertified`. Apex folds the
 * whole rule set into that one flag: two-part programme, contract not Expired
 * or Completed, both parts passed, and (FRM only) results no longer loading.
 *
 * It deliberately does NOT key off `cvStatus`. Every FRM/ERP enrollment gets a
 * Job_Experience requirement at signup — all 107 in this org sit at "Initial" —
 * so a has-a-CV test is true from day one and put the CTA on every programme
 * page, including members who have passed neither exam part.
 */
function withWorkExperienceAction(
	detail: ProgramDetail,
	presentation: ProgramDetailPresentation,
): ProgramDetailPresentation {
	if (detail.programState !== "CVSubmission") return presentation
	const url = programWorkExperiencePath(detail.programType ?? "")
	if (!url) return presentation
	if (
		presentation.primaryAction?.kind === "workExperience" ||
		presentation.secondaryActions.some((a) => a.kind === "workExperience")
	) {
		return presentation
	}

	// Awaiting review: there is nothing to submit, but the submission stays
	// readable — legacy's "View Your Submission". GarpAppv1 drops the link
	// entirely here, which strands the member on a status line.
	const underReview = detail.cvStatus?.trim() === "Ready For Review"
	const action: ProgramAction = {
		kind: "workExperience",
		label: underReview
			? "View work experience"
			: detail.cvStatus?.trim() === "Failed Review"
				? "Resubmit work experience"
				: "Submit work experience",
		url,
		isExternal: false,
	}

	if (!presentation.primaryAction && !underReview) {
		return { ...presentation, primaryAction: { ...action, primary: true } }
	}
	return {
		...presentation,
		secondaryActions: [...presentation.secondaryActions, action],
	}
}

/**
 * Maps Apex `ProgramDetail` into UI-ready status, CTAs, and journey milestones.
 * Pure — no React. Safe to unit-test every exam / program state.
 */
export function buildProgramDetailPresentation(
	detail: ProgramDetail,
): ProgramDetailPresentation {
	return withWorkExperienceAction(detail, buildStatePresentation(detail))
}

function nextStepFor(
	primaryAction: ProgramAction | null,
	detail: ProgramDetail,
	fallbackBody: string,
): { title: string; body: string } {
	switch (primaryAction?.kind) {
		case "schedule":
			return {
				title: "Schedule your exam",
				body: "Open exam setup to choose your sitting while the scheduling window is open.",
			}
		case "setup":
			return {
				title: "Update your exam setup",
				body: "Review or change your exam administration and site in exam setup.",
			}
		case "takeExam":
			return {
				title: "Take your exam",
				body: "Launch your exam provider when you are ready to sit.",
			}
		case "registerAgain":
			return {
				title: "Register again",
				body: "Registration is open — register again to continue.",
			}
		case "registerPartII":
			return {
				title: "Register for Part II",
				body: `Registration is open — register for the ${programTypeLabel(detail)} Exam Part II to continue your certification.`,
			}
		case "viewOrder":
			return {
				title: "Complete your payment",
				body: "Review your unpaid order and complete payment to unlock setup.",
			}
		case "deferExam":
			return {
				title: "Defer your exam",
				body: "Move your sitting to a later administration in exam setup while the deferral window is open.",
			}
		case "viewExamResults":
			return {
				title: "Review your exam results",
				body: "See your official result, quartile rankings, and downloadable letters.",
			}
		default:
			return { title: "Your next step", body: fallbackBody }
	}
}

function buildStatePresentation(
	detail: ProgramDetail,
): ProgramDetailPresentation {
	const displayName = displayProgramName(detail)
	const examLabel = detail.programType?.trim() || displayName
	const description = detail.programInformation?.description?.trim() || null
	const isTwoPart = isTwoPartProgram(detail)
	const part = activeExamPart(detail)
	const administration =
		part?.examAttemptAdminName?.trim() ||
		detail.currentRegistrationAdminName?.trim() ||
		null

	if (detail.programState === "Completed") {
		const actions = completedActions(detail)
		const { primaryAction, secondaryActions } = splitActions(actions)
		const completedOn = detail.programCompletedDate
			? formatLongDate(detail.programCompletedDate.slice(0, 10))
			: null
		const requestable = primaryAction?.kind === "requestCertificate"
		return {
			displayName,
			examLabel,
			description,
			administration: null,
			statusLabel: "Certified",
			statusTone: "success",
			statusSummary: completedOn
				? `Congratulations! You completed the ${displayName} Program on ${completedOn}.`
				: `Congratulations! You have completed the ${displayName} Program.`,
			nextStepTitle: "Celebrate your certification",
			nextStepBody: requestable
				? "Request a printed copy of your certificate, share your digital badge, or update your directory listing."
				: "Download your certificate, share your digital badge, or update your directory listing.",
			nextStepTone: "success",
			notes: [],
			primaryAction,
			secondaryActions,
			milestones: buildMilestones(detail, part),
			isTwoPart,
		}
	}

	if (detail.programState === "CVSubmission") {
		const copy = cvSubmissionCopy(detail)
		const { primaryAction, secondaryActions } = splitActions(
			manageExamActions(detail),
		)
		return {
			displayName,
			examLabel,
			description,
			administration: null,
			statusLabel: "Work experience",
			statusTone: "info",
			statusSummary:
				"Congratulations! You are almost there to getting certified. Submit your work experience to complete your certification.",
			nextStepTitle: copy.heading,
			nextStepBody: copy.body,
			nextStepTone: "info",
			notes: copy.notes,
			// Manage actions never claim primary here — the work-experience CTA
			// appended afterwards is the point of this state.
			primaryAction: null,
			secondaryActions: primaryAction
				? [primaryAction, ...secondaryActions]
				: secondaryActions,
			milestones: buildMilestones(detail, part),
			isTwoPart,
		}
	}

	if (detail.programState === "EnrollmentExpired") {
		const regOpen = detail.currentRegistrationIsOpen === true
		const again = regOpen ? registerAgainAction(detail, true) : null
		const nextDate = formatLongDate(
			detail.nextRegistrationOpenDate?.slice(0, 10),
		)
		const { primaryAction, secondaryActions } = splitActions(
			again ? [again] : [],
		)
		return {
			displayName,
			examLabel,
			description,
			administration,
			statusLabel: "Enrollment expired",
			statusTone: "danger",
			statusSummary: "Your registration has expired.",
			nextStepTitle: "Register again",
			nextStepBody: nextDate
				? `The next window opens on ${nextDate}.`
				: again
					? "Registration is open — register again to continue."
					: "Register again when exam results are released.",
			nextStepTone: "danger",
			notes: [],
			primaryAction,
			secondaryActions,
			milestones: buildMilestones(detail, part),
			isTwoPart,
		}
	}

	// ExamAttempt (default)
	if (!part) {
		return {
			displayName,
			examLabel,
			description,
			administration,
			statusLabel: "In progress",
			statusTone: "neutral",
			statusSummary:
				"No exam attempt details are available for this program yet.",
			nextStepTitle: "Check back soon",
			nextStepBody:
				"Exam details will appear here once your registration is processed.",
			nextStepTone: "neutral",
			notes: [],
			primaryAction: null,
			secondaryActions: [],
			milestones: buildMilestones(detail, part),
			isTwoPart,
		}
	}

	const status = partStatusSummary(part, detail)
	const pending = pendingExamChange(detail)

	if (pending) {
		const { primaryAction, secondaryActions } = splitActions(
			partActions(pending.part, detail),
		)
		return {
			displayName,
			examLabel,
			description,
			administration,
			statusLabel: status.label,
			statusTone: status.tone,
			statusSummary: status.summary,
			nextStepTitle: "You have an unpaid exam change",
			nextStepBody: unpaidChangeMessage(pending.part),
			nextStepTone: "danger",
			notes: [],
			primaryAction,
			secondaryActions,
			milestones: buildMilestones(detail, part),
			isTwoPart,
		}
	}

	const actions = partActions(part, detail)
	actions.push(...manageExamActions(detail, actions))
	const { primaryAction, secondaryActions } = splitActions(actions)
	const next = nextStepFor(primaryAction, detail, status.summary)
	const notes = actions.some((a) => a.kind === "takeExam")
		? [TAKE_EXAM_NOTE]
		: []

	return {
		displayName,
		examLabel,
		description,
		administration,
		statusLabel: status.label,
		statusTone: status.tone,
		statusSummary: status.summary,
		nextStepTitle: next.title,
		nextStepBody: next.body,
		nextStepTone: status.tone,
		notes,
		primaryAction,
		secondaryActions,
		milestones: buildMilestones(detail, part),
		isTwoPart,
	}
}

export function examPartTitle(
	detail: ProgramDetail,
	partIndex: 1 | 2,
): string {
	const examLabel = detail.programType?.trim() || displayProgramName(detail)
	if (partIndex === 2) return `${examLabel} Exam Part II`
	return isTwoPartProgram(detail) ? `${examLabel} Exam Part I` : `${examLabel} Exam`
}
