import { screen } from "@testing-library/react"
import { describe, expect, it } from "vitest"

import { ExamSetupRail } from "@/components/forms/exam-setup/sections/exam-setup-rail"
import { sittingSummary } from "@/lib/exam-setup-presentation"
import { examAdmin, examSetupView } from "@/testing/factories/exam-setup"
import { renderWithProviders } from "@/testing/render"

describe("ExamSetupRail", () => {
	it("shows the chosen date and site with no change marker when nothing moved", () => {
		const view = examSetupView()
		renderWithProviders(
			<ExamSetupRail
				programType="frm"
				parts={sittingSummary(view, { a1: "admin-may", s1: "site-london", a2: "", s2: "" })}
			/>,
		)

		expect(screen.getByText("May 2026")).toBeInTheDocument()
		expect(screen.getByText("London")).toBeInTheDocument()
		expect(screen.queryByText("Changed")).not.toBeInTheDocument()
	})

	// The rail is the one place a member sees "you are moving away from X"
	// before they save, so the record must stay visible next to the choice.
	it("marks a moved date as changed and keeps the old one in view", () => {
		const view = examSetupView()
		renderWithProviders(
			<ExamSetupRail
				programType="frm"
				parts={sittingSummary(view, { a1: "admin-nov", s1: "site-berlin", a2: "", s2: "" })}
			/>,
		)

		expect(screen.getByText("November 2026")).toBeInTheDocument()
		expect(screen.getAllByText("Changed")).toHaveLength(2)
		expect(screen.getByText("was May 2026")).toBeInTheDocument()
		expect(screen.getByText("was London")).toBeInTheDocument()
	})

	it("keeps the shape of the summary before anything is chosen", () => {
		const view = examSetupView({
			examPart1SelectionInfo: [examAdmin()],
		})
		const { container } = renderWithProviders(
			<ExamSetupRail
				programType="frm"
				parts={sittingSummary(view, { a1: "", s1: "", a2: "", s2: "" })}
			/>,
		)

		// Ghost rows are decorative — present in the DOM, hidden from the tree.
		expect(container.querySelector("[aria-hidden] ")).not.toBeNull()
		expect(screen.queryByText("Not chosen yet")).not.toBeInTheDocument()
	})

	it("labels each part for a two-part programme", () => {
		const view = examSetupView({
			examPart2SelectionInfo: [examAdmin({ id: "admin-p2", name: "December 2026", isSelected: true })],
		})
		renderWithProviders(
			<ExamSetupRail
				programType="frm"
				parts={sittingSummary(view, {
					a1: "admin-may",
					s1: "site-london",
					a2: "admin-p2",
					s2: "",
				})}
			/>,
		)

		expect(screen.getByText("Part I")).toBeInTheDocument()
		expect(screen.getByText("Part II")).toBeInTheDocument()
		expect(screen.getByText("December 2026")).toBeInTheDocument()
	})

	it("tells the member what happens after Save, fee included", () => {
		renderWithProviders(
			<ExamSetupRail programType="frm" parts={sittingSummary(examSetupView(), { a1: "", s1: "", a2: "", s2: "" })} />,
		)

		expect(screen.getByText("What happens next")).toBeInTheDocument()
		expect(screen.getByText(/a change fee applies/)).toBeInTheDocument()
	})
})
