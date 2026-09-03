import type {
	ExamAdmin,
	ExamSetupAuthorizeResult,
	ExamSetupIdInfo,
	ExamSetupIdSaveResult,
	ExamSetupView,
	ExamSite,
} from "@/api/exam-setup"

/**
 * `GARP_Portal_ExamSetupService` fixtures. Defaults model a single-part
 * programme whose member sits the May administration in London, with an ID
 * already on file (`idNumber` non-blank) so the save button starts enabled.
 * Tests override the one aspect under test.
 */

export function examSite(overrides: Partial<ExamSite> = {}): ExamSite {
	return { id: "site-london", name: "London", isSelected: false, ...overrides }
}

export function examAdmin(overrides: Partial<ExamAdmin> = {}): ExamAdmin {
	return {
		id: "admin-may",
		name: "May 2026",
		isSelected: false,
		examSites: [examSite()],
		...overrides,
	}
}

/** Two administrations, the member sitting May in London today. */
export function examAdmins(): ExamAdmin[] {
	return [
		examAdmin({
			isSelected: true,
			examSites: [
				examSite({ isSelected: true }),
				examSite({ id: "site-paris", name: "Paris" }),
			],
		}),
		examAdmin({
			id: "admin-nov",
			name: "November 2026",
			examSites: [examSite({ id: "site-berlin", name: "Berlin" })],
		}),
	]
}

export function examSetupIdInfo(
	overrides: Partial<ExamSetupIdInfo> = {},
): ExamSetupIdInfo {
	return {
		isOSTA: false,
		isIDRequired: false,
		idName: "Ada Lovelace",
		/** Last five in the clear — non-blank means "ID on file". */
		idNumber: "45678",
		idType: "Passport",
		idExpireDate: "2030-01-01",
		mobilePhoneLocation: "United States (+1)",
		mobilePhoneNumber: "5551234",
		ostaIDLocation: null,
		ostaGender: null,
		ostaFullNameInChinese: null,
		ostaDateOfBirth: null,
		ostaPhoneNumber: null,
		ostaCurrentWorkingStatus: null,
		ostaCompany: null,
		ostaCurrentSchoolStatus: null,
		ostaSchool: null,
		ostaDegreeProgramName: null,
		mobilePhoneLocations: ["United States (+1)", "United Kingdom (+44)"],
		...overrides,
	}
}

export function examSetupView(
	overrides: Partial<ExamSetupView> = {},
): ExamSetupView {
	return {
		statusMessage: null,
		statusCode: 200,
		allowAdminModPart1: true,
		allowAdminModPart2: true,
		examPart1SelectionInfo: examAdmins(),
		examPart2SelectionInfo: [],
		idInfo: examSetupIdInfo(),
		...overrides,
	}
}

export function examSetupSaveResult(
	overrides: Partial<ExamSetupIdSaveResult> = {},
): ExamSetupIdSaveResult {
	return {
		statusMessage: null,
		statusCode: 200,
		nextScreen: "Setup Complete",
		paymentRequired: false,
		schedulingRequired: false,
		examModificationId: null,
		...overrides,
	}
}

export function examSetupAuthorizeResult(
	overrides: Partial<ExamSetupAuthorizeResult> = {},
): ExamSetupAuthorizeResult {
	return {
		statusMessage: null,
		statusCode: 200,
		schedulingRequired: true,
		isAuthorized: false,
		examScheduleExamURLPart1: null,
		examScheduleExamURLPart2: null,
		...overrides,
	}
}
