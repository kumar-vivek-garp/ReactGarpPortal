import { screen } from "@testing-library/react"
import { describe, expect, it } from "vitest"

import type { ExamPartInfo } from "@/api/programs"
import { ProgramExamOverview } from "@/components/molecules/program-exam-overview"
import { examPartInfo, programDetail } from "@/testing/factories/programs"
import { renderWithRouterProviders } from "@/testing/router"

const FRM = programDetail({ programType: "FRM" })

const renderPart = (
	part: ExamPartInfo,
	detail = FRM,
	partIndex: 1 | 2 = 1,
) =>
	renderWithRouterProviders(
		<ProgramExamOverview detail={detail} part={part} partIndex={partIndex} />,
	)

describe("what the card says per exam-part state", () => {
	it("names the payment deadline while an order is unpaid, and links the order", async () => {
		await renderPart(
			examPartInfo({
				examPartState: "Unpaid",
				unpaidOrderPayByDate: "2027-02-15",
				unpaidOrderId: "801-order",
			}),
		)
		expect(
			screen.getByText("Your registration is not yet paid."),
		).toBeInTheDocument()
		expect(screen.getByText("Complete payment by")).toBeInTheDocument()
		expect(screen.getByText("February 15, 2027")).toBeInTheDocument()
		// The scheduling rows do not apply yet, so they are not shown empty.
		expect(screen.queryByText("Exam site")).not.toBeInTheDocument()
		expect(
			screen.getByRole("link", { name: /View Order/ }).getAttribute("href"),
		).toContain("801-order")
	})

	it("explains a deferral, headed by the administration deferred to", async () => {
		await renderPart(
			examPartInfo({
				examPartState: "Deferred",
				examAttemptAdminName: "May 2027",
				deferredAdminName: "November 2027",
				deferredExamSetupOpenDate: "2027-06-01",
			}),
		)
		expect(
			screen.getByText("Your exam has been deferred to November 2027."),
		).toBeInTheDocument()
		expect(screen.getByText("November 2027")).toBeInTheDocument()
		expect(screen.queryByText("May 2027")).not.toBeInTheDocument()
		expect(screen.getByText("Scheduling opens")).toBeInTheDocument()
		expect(screen.getByText("June 1, 2027")).toBeInTheDocument()
	})

	it("gives the scheduling deadline while setup is open, and Edit while a deferral is", async () => {
		await renderPart(
			examPartInfo({
				examPartState: "SchedulingOpen",
				schedulingIsComplete: false,
				schedulingDeadline: "2027-04-20",
				isSchedulingOpen: true,
				isDeferralOpen: true,
			}),
		)
		expect(
			screen.getByText("Schedule before April 20, 2027."),
		).toBeInTheDocument()
		expect(screen.getByRole("link", { name: /Edit/ })).toHaveAttribute(
			"href",
			"/programs/frm/exam-setup",
		)
		expect(
			screen.getByRole("link", { name: /Schedule Exam/ }),
		).toBeInTheDocument()
	})

	it("withholds Edit when only scheduling, not a deferral, is open", async () => {
		await renderPart(
			examPartInfo({
				examPartState: "SchedulingOpen",
				isSchedulingOpen: true,
				isDeferralOpen: false,
			}),
		)
		expect(screen.queryByRole("link", { name: /Edit/ })).not.toBeInTheDocument()
	})

	it("offers Register Again only while registration is open and Part I on offer", async () => {
		const part = examPartInfo({
			examPartState: "SchedulingClosedNeverScheduled",
			examAttemptAdminName: "May 2027",
		})
		const { unmount } = await renderPart(
			part,
			programDetail({
				programType: "FRM",
				currentRegistrationIsOpen: true,
				currentRegistrationCanRegPartI: true,
				nextRegistrationOpenDate: "2027-12-01",
			}),
		)
		expect(screen.getByText("Your registration has expired.")).toBeInTheDocument()
		expect(
			screen.getByText("Register again on December 1, 2027."),
		).toBeInTheDocument()
		// No administration heads an expired registration.
		expect(screen.queryByText("May 2027")).not.toBeInTheDocument()
		expect(
			screen.getByRole("link", { name: /Register Again/ }),
		).toHaveAttribute("href", "/programs/frm/register")
		unmount()

		await renderPart(part, programDetail({ programType: "FRM", currentRegistrationIsOpen: true }))
		expect(
			screen.queryByRole("link", { name: /Register Again/ }),
		).not.toBeInTheDocument()
	})

	it("speaks each remaining state's line", async () => {
		const cases: Array<[Partial<ExamPartInfo>, string]> = [
			[
				{
					examPartState: "AwaitingSchedulingToOpen",
					schedulingAwaitingToOpenOpenDate: "2027-03-01",
				},
				"Exam setup opens March 1, 2027.",
			],
			[{ examPartState: "AwaitingSchedulingToOpen" }, "Exam setup opens soon."],
			[
				{ examPartState: "SchedulingOpen", schedulingIsComplete: true },
				"Your exam is scheduled.",
			],
			[
				{ examPartState: "SchedulingOpen", schedulingIsComplete: false },
				"Exam setup is open.",
			],
			[
				{ examPartState: "SchedulingClosedAwaitingToTakeExam" },
				"You are scheduled to sit this exam.",
			],
			[
				{ examPartState: "SchedulingClosedAwaitingResults" },
				"Your exam results are being prepared.",
			],
			[
				{
					examPartState: "SchedulingClosedAwaitingResults",
					resultsAvailableStatement: "Results out on 1 July.",
				},
				"Results out on 1 July.",
			],
		]
		for (const [overrides, text] of cases) {
			const { unmount } = await renderPart(examPartInfo(overrides))
			expect(screen.getByText(text)).toBeInTheDocument()
			unmount()
		}
	})

	it("renders nothing at all for a stale result", async () => {
		const { container } = await renderPart(
			examPartInfo({ isResultStale: true }),
		)
		expect(container).toBeEmptyDOMElement()
	})
})

describe("the facts grid", () => {
	it("shows the scheduled sitting with its zone, linking the provider once booked", async () => {
		await renderPart(
			examPartInfo({
				schedulingIsComplete: true,
				schedulingExamDateTimeSelected: "2027-05-08T09:00:00",
				schedulingExamDateTimeZoneSelected: "EST",
				schedulingExamLocationSelected: "Boston",
				schedulingExamProviderName: "Pearson VUE",
				schedulingExamAccessURL: "https://exam.example.test/launch",
			}),
		)
		expect(screen.getByText(/\(EST\)/)).toBeInTheDocument()
		expect(screen.getByText("Boston")).toBeInTheDocument()
		// FRM is always in person, whatever the stored format says.
		expect(screen.getByText("In-Person")).toBeInTheDocument()
		expect(screen.getByRole("link", { name: /Pearson VUE/ })).toHaveAttribute(
			"href",
			"https://exam.example.test/launch",
		)
	})

	it("shows honest empties before anything is booked", async () => {
		await renderPart(
			examPartInfo({ examFormat: null }),
			programDetail({ programType: "SCR" }),
		)
		expect(screen.getByText("Not available")).toBeInTheDocument()
		expect(screen.getByText("Not scheduled")).toBeInTheDocument()
		expect(screen.getByText("Not selected")).toBeInTheDocument()
		expect(screen.getByText("Not assigned")).toBeInTheDocument()
	})
})

describe("the hand-offs", () => {
	it("links the digital badge for a pass, and Take Exam with its caption, in new windows", async () => {
		const { unmount } = await renderPart(
			examPartInfo({
				examPartState: "SchedulingClosedResultsAvailable",
				result: "Pass",
				badgeURL: "https://badges.example.test/frm.png",
				badgePageURL: "https://badges.example.test/frm",
			}),
		)
		expect(
			screen.getByRole("link", { name: /Digital Badge/ }),
		).toHaveAttribute("href", "https://badges.example.test/frm")
		unmount()

		await renderPart(
			examPartInfo({
				showTakeExam: true,
				schedulingExamAccessURL: "https://exam.example.test/launch",
			}),
		)
		expect(screen.getByRole("link", { name: /Take Exam/ })).toHaveAttribute(
			"href",
			"https://exam.example.test/launch",
		)
		expect(
			screen.getByText(/check in 30 minutes prior to the appointment time/),
		).toBeInTheDocument()
	})

	it("withholds Take Exam when the flag is off, even with an access URL", async () => {
		await renderPart(
			examPartInfo({
				showTakeExam: false,
				schedulingExamAccessURL: "https://exam.example.test/launch",
			}),
		)
		expect(
			screen.queryByRole("link", { name: /Take Exam/ }),
		).not.toBeInTheDocument()
	})

	it("titles part II as Part II, and a one-part programme without any part", async () => {
		const { unmount } = await renderPart(examPartInfo(), FRM, 2)
		expect(screen.getByText("FRM Exam Part II")).toBeInTheDocument()
		unmount()

		await renderPart(examPartInfo(), programDetail({ programType: "SCR" }))
		expect(screen.getByText("SCR Exam")).toBeInTheDocument()
	})
})
