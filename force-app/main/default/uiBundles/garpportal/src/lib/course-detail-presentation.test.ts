import { describe, expect, it } from "vitest"

import type { CourseDetail, CourseState } from "@/api/courses"
import {
	buildCourseDetailPresentation,
	courseDisplayName,
	courseHasExam,
	courseMilestones,
	courseRetakeCopy,
	courseTypeFromSlug,
} from "./course-detail-presentation"

function course(over: Partial<CourseDetail> = {}): CourseDetail {
	return {
		programState: "Enrolled",
		programType: "FRR25",
		programRegisteredOnDate: "2026-01-05",
		programExpireDate: "2027-01-05",
		examAttemptId: "a0X1",
		paymentStatus: "Paid",
		unpaidOrderId: null,
		eBookKey: "KEY",
		eBookAccessURL: "/reader",
		eBookExpireDate: "2027-01-05",
		eLearningPlatformName: "BenchPrep",
		eLearningPlatformAccessURL: "/BenchPrepSSO?prog=FRR25&part=Full",
		eLearningPlatformExpiresOnDate: "2027-01-05",
		onlineExamProviderName: "Pearson",
		onlineExamSchedulingID: "SCH1",
		onlineExamSchedulingInformationPageURL: "/info",
		OnlineExamSchedulingAccessURL: "/schedule",
		OnlineExamSchedulingExpiresOn: null,
		scheduledExamMode: "Remote",
		scheduledExamDateTime: "2026-06-01T10:00:00Z",
		scheduledExamDateTimeZone: "UTC",
		scheduledExamLocation: null,
		showTakeExam: false,
		examTakenDate: null,
		examResult: null,
		examRetakeAvailable: null,
		examRetakeAvailableDate: null,
		downloadCertificateURL: null,
		microCourseInfo: null,
		programInformation: null,
		...over,
	}
}

const fmt = (iso: string) => iso

describe("courseTypeFromSlug", () => {
	/**
	 * Apex matches an upper-cased fixed map, then the micro-course codes. A
	 * lower-cased slug matches neither and comes back 501 "Invalid Course Type".
	 */
	it("maps the three fixed slugs to what Apex matches on", () => {
		expect(courseTypeFromSlug("frr")).toBe("FRR")
		expect(courseTypeFromSlug("frr25")).toBe("FRR25")
		expect(courseTypeFromSlug("ffr")).toBe("FFR")
	})

	/** Micro codes cannot be enumerated — they arrive at runtime. */
	it("passes an unknown code through, upper-cased", () => {
		expect(courseTypeFromSlug("arpm")).toBe("ARPM")
		expect(courseTypeFromSlug("FRR_MC1")).toBe("FRR_MC1")
	})

	it("returns null for nothing", () => {
		expect(courseTypeFromSlug("   ")).toBeNull()
		expect(courseTypeFromSlug("")).toBeNull()
	})
})

describe("courseHasExam", () => {
	/**
	 * Gated on the payload, not the course code. FFR is the exam-less one today
	 * — Apex returns before it looks for a sitting — but keying off the code
	 * would leave a future exam-less course rendering an empty exam panel.
	 */
	it("is false for a payload with nothing exam-shaped on it", () => {
		expect(
			courseHasExam(
				course({
					programType: "FFR",
					examAttemptId: null,
					examResult: null,
					scheduledExamDateTime: null,
					onlineExamSchedulingID: null,
					OnlineExamSchedulingAccessURL: null,
				}),
			),
		).toBe(false)
	})

	it("is true as soon as any exam field is present", () => {
		expect(courseHasExam(course())).toBe(true)
		expect(
			courseHasExam(
				course({
					examAttemptId: null,
					scheduledExamDateTime: null,
					onlineExamSchedulingID: null,
					OnlineExamSchedulingAccessURL: null,
					examResult: "Pass",
				}),
			),
		).toBe(true)
	})
})

describe("courseRetakeCopy", () => {
	/** Both halves are resolved server-side per course; nothing is re-derived. */
	it("offers a retake when the server says one is available", () => {
		expect(courseRetakeCopy(course({ examRetakeAvailable: true }), fmt)).toBe(
			"You can retake this exam.",
		)
	})

	it("names the date when one is set but not yet reached", () => {
		expect(
			courseRetakeCopy(
				course({
					examRetakeAvailable: false,
					examRetakeAvailableDate: "2026-07-01",
				}),
				fmt,
			),
		).toContain("2026-07-01")
	})

	/** Never offered after a Pass — Apex returns before setting either field. */
	it("offers nothing when neither field is set", () => {
		expect(courseRetakeCopy(course({ examResult: "Pass" }), fmt)).toBeNull()
	})
})

describe("courseMilestones", () => {
	it("drops the exam and result stops for an exam-less course", () => {
		const steps = courseMilestones(
			course({
				programType: "FFR",
				examAttemptId: null,
				scheduledExamDateTime: null,
				onlineExamSchedulingID: null,
				OnlineExamSchedulingAccessURL: null,
			}),
		)
		expect(steps.map((s) => s.id)).toEqual(["registration", "coursework"])
	})

	it("marks everything complete once the course is Completed", () => {
		const steps = courseMilestones(course({ programState: "Completed" }))
		expect(steps.every((s) => s.status === "complete")).toBe(true)
	})

	it("blocks the first stop when the enrolment expired", () => {
		expect(courseMilestones(course({ programState: "Expired" }))[0].status).toBe(
			"blocked",
		)
	})

	it("puts the member at the right stop while enrolled", () => {
		const steps = courseMilestones(course({ programState: "AwaitingResults" }))
		expect(steps.find((s) => s.id === "exam")?.status).toBe("current")
		expect(steps.find((s) => s.id === "registration")?.status).toBe("complete")
	})
})

describe("buildCourseDetailPresentation", () => {
	/** A course has one contract and one sitting — never the part machinery. */
	it("is never two-part", () => {
		expect(buildCourseDetailPresentation(course()).isTwoPart).toBe(false)
	})

	it("produces a usable presentation for every state", () => {
		const states: CourseState[] = [
			"Unpaid",
			"Enrolled",
			"AwaitingResults",
			"ResultsAvailable",
			"Completed",
			"Expired",
		]
		for (const programState of states) {
			const view = buildCourseDetailPresentation(course({ programState }))
			expect(view.statusLabel).toBeTruthy()
			expect(view.nextStepTitle).toBeTruthy()
			expect(view.milestones.length).toBeGreaterThan(0)
		}
	})

	it("leads with the order when payment is outstanding", () => {
		const view = buildCourseDetailPresentation(
			course({ programState: "Unpaid", unpaidOrderId: "006XYZ" }),
		)
		expect(view.primaryAction).toMatchObject({
			kind: "viewOrder",
			url: "/my-account/orders/006XYZ",
		})
	})

	it("leads with the certificate once completed", () => {
		const view = buildCourseDetailPresentation(
			course({
				programState: "Completed",
				downloadCertificateURL: "/Frr25Certificate?id=003",
			}),
		)
		expect(view.primaryAction?.kind).toBe("downloadCertificate")
	})

	/**
	 * `showTakeExam` is the gate, not the URL. The scheduling link outlives the
	 * ±2 day window it is valid in, so offering it whenever it exists would send
	 * members to a provider that turns them away.
	 */
	it("offers Take Exam only when showTakeExam is true", () => {
		const closed = buildCourseDetailPresentation(course({ showTakeExam: false }))
		expect(closed.secondaryActions.some((a) => a.kind === "takeExam")).toBe(
			false,
		)
		const open = buildCourseDetailPresentation(course({ showTakeExam: true }))
		expect(open.secondaryActions.some((a) => a.kind === "takeExam")).toBe(true)
	})
})

describe("courseDisplayName", () => {
	it("prefers the catalogue name", () => {
		expect(
			courseDisplayName(
				course({
					programInformation: {
						programCode: "FRR25",
						abbrevName: "FRR",
						formalName: "Financial Risk and Regulation",
						informalName: null,
						policyURL: null,
						regLogoURL: null,
						myProgramsLogoURL: null,
						description: null,
						registrationPath: null,
					},
				}),
			),
		).toBe("Financial Risk and Regulation")
	})

	it("falls back to the known course names, then the raw code", () => {
		expect(courseDisplayName(course({ programType: "FFR" }))).toBe(
			"Foundations of Financial Risk",
		)
		expect(courseDisplayName(course({ programType: "ARPM" }))).toBe("ARPM")
	})
})
