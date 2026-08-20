import { afterEach, describe, expect, it, vi } from "vitest"

vi.mock("@/auth/sfdc-env", () => ({
	isLocalViteHost: vi.fn(() => false),
	getSfdcEnv: vi.fn(() => undefined),
}))

vi.mock("@/lib/resolve-portal-asset-url", () => ({
	resolvePortalAssetUrl: vi.fn((url: string) => url),
}))

import type { ExamPartInfo, ProgramDetail } from "@/api/programs"
import {
	activeExamPart,
	buildProgramDetailPresentation,
	displayProgramName,
	examPartTitle,
	resultCopy,
} from "./program-detail-presentation"

function basePart(
	overrides: Partial<ExamPartInfo> = {},
): ExamPartInfo {
	return {
		examPartState: "SchedulingOpen",
		examAttemptAdminName: "October 2026",
		examAttemptId: "a1a",
		lastDateforADA: null,
		examFormat: null,
		unpaidOrderId: null,
		unpaidOrderPayByDate: null,
		deferredAdminName: null,
		deferredExamSetupOpenDate: null,
		isDeferralOpen: true,
		schedulingAwaitingToOpenOpenDate: null,
		schedulingIsComplete: false,
		isSchedulingOpen: true,
		schedulingDeadline: "2026-11-07",
		schedulingExamDateTimeSelected: null,
		schedulingExamDateTimeZoneSelected: null,
		schedulingExamLocationSelected: null,
		schedulingExamProviderName: "Pearson",
		showTakeExam: false,
		schedulingExamAccessURL: "/PearsonVue_SSO?id=a1a",
		unpaidDeferralOrderId: null,
		resultsAvailableDateTime: null,
		resultsAvailableStatement: null,
		result: null,
		isResultStale: false,
		badgeURL: null,
		badgePageURL: null,
		...overrides,
	}
}

function baseDetail(overrides: Partial<ProgramDetail> = {}): ProgramDetail {
	return {
		statusMessage: "Success",
		statusCode: 200,
		programState: "ExamAttempt",
		programType: "RiskAI",
		programCompletedDate: null,
		certificateDownloadURL: null,
		digitalBadgheURL: null,
		isAnyPartSchedulingOpen: true,
		isAnyPartDeferalOpen: true,
		isAnyPartDeferred: false,
		programInformation: {
			programCode: "riskai",
			abbrevName: "RAI",
			formalName: "Risk and AI (RAI<sup>&trade;</sup>)",
			informalName: "Risk AI Program",
			policyURL: null,
			regLogoURL: null,
			myProgramsLogoURL: "https://example.com/RAI.webp",
			description: "AI risk certificate.",
			registrationPath: "rai",
		},
		examPart1Info: basePart(),
		examPart2Info: null,
		currentRegistrationIsOpen: true,
		currentRegistrationAdminName: "October 2026",
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
		isOSTACandidate: false,
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

afterEach(() => {
	vi.clearAllMocks()
})

describe("displayProgramName", () => {
	it("strips formalName HTML entities", () => {
		expect(displayProgramName(baseDetail())).toBe("Risk and AI (RAI™)")
	})
})

describe("resultCopy", () => {
	it("maps known results", () => {
		expect(resultCopy("Pass")).toContain("certified")
		expect(resultCopy("Fail")).toContain("did not meet")
	})

	it("falls back to raw result", () => {
		expect(resultCopy("Custom")).toBe("Custom")
	})
})

describe("activeExamPart", () => {
	it("skips stale part 1 and uses part 2", () => {
		const detail = baseDetail({
			programType: "FRM",
			examPart1Info: basePart({ isResultStale: true }),
			examPart2Info: basePart({
				examAttemptAdminName: "May 2027",
				examPartState: "SchedulingOpen",
			}),
		})
		expect(activeExamPart(detail)?.examAttemptAdminName).toBe("May 2027")
	})
})

describe("examPartTitle", () => {
	it("labels FRM parts", () => {
		const detail = baseDetail({ programType: "FRM" })
		expect(examPartTitle(detail, 1)).toBe("FRM Exam Part I")
		expect(examPartTitle(detail, 2)).toBe("FRM Exam Part II")
	})

	it("uses single exam title for SCR", () => {
		expect(examPartTitle(baseDetail({ programType: "SCR" }), 1)).toBe(
			"SCR Exam",
		)
	})
})

describe("buildProgramDetailPresentation", () => {
	it("SchedulingOpen → Schedule Exam primary CTA", () => {
		const view = buildProgramDetailPresentation(baseDetail())
		expect(view.statusLabel).toBe("Scheduling open")
		expect(view.statusTone).toBe("info")
		expect(view.primaryAction?.kind).toBe("schedule")
		expect(view.primaryAction?.label).toBe("Schedule Exam")
		expect(view.milestones.find((m) => m.id === "scheduling")?.status).toBe(
			"current",
		)
	})

	it("SchedulingOpen complete → Exam Setup", () => {
		const view = buildProgramDetailPresentation(
			baseDetail({
				examPart1Info: basePart({ schedulingIsComplete: true }),
			}),
		)
		expect(view.primaryAction?.kind).toBe("setup")
		expect(view.statusLabel).toBe("Exam scheduled")
	})

	it("showTakeExam wins over schedule", () => {
		const view = buildProgramDetailPresentation(
			baseDetail({
				examPart1Info: basePart({
					examPartState: "SchedulingClosedAwaitingToTakeExam",
					isSchedulingOpen: false,
					showTakeExam: true,
					schedulingExamAccessURL: "/PearsonVue_SSO?id=x",
				}),
			}),
		)
		expect(view.primaryAction?.kind).toBe("takeExam")
		expect(view.statusLabel).toBe("Ready to take exam")
	})

	it("Unpaid → View Order primary", () => {
		const view = buildProgramDetailPresentation(
			baseDetail({
				examPart1Info: basePart({
					examPartState: "Unpaid",
					isSchedulingOpen: false,
					unpaidOrderId: "801xxx",
					unpaidOrderPayByDate: "2026-09-01",
				}),
			}),
		)
		expect(view.statusTone).toBe("warning")
		expect(view.primaryAction?.kind).toBe("viewOrder")
		expect(view.statusSummary).toContain("Pay by")
	})

	it("Deferred → setup-open messaging", () => {
		const view = buildProgramDetailPresentation(
			baseDetail({
				examPart1Info: basePart({
					examPartState: "Deferred",
					isSchedulingOpen: false,
					deferredAdminName: "April 2027",
					deferredExamSetupOpenDate: "2027-01-15",
				}),
			}),
		)
		expect(view.statusLabel).toBe("Deferred")
		expect(view.statusSummary).toContain("April 2027")
		expect(view.statusSummary).toContain("January")
	})

	it("SchedulingClosedNeverScheduled with open reg → Register Again", () => {
		const view = buildProgramDetailPresentation(
			baseDetail({
				programType: "SCR",
				currentRegistrationIsOpen: true,
				examPart1Info: basePart({
					examPartState: "SchedulingClosedNeverScheduled",
					isSchedulingOpen: false,
					isDeferralOpen: false,
				}),
			}),
		)
		expect(view.statusTone).toBe("danger")
		expect(view.primaryAction?.kind).toBe("registerAgain")
		expect(view.milestones[0]?.status).toBe("blocked")
	})

	it("Awaiting results uses statement", () => {
		const view = buildProgramDetailPresentation(
			baseDetail({
				examPart1Info: basePart({
					examPartState: "SchedulingClosedAwaitingResults",
					isSchedulingOpen: false,
					resultsAvailableStatement: "Results on May 1.",
				}),
			}),
		)
		expect(view.statusLabel).toBe("Awaiting results")
		expect(view.statusSummary).toBe("Results on May 1.")
	})

	it("Results available with Pass tone", () => {
		const view = buildProgramDetailPresentation(
			baseDetail({
				examPart1Info: basePart({
					examPartState: "SchedulingClosedResultsAvailable",
					isSchedulingOpen: false,
					result: "Pass",
					badgePageURL: "https://badge.example/x",
				}),
			}),
		)
		expect(view.statusTone).toBe("success")
		expect(view.primaryAction?.kind).toBe("viewExamResults")
		expect(view.primaryAction?.url).toBe("/programs/riskai/results")
		expect(view.secondaryActions.map((a) => a.kind)).toContain(
			"digitalBadge",
		)
	})

	it("Completed → certificate / badge / directory", () => {
		const view = buildProgramDetailPresentation(
			baseDetail({
				programState: "Completed",
				programCompletedDate: "2025-06-01",
				certificateDownloadURL: "https://cert.example/a",
				digitalBadgheURL: "https://badge.example/b",
				examPart1Info: null,
			}),
		)
		expect(view.statusLabel).toBe("Certified")
		expect(view.primaryAction?.kind).toBe("downloadCertificate")
		expect(view.secondaryActions.map((a) => a.kind)).toEqual([
			"digitalBadge",
			"directory",
			"viewExamResults",
		])
		expect(
			view.milestones.every((m) => m.status === "complete"),
		).toBe(true)
	})

	it("CVSubmission has no fabricated CTA", () => {
		const view = buildProgramDetailPresentation(
			baseDetail({
				programState: "CVSubmission",
				cvStatus: "Pending Review",
				examPart1Info: null,
			}),
		)
		expect(view.primaryAction).toBeNull()
		expect(view.statusLabel).toBe("Work experience")
		expect(view.nextStepBody).toContain("Pending Review")
	})

	it("EnrollmentExpired with open registration", () => {
		const view = buildProgramDetailPresentation(
			baseDetail({
				programState: "EnrollmentExpired",
				currentRegistrationIsOpen: true,
				examPart1Info: null,
			}),
		)
		expect(view.primaryAction?.kind).toBe("registerAgain")
		expect(view.statusTone).toBe("danger")
	})

	it("skips CTAs when stale-only parts", () => {
		const view = buildProgramDetailPresentation(
			baseDetail({
				examPart1Info: basePart({ isResultStale: true }),
				examPart2Info: null,
			}),
		)
		expect(view.primaryAction).toBeNull()
		expect(view.statusSummary).toContain("No exam attempt")
	})
})
