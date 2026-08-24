import type { CourseDetail, CourseState } from "@/api/courses"
import {
	COURSE_JOURNEY,
	COURSE_NAMES,
	COURSE_STATE_COPY,
	FIXED_COURSE_TYPES,
} from "@/config/courses"
import type {
	JourneyMilestone,
	ProgramAction,
	ProgramDetailPresentation,
} from "@/lib/program-detail-presentation"

/**
 * Route slug → the `courseType` Apex matches on.
 *
 * Apex compares against a fixed upper-cased map (`FRR` / `FRR25` / `FFR`) and
 * then against the micro-course codes, so a lower-cased slug matches neither
 * and comes back 501. Micro codes cannot be enumerated here — they arrive at
 * runtime on `ProgramsView.microCourseConfig` — so anything unknown is passed
 * through upper-cased rather than rejected.
 */
export function courseTypeFromSlug(slug: string): string | null {
	const value = slug.trim()
	if (!value) return null
	return FIXED_COURSE_TYPES[value.toLowerCase()] ?? value.toUpperCase()
}

/** The name to show. Micro courses carry their own; the three fixed ones do not. */
export function courseDisplayName(detail: CourseDetail): string {
	const fromCatalogue =
		detail.programInformation?.formalName?.trim() ||
		detail.microCourseInfo?.formalName?.trim() ||
		detail.microCourseInfo?.name?.trim()
	if (fromCatalogue) return fromCatalogue
	const code = detail.programType?.trim().toUpperCase() ?? ""
	return COURSE_NAMES[code] ?? code ?? "Course"
}

/**
 * Whether this course has an exam at all.
 *
 * Gated on the payload rather than on the course code. FFR is the exam-less one
 * today — Apex returns before it ever looks for a sitting — but keying off
 * `programType === "FFR"` would mean a future exam-less course renders an empty
 * exam panel until someone remembers to add it to a list.
 */
export function courseHasExam(detail: CourseDetail): boolean {
	return Boolean(
		detail.examAttemptId ||
			detail.examResult ||
			detail.scheduledExamDateTime ||
			detail.onlineExamSchedulingID ||
			detail.OnlineExamSchedulingAccessURL,
	)
}

/**
 * The retake line, or null when none is offered.
 *
 * Both halves are already resolved server-side per course — FRR only 30 days
 * after the sitting, FRR25 and micro immediately, and never after a Pass. This
 * reads them; it does not re-derive anything from the course code.
 */
export function courseRetakeCopy(
	detail: CourseDetail,
	formatDate: (iso: string) => string,
): string | null {
	if (detail.examRetakeAvailable === true) {
		return "You can retake this exam."
	}
	const from = detail.examRetakeAvailableDate?.trim()
	if (from) {
		return `You can retake this exam from ${formatDate(from)}.`
	}
	return null
}

/** Which stops are done, where the member is, and what is still ahead. */
export function courseMilestones(detail: CourseDetail): JourneyMilestone[] {
	const state = detail.programState
	const hasExam = courseHasExam(detail)

	/* Position on the journey, as an index into COURSE_JOURNEY. */
	const reached: Record<CourseState, number> = {
		Unpaid: -1,
		Enrolled: 1,
		AwaitingResults: 2,
		ResultsAvailable: 3,
		Completed: 3,
		Expired: 0,
	}
	const at = state ? reached[state] : 0

	return COURSE_JOURNEY.filter(
		// An exam-less course has no exam or result stop to show.
		(step) => hasExam || (step.id !== "exam" && step.id !== "results"),
	).map((step, index) => {
		let status: JourneyMilestone["status"] = "upcoming"
		if (state === "Expired") status = index === 0 ? "blocked" : "upcoming"
		else if (state === "Completed") status = "complete"
		else if (index < at) status = "complete"
		else if (index === at) status = "current"
		return { id: step.id, label: step.label, status }
	})
}

function actionsFor(detail: CourseDetail): {
	primary: ProgramAction | null
	secondary: ProgramAction[]
} {
	const secondary: ProgramAction[] = []
	let primary: ProgramAction | null = null

	const learning = detail.eLearningPlatformAccessURL?.trim()
	const ebook = detail.eBookAccessURL?.trim()
	const certificate = detail.downloadCertificateURL?.trim()
	const order = detail.unpaidOrderId?.trim()

	if (detail.programState === "Unpaid" && order) {
		primary = {
			kind: "viewOrder",
			label: "View order",
			url: `/my-account/orders/${order}`,
			isExternal: false,
			primary: true,
		}
	} else if (detail.programState === "Completed" && certificate) {
		primary = {
			kind: "downloadCertificate",
			label: "Download certificate",
			url: certificate,
			isExternal: true,
			newWindow: true,
			primary: true,
		}
	} else if (learning) {
		primary = {
			kind: "eLearning",
			label: detail.eLearningPlatformName?.trim()
				? `Open ${detail.eLearningPlatformName.trim()}`
				: "Open your course",
			url: learning,
			isExternal: true,
			newWindow: true,
			primary: true,
		}
	}

	/*
	 * `showTakeExam` is the gate, not the URL. The scheduling link outlives the
	 * ±2 day window it is valid in, so offering it whenever it exists would
	 * send members to a provider that will turn them away.
	 */
	if (detail.showTakeExam === true && detail.OnlineExamSchedulingAccessURL) {
		secondary.push({
			kind: "takeExam",
			label: "Take exam",
			url: detail.OnlineExamSchedulingAccessURL,
			isExternal: true,
			newWindow: true,
		})
	}

	if (ebook) {
		secondary.push({
			kind: "eBook",
			label: "Open eBook",
			url: ebook,
			isExternal: true,
			newWindow: true,
		})
	}

	if (certificate && detail.programState !== "Completed") {
		secondary.push({
			kind: "downloadCertificate",
			label: "Download certificate",
			url: certificate,
			isExternal: true,
			newWindow: true,
		})
	}

	return { primary, secondary }
}

/**
 * Maps `CourseDetail` onto the same presentation the programme pages use.
 *
 * Deliberately produces a `ProgramDetailPresentation` so `ProgramDetailHero`
 * and `ProgramJourney` work untouched — the page is a different payload, not a
 * different design. `isTwoPart` is always false: a course has one contract, one
 * sitting, and none of the part machinery.
 */
export function buildCourseDetailPresentation(
	detail: CourseDetail,
): ProgramDetailPresentation {
	const state = detail.programState
	const copy = state ? COURSE_STATE_COPY[state] : COURSE_STATE_COPY.Enrolled
	const { primary, secondary } = actionsFor(detail)
	const name = courseDisplayName(detail)

	return {
		displayName: name,
		examLabel: name,
		description: detail.programInformation?.description ?? null,
		administration: null,
		statusLabel: copy.label,
		statusTone: copy.tone,
		statusSummary: copy.body,
		nextStepTitle: copy.next,
		nextStepBody: copy.body,
		primaryAction: primary,
		secondaryActions: secondary,
		milestones: courseMilestones(detail),
		isTwoPart: false,
	}
}
