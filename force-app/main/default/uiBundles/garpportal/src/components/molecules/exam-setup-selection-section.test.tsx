import { screen, within } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { describe, expect, it, vi } from "vitest"

import type { ExamSetupSelectionInput } from "@/api/exam-setup"
import { examAdmin, examAdmins, examSite } from "@/testing/factories/exam-setup"
import { renderWithProviders } from "@/testing/render"

import { ExamSetupSelectionSection } from "./exam-setup-selection-section"

function selection(
	overrides: Partial<ExamSetupSelectionInput> = {},
): ExamSetupSelectionInput {
	return {
		selectedAdminPart1: "admin-may",
		selectedSitePart1: "site-london",
		selectedAdminPart2: null,
		selectedSitePart2: null,
		...overrides,
	}
}

const part2Admins = () => [
	examAdmin({
		id: "admin2-may",
		name: "May 2026 (Part II)",
		examSites: [examSite({ id: "site2-oslo", name: "Oslo" })],
	}),
]

function renderSection(current = selection()) {
	const onSelectionChange = vi.fn()
	renderWithProviders(
		<ExamSetupSelectionSection
			part1Admins={examAdmins()}
			part2Admins={part2Admins()}
			selection={current}
			canChangeAdminPart1
			canChangeAdminPart2
			onSelectionChange={onSelectionChange}
		/>,
	)
	return { onSelectionChange }
}

const partTwo = () => within(screen.getByRole("group", { name: "Part II" }))

describe("ExamSetupSelectionSection — Part II column", () => {
	it("choosing a Part II date clears the Part II site with it", async () => {
		const user = userEvent.setup()
		const { onSelectionChange } = renderSection(
			selection({ selectedAdminPart2: null, selectedSitePart2: "stale-site" }),
		)

		await user.click(
			partTwo().getByRole("combobox", { name: /Exam date/ }),
		)
		await user.click(
			await screen.findByRole("option", { name: "May 2026 (Part II)" }),
		)

		expect(onSelectionChange).toHaveBeenCalledWith(
			selection({ selectedAdminPart2: "admin2-may", selectedSitePart2: null }),
		)
	})

	it("choosing a Part II site keeps the rest of the selection", async () => {
		const user = userEvent.setup()
		const { onSelectionChange } = renderSection(
			selection({ selectedAdminPart2: "admin2-may" }),
		)

		await user.click(
			partTwo().getByRole("combobox", { name: /Exam site/ }),
		)
		await user.click(await screen.findByRole("option", { name: "Oslo" }))

		expect(onSelectionChange).toHaveBeenCalledWith(
			selection({
				selectedAdminPart2: "admin2-may",
				selectedSitePart2: "site2-oslo",
			}),
		)
	})

	it("renders a single column when the programme has no Part II", () => {
		renderWithProviders(
			<ExamSetupSelectionSection
				part1Admins={examAdmins()}
				part2Admins={[]}
				selection={selection()}
				canChangeAdminPart1
				canChangeAdminPart2
				onSelectionChange={vi.fn()}
			/>,
		)

		expect(screen.getByRole("group", { name: "Your exam" })).toBeInTheDocument()
		expect(
			screen.queryByRole("group", { name: "Part II" }),
		).not.toBeInTheDocument()
	})
})
