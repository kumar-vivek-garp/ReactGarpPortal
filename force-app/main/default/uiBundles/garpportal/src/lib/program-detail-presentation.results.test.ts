import { describe, expect, it, vi } from "vitest"

vi.mock("@/auth/sfdc-env", () => ({
	isLocalViteHost: vi.fn(() => false),
	getSfdcEnv: vi.fn(() => undefined),
}))

import { examPartInfo, programDetail } from "@/testing/factories/programs"
import {
	buildProgramDetailPresentation,
	certificateAction,
	cvSubmissionCopy,
	resultActions,
} from "./program-detail-presentation"
import { TAKE_EXAM_NOTE } from "./program-part-presentation"

/**
 * What the page offers once an outcome is in: the results-state buttons
 * (GarpAppv1's setExamButtonText), the certificate by programme, and the
 * work-experience copy.
 */

const result = (r: string) =>
	examPartInfo({ examPartState: "SchedulingClosedResultsAvailable", result: r })

const frm = (overrides = {}) =>
	programDetail({ programType: "FRM", programState: "ExamAttempt", ...overrides })

describe("resultActions", () => {
	it("sends a pass with Part II open to register for it, results second", () => {
		expect(
			resultActions(
				result("Pass"),
				frm({
					currentRegistrationCanAddPartII: true,
					currentRegistrationIsOpen: true,
				}),
			).map((a) => [a.kind, a.label, a.primary ?? false]),
		).toEqual([
			["registerPartII", "Register for Part II", true],
			["viewExamResults", "View Exam Results", false],
		])
	})

	it("offers a re-register to a non-pass while the window is open", () => {
		for (const r of ["Fail", "No-Show", "Not Graded"]) {
			expect(
				resultActions(result(r), frm({ currentRegistrationIsOpen: true })).map(
					(a) => a.kind,
				),
			).toEqual(["registerAgain", "viewExamResults"])
		}
	})

	it("falls back to the results page when the window is shut", () => {
		expect(
			resultActions(result("Fail"), frm({ currentRegistrationIsOpen: false })),
		).toEqual([
			expect.objectContaining({ kind: "viewExamResults", primary: true }),
		])
		expect(
			resultActions(
				result("Pass"),
				frm({ currentRegistrationCanAddPartII: true, currentRegistrationIsOpen: false }),
			).map((a) => a.kind),
		).toEqual(["viewExamResults"])
	})

	it("offers nothing at all when the result is not available", () => {
		expect(
			resultActions(result("Not Available"), frm({ currentRegistrationIsOpen: true })),
		).toEqual([])
	})

	it("leads the next step with Register for Part II", () => {
		const view = buildProgramDetailPresentation(
			frm({
				currentRegistrationCanAddPartII: true,
				currentRegistrationIsOpen: true,
				examPart1Info: result("Pass"),
			}),
		)
		expect(view.nextStepTitle).toBe("Register for Part II")
		expect(view.nextStepBody).toContain("FRM Exam Part II")
		// The manage action does not repeat what the primary already offers.
		expect(
			view.secondaryActions.filter((a) => a.kind === "registerPartII"),
		).toEqual([])
	})
})

describe("certificateAction", () => {
	it("orders a printed copy for FRM and ERP — their certificates never download", () => {
		expect(
			certificateAction(
				programDetail({
					programType: "FRM",
					certificateDownloadURL: null,
				}),
			),
		).toMatchObject({
			kind: "requestCertificate",
			label: "Request Copy of Certificate",
			url: "/Login?start=myprograms/certcheckout/frm",
			isExternal: true,
		})
		expect(
			certificateAction(programDetail({ programType: "ERP" }))?.url,
		).toContain("certcheckout/erp")
	})

	it("downloads for the one-part programmes, only when the org supplies a file", () => {
		expect(
			certificateAction(
				programDetail({
					programType: "SCR",
					certificateDownloadURL: "https://cert.example/scr.pdf",
				}),
			),
		).toMatchObject({ kind: "downloadCertificate", newWindow: true })
		expect(
			certificateAction(programDetail({ programType: "RAIJ" })),
		).toBeNull()
	})

	it("words the certified next step around requesting, for FRM", () => {
		const view = buildProgramDetailPresentation(
			programDetail({ programType: "FRM", programState: "Completed" }),
		)
		expect(view.primaryAction?.kind).toBe("requestCertificate")
		expect(view.nextStepBody).toMatch(/^Request a printed copy/)
	})
})

describe("cvSubmissionCopy", () => {
	it("keys heading and body on the review status", () => {
		expect(
			cvSubmissionCopy(programDetail({ programType: "FRM", cvStatus: "Ready For Review" })),
		).toMatchObject({ heading: "Submission received", notes: [] })
		expect(
			cvSubmissionCopy(programDetail({ programType: "FRM", cvStatus: "Failed Review" })),
		).toMatchObject({ heading: "Submission denied" })
		expect(
			cvSubmissionCopy(programDetail({ programType: "FRM", cvStatus: "Initial" })),
		).toMatchObject({ heading: "Submission required" })
	})

	it("warns about the 10-year window in the programme's own words", () => {
		const frmNote = cvSubmissionCopy(
			programDetail({ programType: "FRM", cvStatus: null }),
		).notes[0]
		expect(frmNote).toContain("re-enroll in the FRM Program")
		const erp = cvSubmissionCopy(programDetail({ programType: "ERP", cvStatus: null }))
		expect(erp.notes[0]).toContain("their program will expire")
		expect(erp.body).toMatch(/^Before you can become an ERP/)
	})

	it("carries into the CVSubmission next step, with the notes", () => {
		const view = buildProgramDetailPresentation(
			programDetail({ programType: "FRM", programState: "CVSubmission", cvStatus: null }),
		)
		expect(view.nextStepTitle).toBe("Submission required")
		expect(view.notes).toHaveLength(1)
	})
})

describe("the Take Exam caption", () => {
	it("is noted only while Take Exam is on offer", () => {
		const view = buildProgramDetailPresentation(
			frm({
				examPart1Info: examPartInfo({
					examPartState: "SchedulingClosedAwaitingToTakeExam",
					showTakeExam: true,
					schedulingExamAccessURL: "/PearsonVue_SSO?id=a1",
				}),
			}),
		)
		expect(view.notes).toEqual([TAKE_EXAM_NOTE])
		expect(buildProgramDetailPresentation(frm()).notes).toEqual([])
	})
})
