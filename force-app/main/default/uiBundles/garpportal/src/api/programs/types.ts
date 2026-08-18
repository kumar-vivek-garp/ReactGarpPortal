import type { MemberPortalEnvelope } from "@/api/account/types"

/** Marketing catalogue entry from `GARP_Portal_ProgramsService.ProgramInformation`. */
export type ProgramInformation = {
	programCode: string | null
	abbrevName: string | null
	formalName: string | null
	informalName: string | null
	policyURL: string | null
	regLogoURL: string | null
	myProgramsLogoURL: string | null
	description: string | null
	registrationPath: string | null
}

/** In-progress program. Listing does not use exam attempt rows. */
export type EnrolledProgram = {
	programType: string
	adminPartIName: string | null
	adminPartIIName: string | null
	programInformation: ProgramInformation | null
}

export type CompletedProgram = {
	programType: string
	programInformation: ProgramInformation | null
}

export type OtherProgram = {
	programType: string
	isRegistrationOpen: boolean
	/** ISO date (`yyyy-MM-dd`) when closed. */
	nextRegistrationOpenDate: string | null
	nextRegistrationOpenAdminName: string | null
	isMicroCourse: boolean
	programInformation: ProgramInformation | null
}

/** Typed for the payload; listing cards do not render this map. */
export type MicroCourseConfig = {
	name: string | null
	courseCode: string | null
	description: string | null
	abbrevName: string | null
	formalName: string | null
	policyURL: string | null
	registrationLogoURL: string | null
	myProgramsLogoURL: string | null
	programType: string | null
	programRecordTypeAPIName: string | null
}

/** `GET /memberportal/programs` view (`GARP_Portal_ProgramsService.ProgramsView`). */
export type ProgramsView = {
	statusMessage: string | null
	statusCode: number
	enrolledPrograms: EnrolledProgram[]
	completedPrograms: CompletedProgram[]
	otherPrograms: OtherProgram[]
	hasCPDProgram: boolean
	hasExamResults: boolean
	microCourseConfig: Record<string, MicroCourseConfig> | null
}

/** Apex `programState` values on `ProgramDetail`. */
export type ProgramDetailState =
	| "Completed"
	| "EnrollmentExpired"
	| "CVSubmission"
	| "ExamAttempt"
	| string

/** Apex `examPartState` values on `ExamPartInfo` (plus unknown for resilience). */
export type ExamPartState =
	| "Unpaid"
	| "Deferred"
	| "AwaitingSchedulingToOpen"
	| "SchedulingOpen"
	| "SchedulingClosedNeverScheduled"
	| "SchedulingClosedAwaitingToTakeExam"
	| "SchedulingClosedAwaitingResults"
	| "SchedulingClosedResultsAvailable"
	| string

/** One exam part card (`GARP_Portal_ProgramDetailService.ExamPartInfo`). */
export type ExamPartInfo = {
	examPartState: ExamPartState | null
	examAttemptAdminName: string | null
	examAttemptId: string | null
	lastDateforADA: string | null
	examFormat: string | null
	unpaidOrderId: string | null
	unpaidOrderPayByDate: string | null
	deferredAdminName: string | null
	deferredExamSetupOpenDate: string | null
	isDeferralOpen: boolean | null
	schedulingAwaitingToOpenOpenDate: string | null
	schedulingIsComplete: boolean | null
	isSchedulingOpen: boolean | null
	schedulingDeadline: string | null
	schedulingExamDateTimeSelected: string | null
	schedulingExamDateTimeZoneSelected: string | null
	schedulingExamLocationSelected: string | null
	schedulingExamProviderName: string | null
	showTakeExam: boolean | null
	schedulingExamAccessURL: string | null
	unpaidDeferralOrderId: string | null
	resultsAvailableDateTime: string | null
	resultsAvailableStatement: string | null
	result: string | null
	isResultStale: boolean | null
	badgeURL: string | null
	badgePageURL: string | null
}

/** Deadline rail row (`GARP_Portal_ProgramDetailService.ExamDeadline`). */
export type ExamDeadline = {
	examMonth: string | null
	examYear: string | null
	ADADeadline: string | null
	/** Apex typo — keep as returned. */
	deferalDeadline: string | null
	schedulingDeadline: string | null
}

/**
 * Exam resources rail (`GARP_Portal_ProgramDetailService.ExamResources`).
 * eBook / BenchPrep / ADA URLs may be null until study-materials Apex is ported.
 */
export type ExamResources = {
	eBookItems: unknown[] | null
	eBookExpireDate: string | null
	eBookProviderName: string | null
	eLearningPlatformAccessURL: string | null
	eLearningPlatformName: string | null
	ADAFormAccessURL: string | null
	IsOptedIntoEPP: boolean | null
}

/** Notification row nested on detail (same shape as notifications action). */
export type ProgramExamNotification = {
	notificationTitle: string | null
	notificationDetails: string | null
	notificationDate: string | null
}

/** `GET /memberportal/programDetail` inner payload. */
export type ProgramDetail = {
	statusMessage: string | null
	statusCode: number | null
	programState: ProgramDetailState | null
	programType: string | null
	programCompletedDate: string | null
	certificateDownloadURL: string | null
	/** Apex typo — keep as returned. */
	digitalBadgheURL: string | null
	isAnyPartSchedulingOpen: boolean | null
	isAnyPartDeferalOpen: boolean | null
	isAnyPartDeferred: boolean | null
	programInformation: ProgramInformation | null
	examPart1Info: ExamPartInfo | null
	examPart2Info: ExamPartInfo | null
	currentRegistrationIsOpen: boolean | null
	currentRegistrationAdminName: string | null
	nextRegistrationAdminName: string | null
	nextRegistrationOpenDate: string | null
	currentRegistrationCanRegPartI: boolean | null
	currentRegistrationCanAddPartII: boolean | null
	cvStatus: string | null
	examResources: ExamResources | null
	IDName: string | null
	IDType: string | null
	IDNumber: string | null
	IDLocation: string | null
	IDExpireDate: string | null
	phoneCode: string | null
	phoneNumber: string | null
	isOSTACandidate: boolean | null
	OSTANameInChinese: string | null
	OSTADateOfBirth: string | null
	OSTAGender: string | null
	OSTAPhoneNumber: string | null
	OSTAWorkingStatus: string | null
	OSTACompany: string | null
	OSTAEducationalStatus: string | null
	OSTAEducationalSchool: string | null
	OSTAEducationalProgram: string | null
	examDeadlines: ExamDeadline[] | null
	examNotifications: ProgramExamNotification[] | null
}

/** `GET /memberportal/programDetail` view (`DetailView`). */
export type ProgramDetailView = {
	statusMessage: string | null
	statusCode: number
	programsDetailInfo: ProgramDetail | null
}

export type { MemberPortalEnvelope }
