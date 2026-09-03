/**
 * Typed fixtures for the program-detail contract (`api/programs/types.ts`).
 * Typed against the api types so a contract drift breaks compilation,
 * not just runtime.
 */

import type {
	ExamDeadline,
	ExamPartInfo,
	ExamResources,
	ProgramDetail,
	ProgramExamNotification,
} from "@/api/programs"

export function examPartInfo(
	overrides: Partial<ExamPartInfo> = {},
): ExamPartInfo {
	return {
		examPartState: "SchedulingOpen",
		examAttemptAdminName: "May 2027",
		examAttemptId: "attempt-1",
		lastDateforADA: null,
		examFormat: "Computer-based",
		unpaidOrderId: null,
		unpaidOrderPayByDate: null,
		deferredAdminName: null,
		deferredExamSetupOpenDate: null,
		isDeferralOpen: null,
		schedulingAwaitingToOpenOpenDate: null,
		schedulingIsComplete: null,
		isSchedulingOpen: null,
		schedulingDeadline: null,
		schedulingExamDateTimeSelected: null,
		schedulingExamDateTimeZoneSelected: null,
		schedulingExamLocationSelected: null,
		schedulingExamProviderName: null,
		showTakeExam: null,
		schedulingExamAccessURL: null,
		unpaidDeferralOrderId: null,
		resultsAvailableDateTime: null,
		resultsAvailableStatement: null,
		result: null,
		isResultStale: null,
		badgeURL: null,
		badgePageURL: null,
		...overrides,
	}
}

export function examDeadline(
	overrides: Partial<ExamDeadline> = {},
): ExamDeadline {
	return {
		examMonth: "May",
		examYear: "2027",
		ADADeadline: null,
		deferalDeadline: null,
		schedulingDeadline: null,
		...overrides,
	}
}

export function examResources(
	overrides: Partial<ExamResources> = {},
): ExamResources {
	return {
		eBookItems: null,
		eBookExpireDate: null,
		eBookProviderName: null,
		eLearningPlatformAccessURL: null,
		eLearningPlatformName: null,
		ADAFormAccessURL: null,
		IsOptedIntoEPP: null,
		...overrides,
	}
}

export function programExamNotification(
	overrides: Partial<ProgramExamNotification> = {},
): ProgramExamNotification {
	return {
		notificationTitle: "Exam window update",
		notificationDetails: "Your exam window has moved.",
		notificationDate: "2027-01-15",
		...overrides,
	}
}

export function programDetail(
	overrides: Partial<ProgramDetail> = {},
): ProgramDetail {
	return {
		statusMessage: null,
		statusCode: 200,
		programState: null,
		programType: "frm",
		programCompletedDate: null,
		certificateDownloadURL: null,
		digitalBadgheURL: null,
		isAnyPartSchedulingOpen: null,
		isAnyPartDeferalOpen: null,
		isAnyPartDeferred: null,
		programInformation: null,
		examPart1Info: null,
		examPart2Info: null,
		currentRegistrationIsOpen: null,
		currentRegistrationAdminName: null,
		nextRegistrationAdminName: null,
		nextRegistrationOpenDate: null,
		currentRegistrationCanRegPartI: null,
		currentRegistrationCanAddPartII: null,
		cvStatus: null,
		examResources: null,
		IDName: null,
		IDType: null,
		IDNumber: null,
		IDLocation: null,
		IDExpireDate: null,
		phoneCode: null,
		phoneNumber: null,
		isOSTACandidate: null,
		OSTANameInChinese: null,
		OSTADateOfBirth: null,
		OSTAGender: null,
		OSTAPhoneNumber: null,
		OSTAWorkingStatus: null,
		OSTACompany: null,
		OSTAEducationalStatus: null,
		OSTAEducationalSchool: null,
		OSTAEducationalProgram: null,
		examDeadlines: null,
		examNotifications: null,
		...overrides,
	}
}
