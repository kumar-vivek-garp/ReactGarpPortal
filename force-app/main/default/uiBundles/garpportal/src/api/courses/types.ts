import type { MemberPortalEnvelope } from "@/api/account/types"
import type { MicroCourseConfig, ProgramInformation } from "@/api/programs/types"

/**
 * Types mirroring `GARP_Portal_CourseDetailService`.
 *
 * Courses are not exams. A course has one contract, one eBook, one e-learning
 * platform and at most one sitting, so none of the two-part machinery on
 * `ProgramDetail` applies — the fields here are flat rather than split across
 * `examPart1Info` / `examPart2Info`.
 *
 * The Apex collapses the legacy's four remote actions (FRR, FRR25, FFR and the
 * micro-course variant) into one, because they differ only in which contract
 * they read.
 */

/**
 * Where the member stands. Six values, and they do **not** overlap
 * `ProgramDetailState` — `Enrolled` and `AwaitingResults` have no equivalent
 * there, and `CVSubmission` / `ExamAttempt` have none here. Do not reuse that
 * union or anything branching on it.
 */
export type CourseState =
	| "Unpaid"
	| "Enrolled"
	| "AwaitingResults"
	| "ResultsAvailable"
	| "Completed"
	| "Expired"

export type CourseDetail = {
	programState: CourseState | null
	/** `FRR` | `FRR25` | `FFR` | a micro course code — as sent, not a slug. */
	programType: string | null
	programRegisteredOnDate: string | null
	programExpireDate: string | null
	examAttemptId: string | null

	paymentStatus: string | null
	/** Set only in the `Unpaid` state. */
	unpaidOrderId: string | null

	eBookKey: string | null
	eBookAccessURL: string | null
	eBookExpireDate: string | null

	/** "We Know Training (WKT)" for FRR/FFR, "BenchPrep" otherwise. */
	eLearningPlatformName: string | null
	eLearningPlatformAccessURL: string | null
	eLearningPlatformExpiresOnDate: string | null

	onlineExamProviderName: string | null
	onlineExamSchedulingID: string | null
	onlineExamSchedulingInformationPageURL: string | null
	OnlineExamSchedulingAccessURL: string | null
	OnlineExamSchedulingExpiresOn: string | null

	scheduledExamMode: string | null
	scheduledExamDateTime: string | null
	scheduledExamDateTimeZone: string | null
	scheduledExamLocation: string | null
	/**
	 * The gate for the provider link — a booked remote FRR25 sitting inside a
	 * ±2 day window. Never infer it from `OnlineExamSchedulingAccessURL` being
	 * present; the URL outlives the window.
	 */
	showTakeExam: boolean | null

	examTakenDate: string | null
	examResult: string | null
	/**
	 * Already resolved server-side per course — FRR only 30 days after the
	 * sitting, FRR25 and micro immediately, and never after a Pass. Render it;
	 * compute nothing from the course code.
	 */
	examRetakeAvailable: boolean | null
	examRetakeAvailableDate: string | null

	downloadCertificateURL: string | null

	microCourseInfo: MicroCourseConfig | null
	programInformation: ProgramInformation | null
}

/** `GET courseDetail?courseType=`. */
export type CourseView = {
	statusMessage: string | null
	statusCode: number
	courseDetailInfo: CourseDetail | null
}

export type { MemberPortalEnvelope, MicroCourseConfig, ProgramInformation }
