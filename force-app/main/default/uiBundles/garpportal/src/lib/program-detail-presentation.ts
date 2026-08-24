import type {
	ExamPartInfo,
	ProgramDetail,
} from "@/api/programs"
import { formatDateTime, formatLongDate } from "@/lib/account-format"
import {
	programExamSetupHref,
	programOrderHref,
	programRegistrationHref,
	programResultsPath,
	programWorkExperiencePath,
	resolveExperienceHref,
} from "@/lib/program-card-links"
import { stripProgramFormalName } from "@/lib/program-formal-name"
import type { StatusTone } from "@/lib/status-tone"


export type ProgramActionKind =
	| "schedule"
	| "setup"
	| "takeExam"
	| "viewOrder"
	| "viewExamResults"
	| "workExperience"
	| "registerAgain"
	| "digitalBadge"
	| "downloadCertificate"
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
	primaryAction: ProgramAction | null
	secondaryActions: ProgramAction[]
	milestones: JourneyMilestone[]
	isTwoPart: boolean
}

/** Legacy result sentences keyed by Apex `result`. */
const RESULT_COPY: Record<string, string> = {
	Pass: "Congratulations! You are almost there to getting certified!",
	Fail: "We regret to inform you, your result did not meet the requirement to pass.",
	"No-Show": "We have no record of you attending this exam.",
	"Not Graded": "Your Exam was not graded.",
	"Not Available": "Your exam result is not available.",
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

export function resultCopy(result: string | null | undefined): string | null {
	if (!result?.trim()) return null
	return RESULT_COPY[result] ?? result
}

/** Prefer part 1; fall back to part 2 when part 1 is stale/missing. */
export function activeExamPart(
	detail: ProgramDetail,
): ExamPartInfo | null {
	const part1 =
		detail.examPart1Info && detail.examPart1Info.isResultStale !== true
			? detail.examPart1Info
			: null
	if (part1) return part1
	const part2 =
		detail.examPart2Info && detail.examPart2Info.isResultStale !== true
			? detail.examPart2Info
			: null
	return part2
}

function registrationUrl(detail: ProgramDetail): string | null {
	return programRegistrationHref(
		detail.programInformation?.registrationPath,
		detail.programType ?? "",
		false,
	)
}

function setupUrl(detail: ProgramDetail): string | null {
	return programExamSetupHref(detail.programType ?? "")
}

function partActions(
	part: ExamPartInfo,
	detail: ProgramDetail,
): ProgramAction[] {
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
		actions.push({
			kind: part.schedulingIsComplete ? "setup" : "schedule",
			label: part.schedulingIsComplete ? "Exam Setup" : "Schedule Exam",
			url: setupHref,
			isExternal: true,
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

	if (
		part.examPartState === "SchedulingClosedNeverScheduled" &&
		detail.currentRegistrationIsOpen === true
	) {
		const regUrl = registrationUrl(detail)
		if (regUrl) {
			actions.push({
				kind: "registerAgain",
				label: "Register Again",
				url: regUrl,
				isExternal: true,
				primary: actions.length === 0,
			})
		}
	}

	const badgeUrl = resolveExperienceHref(part.badgePageURL ?? part.badgeURL)
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

	if (part.examPartState === "SchedulingClosedResultsAvailable") {
		const resultsUrl = programResultsPath(detail.programType ?? "")
		if (resultsUrl) {
			actions.unshift({
				kind: "viewExamResults",
				label: "View Exam Results",
				url: resultsUrl,
				isExternal: false,
				primary: true,
			})
			// Only one primary — demote anything else that claimed it.
			for (const action of actions) {
				if (action.kind !== "viewExamResults") action.primary = false
			}
		}
	}

	return actions
}

function completedActions(detail: ProgramDetail): ProgramAction[] {
	const actions: ProgramAction[] = []
	const certUrl = resolveExperienceHref(detail.certificateDownloadURL)
	if (certUrl) {
		actions.push({
			kind: "downloadCertificate",
			label: "Download Certificate",
			url: certUrl,
			isExternal: true,
			newWindow: true,
			primary: true,
		})
	}
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
	const resultsUrl = programResultsPath(detail.programType ?? "")
	if (resultsUrl) {
		actions.push({
			kind: "viewExamResults",
			label: "View Exam Results",
			url: resultsUrl,
			isExternal: false,
			primary: false,
		})
	}
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
 * Maps Apex `ProgramDetail` into UI-ready status, CTAs, and journey milestones.
 * Pure — no React. Safe to unit-test every exam / program state.
 */
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

export function buildProgramDetailPresentation(
	detail: ProgramDetail,
): ProgramDetailPresentation {
	return withWorkExperienceAction(detail, buildStatePresentation(detail))
}

function buildStatePresentation(
	detail: ProgramDetail,
): ProgramDetailPresentation {
	const displayName = displayProgramName(detail)
	const examLabel = detail.programType?.trim() || displayName
	const description = detail.programInformation?.description?.trim() || null
	const isTwoPart =
		detail.programType === "FRM" || detail.programType === "ERP"
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
			nextStepBody:
				"Download your certificate, share your digital badge, or update your directory listing.",
			primaryAction,
			secondaryActions,
			milestones: buildMilestones(detail, part),
			isTwoPart,
		}
	}

	if (detail.programState === "CVSubmission") {
		return {
			displayName,
			examLabel,
			description,
			administration: null,
			statusLabel: "Work experience",
			statusTone: "info",
			statusSummary:
				"Congratulations! You are almost there to getting certified. Submit your work experience to complete your certification.",
			nextStepTitle: "Finish certification",
			nextStepBody:
				"Add the roles that make up your two years of risk management experience, then submit them for review.",
			primaryAction: null,
			secondaryActions: [],
			milestones: buildMilestones(detail, part),
			isTwoPart,
		}
	}

	if (detail.programState === "EnrollmentExpired") {
		const regOpen = detail.currentRegistrationIsOpen === true
		const regUrl = regOpen ? registrationUrl(detail) : null
		const nextDate = formatLongDate(
			detail.nextRegistrationOpenDate?.slice(0, 10),
		)
		const actions: ProgramAction[] = []
		if (regUrl) {
			actions.push({
				kind: "registerAgain",
				label: "Register Again",
				url: regUrl,
				isExternal: true,
				primary: true,
			})
		}
		const { primaryAction, secondaryActions } = splitActions(actions)
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
				: regUrl
					? "Registration is open — continue in MyGarp to enroll again."
					: "Register again when exam results are released.",
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
			primaryAction: null,
			secondaryActions: [],
			milestones: buildMilestones(detail, part),
			isTwoPart,
		}
	}

	const status = partStatusSummary(part, detail)
	const actions = partActions(part, detail)
	const { primaryAction, secondaryActions } = splitActions(actions)

	const nextStepTitle =
		primaryAction?.label === "Schedule Exam"
			? "Schedule your exam"
			: primaryAction?.label === "Exam Setup"
				? "Update your exam setup"
				: primaryAction?.label === "Take Exam"
					? "Take your exam"
					: primaryAction?.label === "Register Again"
						? "Register again"
						: primaryAction?.label === "View Order"
							? "Complete your payment"
							: primaryAction?.label === "View Exam Results"
								? "Review your exam results"
								: "Your next step"

	const nextStepBody =
		primaryAction?.kind === "schedule"
			? "Open exam setup to choose your sitting while the scheduling window is open."
			: primaryAction?.kind === "setup"
				? "Review or change your exam administration and site in exam setup."
				: primaryAction?.kind === "takeExam"
					? "Launch your exam provider when you are ready to sit."
					: primaryAction?.kind === "registerAgain"
						? "Registration is open — continue in MyGarp to enroll again."
						: primaryAction?.kind === "viewOrder"
							? "Review your unpaid order and complete payment to unlock setup."
							: primaryAction?.kind === "viewExamResults"
								? "See your official result, quartile rankings, and downloadable letters."
								: status.summary

	return {
		displayName,
		examLabel,
		description,
		administration,
		statusLabel: status.label,
		statusTone: status.tone,
		statusSummary: status.summary,
		nextStepTitle,
		nextStepBody,
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
	const twoPart =
		detail.programType === "FRM" || detail.programType === "ERP"
	if (partIndex === 2) return `${examLabel} Exam Part II`
	return twoPart ? `${examLabel} Exam Part I` : `${examLabel} Exam`
}
