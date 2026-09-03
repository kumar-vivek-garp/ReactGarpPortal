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
			screen.getByText("Payment due by February 15, 2027."),
		).toBeInTheDocument()
		expect(
			screen.getByRole("link", { name: /View Order/ }).getAttribute("href"),
		).toContain("801-order")
	})

	it("explains a deferral, with the target administration and reopen date", async () => {
		await renderPart(
			examPartInfo({
				examPartState: "Deferred",
				deferredAdminName: "November 2027",
				deferredExamSetupOpenDate: "2027-06-01",
			}),
		)
		expect(
			screen.getByText("Deferred to November 2027. Setup opens June 1, 2027."),
		).toBeInTheDocument()
	})

	it("gives the scheduling deadline while setup is open and unfinished", async () => {
		await renderPart(
			examPartInfo({
				examPartState: "SchedulingOpen",
				schedulingIsComplete: false,
				schedulingDeadline: "2027-04-20",
				isSchedulingOpen: true,
			}),
		)
		expect(
			screen.getByText("Schedule before April 20, 2027."),
		).toBeInTheDocument()
		// Setup being open earns the Edit affordance.
		expect(screen.getByRole("link", { name: /Edit/ })).toHaveAttribute(
			"href",
			"/programs/frm/exam-setup",
		)
	})

	it("offers Register Again only while registration is open", async () => {
		const part = examPartInfo({
			examPartState: "SchedulingClosedNeverScheduled",
		})
		const { unmount } = await renderPart(
			part,
			programDetail({
				programType: "FRM",
				currentRegistrationIsOpen: true,
			}),
		)
		expect(
			screen.getByText(
				"Your registration expired before a sitting was scheduled.",
			),
		).toBeInTheDocument()
		expect(
			screen.getByRole("link", { name: /Register Again/ }),
		).toBeInTheDocument()
		unmount()

		await renderPart(part, FRM)
		expect(
			screen.queryByRole("link", { name: /Register Again/ }),
		).not.toBeInTheDocument()
	})

	it("speaks each remaining state's line", async () => {
		const cases: Array<[Partial<ExamPartInfo>, string | RegExp]> = [
			[
				{ examPartState: "Unpaid", unpaidOrderPayByDate: null },
				"Your registration is not yet paid.",
			],
			[
				{
					examPartState: "AwaitingSchedulingToOpen",
					schedulingAwaitingToOpenOpenDate: "2027-03-01",
				},
				"Exam setup opens March 1, 2027.",
			],
			[
				{ examPartState: "AwaitingSchedulingToOpen" },
				"Exam setup opens soon.",
			],
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
			[
				{ examPartState: "SchedulingClosedResultsAvailable", result: "P" },
				/./,
			],
		]
		for (const [overrides, text] of cases) {
			const { unmount } = await renderPart(examPartInfo(overrides))
			if (typeof text === "string") {
				expect(screen.getByText(text)).toBeInTheDocument()
			}
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
	it("shows the scheduled sitting with its zone, and honest empties otherwise", async () => {
		const { unmount } = await renderPart(
			examPartInfo({
				schedulingExamDateTimeSelected: "2027-05-08T09:00:00",
				schedulingExamDateTimeZoneSelected: "EST",
				schedulingExamLocationSelected: "Boston",
				schedulingExamProviderName: "Pearson VUE",
			}),
		)
		expect(screen.getByText(/\(EST\)/)).toBeInTheDocument()
		expect(screen.getByText("Boston")).toBeInTheDocument()
		expect(screen.getByText("Pearson VUE")).toBeInTheDocument()
		unmount()

		await renderPart(examPartInfo({ examFormat: null }))
		expect(screen.getByText("Not available")).toBeInTheDocument()
		expect(screen.getByText("Not scheduled")).toBeInTheDocument()
		expect(screen.getByText("Not selected")).toBeInTheDocument()
		expect(screen.getByText("Not assigned")).toBeInTheDocument()
	})
})

describe("the hand-offs", () => {
	it("links the digital badge and Take Exam in new windows when granted", async () => {
		await renderPart(
			examPartInfo({
				badgePageURL: "https://badges.example.test/frm",
				showTakeExam: true,
				schedulingExamAccessURL: "https://exam.example.test/launch",
			}),
		)
		expect(
			screen.getByRole("link", { name: /Digital Badge/ }),
		).toHaveAttribute("href", "https://badges.example.test/frm")
		expect(screen.getByRole("link", { name: /Take Exam/ })).toHaveAttribute(
			"href",
			"https://exam.example.test/launch",
		)
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
