import { GraduationCap } from "lucide-react"

/**
 * Static config for course detail (`/courses/$courseType`).
 *
 * Only the three fixed courses are listed. Micro courses are **not** — their
 * codes come from `ProgramsView.microCourseConfig` at runtime and cannot be
 * enumerated here, so anything not in this map is passed through as a code.
 */

/** Route slug → the `courseType` Apex matches on. */
export const FIXED_COURSE_TYPES: Record<string, string> = {
	frr: "FRR",
	frr25: "FRR25",
	ffr: "FFR",
}

/** Display names, from the legacy's own page titles. */
export const COURSE_NAMES: Record<string, string> = {
	FRR: "Financial Risk and Regulation",
	FRR25: "Financial Risk and Regulation",
	FFR: "Foundations of Financial Risk",
}

/** Headline and tone per state. `programState` is the page's whole story. */
export const COURSE_STATE_COPY = {
	Unpaid: {
		label: "Payment outstanding",
		tone: "warning",
		next: "Complete your payment",
		body: "Your enrolment starts once this order is paid.",
	},
	Enrolled: {
		label: "Enrolled",
		tone: "info",
		next: "Work through your course",
		body: "Your course materials are ready.",
	},
	AwaitingResults: {
		label: "Awaiting results",
		tone: "info",
		next: "Wait for your result",
		body: "You have sat the exam. We'll let you know as soon as it is graded.",
	},
	ResultsAvailable: {
		label: "Result available",
		tone: "success",
		next: "Your result",
		body: "Your exam has been graded.",
	},
	Completed: {
		label: "Completed",
		tone: "success",
		next: "You're done",
		body: "You have completed this course.",
	},
	Expired: {
		label: "Enrolment expired",
		tone: "neutral",
		next: "Your enrolment has ended",
		body: "This enrolment is no longer active. Contact Member Services if you think that's wrong.",
	},
} as const

/** The four stops a course passes through. */
export const COURSE_JOURNEY = [
	{ id: "registration", label: "Enrolled" },
	{ id: "coursework", label: "Coursework" },
	{ id: "exam", label: "Exam" },
	{ id: "results", label: "Result" },
] as const

export const COURSE_UNAVAILABLE = {
	icon: GraduationCap,
	title: "This course isn't on your account",
	message:
		"You may not be enrolled, or the enrolment may not have a sitting behind it yet. If you believe this is wrong, contact Member Services.",
} as const
