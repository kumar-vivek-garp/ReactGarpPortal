import { screen } from "@testing-library/react"
import { describe, expect, it } from "vitest"

import { ProgramExamOverview } from "@/components/molecules/program-exam-overview"
import { examPartInfo, programDetail } from "@/testing/factories/programs"
import { renderWithRouterProviders } from "@/testing/router"

/**
 * The card once an outcome is in, or a change is unpaid — the states whose
 * buttons the legacy decides across both parts at once.
 */

describe("results available", () => {
	it("leads a pass with Part II open to register for it, and says so", async () => {
		await renderWithRouterProviders(
			<ProgramExamOverview
				detail={programDetail({
					programType: "FRM",
					currentRegistrationCanAddPartII: true,
					currentRegistrationIsOpen: true,
				})}
				part={examPartInfo({
					examPartState: "SchedulingClosedResultsAvailable",
					result: "Pass",
				})}
				partIndex={1}
			/>,
		)
		expect(screen.getByText("Take the FRM Exam Part II next.")).toBeInTheDocument()
		expect(screen.getByText("Exam results")).toBeInTheDocument()
		expect(screen.getByText("Pass")).toBeInTheDocument()
		expect(
			screen.getByRole("link", { name: /Register for Part II/ }),
		).toHaveAttribute("href", "/programs/frm/register")
		expect(
			screen.getByRole("link", { name: /View Exam Results/ }),
		).toHaveAttribute("href", "/programs/frm/results")
	})

	it("names the reopen date for a fail while the window is shut, with results only", async () => {
		await renderWithRouterProviders(
			<ProgramExamOverview
				detail={programDetail({
					programType: "FRM",
					currentRegistrationIsOpen: false,
					nextRegistrationOpenDate: "2027-12-01",
				})}
				part={examPartInfo({
					examPartState: "SchedulingClosedResultsAvailable",
					result: "Fail",
				})}
				partIndex={1}
			/>,
		)
		expect(
			screen.getByText("Registration will open on December 1, 2027."),
		).toBeInTheDocument()
		expect(screen.getAllByRole("link")).toHaveLength(1)
		expect(screen.getByRole("link", { name: /View Exam Results/ })).toBeInTheDocument()
	})

	it("offers nothing at all when the result is not available", async () => {
		await renderWithRouterProviders(
			<ProgramExamOverview
				detail={programDetail({ programType: "FRM", currentRegistrationIsOpen: true })}
				part={examPartInfo({
					examPartState: "SchedulingClosedResultsAvailable",
					result: "Not Available",
				})}
				partIndex={1}
			/>,
		)
		expect(screen.getByText("Your exam result is not available.")).toBeInTheDocument()
		expect(screen.queryByRole("link")).not.toBeInTheDocument()
	})
})

describe("an unpaid exam change", () => {
	it("warns, offers only the pending order, and withholds Edit and Take Exam", async () => {
		await renderWithRouterProviders(
			<ProgramExamOverview
				detail={programDetail({ programType: "FRM" })}
				part={examPartInfo({
					examPartState: "SchedulingClosedAwaitingToTakeExam",
					isDeferralOpen: true,
					showTakeExam: true,
					schedulingExamAccessURL: "https://exam.example.test/launch",
					schedulingDeadline: "2027-04-20",
					unpaidDeferralOrderId: "006-change",
				})}
				partIndex={1}
			/>,
		)
		expect(screen.getByRole("alert")).toHaveTextContent(
			"You must pay before April 20, 2027 to complete this request.",
		)
		expect(
			screen.getByRole("link", { name: /View Pending Order/ }),
		).toHaveAttribute("href", "/my-account/orders/006-change")
		expect(screen.queryByRole("link", { name: /Take Exam/ })).not.toBeInTheDocument()
		expect(screen.queryByRole("link", { name: /Edit/ })).not.toBeInTheDocument()
	})
})
