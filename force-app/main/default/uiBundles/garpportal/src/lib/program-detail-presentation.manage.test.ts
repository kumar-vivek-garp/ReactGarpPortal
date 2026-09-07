import { describe, expect, it, vi } from "vitest"

vi.mock("@/auth/sfdc-env", () => ({
	isLocalViteHost: vi.fn(() => false),
	getSfdcEnv: vi.fn(() => undefined),
}))

import { examPartInfo, programDetail } from "@/testing/factories/programs"
import {
	activeExamPart,
	buildProgramDetailPresentation,
	manageExamActions,
	partActions,
	pendingExamChange,
	showIdInfo,
	visibleExamParts,
} from "./program-detail-presentation"

/**
 * The page-level gates GarpAppv1 reads and this page did not: the unpaid
 * exam change, the Manage-Your-Exam actions, which parts render, and when
 * identity is shown.
 */

const frm = (overrides = {}) =>
	programDetail({
		programType: "FRM",
		programState: "ExamAttempt",
		...overrides,
	})

describe("an unpaid exam change", () => {
	const blocked = examPartInfo({
		examPartState: "SchedulingOpen",
		isSchedulingOpen: true,
		isDeferralOpen: true,
		showTakeExam: true,
		schedulingExamAccessURL: "/PearsonVue_SSO?id=a1",
		schedulingDeadline: "2027-04-20",
		unpaidDeferralOrderId: "006-change",
	})

	it("offers only the pending order on that sitting, whatever else is open", () => {
		expect(partActions(blocked, frm())).toEqual([
			expect.objectContaining({
				kind: "viewPendingOrder",
				label: "View Pending Order",
				url: "/my-account/orders/006-change",
				primary: true,
			}),
		])
	})

	it("turns the next step into the warning, with the pay-by date", () => {
		const view = buildProgramDetailPresentation(
			frm({ examPart1Info: blocked, isAnyPartDeferalOpen: true }),
		)
		expect(view.nextStepTone).toBe("danger")
		expect(view.nextStepTitle).toBe("You have an unpaid exam change")
		expect(view.nextStepBody).toBe(
			"You must pay before April 20, 2027 to complete this request.",
		)
		expect(view.primaryAction?.kind).toBe("viewPendingOrder")
		// No deferral, no Part II — a second change cannot be requested.
		expect(view.secondaryActions).toEqual([])
		expect(view.notes).toEqual([])
	})

	it("is the part the hero summarises, even when it is Part II", () => {
		const detail = frm({
			examPart1Info: examPartInfo({
				examPartState: "SchedulingClosedResultsAvailable",
				result: "Pass",
			}),
			examPart2Info: blocked,
		})
		expect(pendingExamChange(detail)?.orderId).toBe("006-change")
		expect(activeExamPart(detail)).toBe(blocked)
	})
})

describe("manageExamActions", () => {
	it("offers a deferral while one is open, unless the wizard is already offered", () => {
		const detail = frm({ isAnyPartDeferalOpen: true })
		expect(manageExamActions(detail)).toEqual([
			expect.objectContaining({
				kind: "deferExam",
				label: "Defer Exam",
				url: "/programs/frm/exam-setup",
			}),
		])
		expect(
			manageExamActions(detail, [
				{
					kind: "schedule",
					label: "Schedule Exam",
					url: "/programs/frm/exam-setup",
					isExternal: false,
				},
			]),
		).toEqual([])
	})

	it("offers Part II only when the server allows it AND registration is open", () => {
		expect(
			manageExamActions(
				frm({
					currentRegistrationCanAddPartII: true,
					currentRegistrationIsOpen: true,
				}),
			),
		).toEqual([
			expect.objectContaining({
				kind: "registerPartII",
				label: "Add FRM Part II",
				url: "/programs/frm/register",
				isExternal: false,
			}),
		])
		expect(
			manageExamActions(
				frm({
					currentRegistrationCanAddPartII: true,
					currentRegistrationIsOpen: false,
				}),
			),
		).toEqual([])
	})

	it("stands down entirely while an exam change is unpaid", () => {
		expect(
			manageExamActions(
				frm({
					isAnyPartDeferalOpen: true,
					currentRegistrationCanAddPartII: true,
					currentRegistrationIsOpen: true,
					examPart1Info: examPartInfo({ unpaidDeferralOrderId: "006" }),
				}),
			),
		).toEqual([])
	})

	it("joins the next step, leading it when the sitting offers nothing else", () => {
		const view = buildProgramDetailPresentation(
			frm({
				isAnyPartDeferalOpen: true,
				currentRegistrationCanAddPartII: true,
				currentRegistrationIsOpen: true,
				examPart1Info: examPartInfo({
					examPartState: "SchedulingClosedAwaitingToTakeExam",
				}),
			}),
		)
		expect(view.primaryAction?.kind).toBe("deferExam")
		expect(view.nextStepTitle).toBe("Defer your exam")
		expect(view.secondaryActions.map((a) => a.kind)).toEqual(["registerPartII"])
	})

	it("stays secondary behind a scheduling action", () => {
		const view = buildProgramDetailPresentation(
			frm({
				currentRegistrationCanAddPartII: true,
				currentRegistrationIsOpen: true,
				examPart1Info: examPartInfo({
					examPartState: "SchedulingOpen",
					isSchedulingOpen: true,
				}),
			}),
		)
		expect(view.primaryAction?.kind).toBe("schedule")
		expect(view.secondaryActions.map((a) => a.kind)).toEqual(["registerPartII"])
	})
})

describe("Register Again after never scheduling", () => {
	const expired = examPartInfo({
		examPartState: "SchedulingClosedNeverScheduled",
	})

	it("needs the window open AND Part I still on offer", () => {
		expect(
			partActions(
				expired,
				frm({
					currentRegistrationIsOpen: true,
					currentRegistrationCanRegPartI: true,
				}),
			),
		).toEqual([
			expect.objectContaining({
				kind: "registerAgain",
				url: "/programs/frm/register",
				isExternal: false,
			}),
		])
		expect(
			partActions(
				expired,
				frm({ currentRegistrationIsOpen: true, currentRegistrationCanRegPartI: null }),
			),
		).toEqual([])
	})
})

describe("visibleExamParts", () => {
	const p1 = examPartInfo({ examAttemptId: "p1" })
	const p2 = examPartInfo({ examAttemptId: "p2" })

	it("renders both FRM parts, in order", () => {
		expect(
			visibleExamParts(frm({ examPart1Info: p1, examPart2Info: p2 })).map(
				(v) => v.partIndex,
			),
		).toEqual([1, 2])
	})

	it("never renders ERP Part I — it is not sat through this portal", () => {
		const parts = visibleExamParts(
			programDetail({ programType: "ERP", examPart1Info: p1, examPart2Info: p2 }),
		)
		expect(parts.map((v) => v.partIndex)).toEqual([2])
		expect(
			activeExamPart(
				programDetail({ programType: "ERP", examPart1Info: p1, examPart2Info: p2 }),
			),
		).toBe(p2)
	})

	it("drops a stale part and a Part II on a one-part programme", () => {
		expect(
			visibleExamParts(
				frm({
					examPart1Info: examPartInfo({ isResultStale: true }),
					examPart2Info: p2,
				}),
			).map((v) => v.partIndex),
		).toEqual([2])
		expect(
			visibleExamParts(
				programDetail({ programType: "SCR", examPart1Info: p1, examPart2Info: p2 }),
			).map((v) => v.partIndex),
		).toEqual([1])
	})
})

describe("showIdInfo", () => {
	it("shows identity while a sitting can change or is booked and waiting", () => {
		expect(showIdInfo(frm({ isAnyPartDeferalOpen: true }))).toBe(true)
		expect(showIdInfo(frm({ isAnyPartSchedulingOpen: true }))).toBe(true)
		expect(
			showIdInfo(
				frm({
					examPart2Info: examPartInfo({
						examPartState: "SchedulingClosedAwaitingToTakeExam",
					}),
				}),
			),
		).toBe(true)
	})

	it("hides it otherwise — after results, or with nothing in play", () => {
		expect(
			showIdInfo(
				frm({
					examPart1Info: examPartInfo({
						examPartState: "SchedulingClosedResultsAvailable",
					}),
				}),
			),
		).toBe(false)
		expect(showIdInfo(frm())).toBe(false)
	})
})
