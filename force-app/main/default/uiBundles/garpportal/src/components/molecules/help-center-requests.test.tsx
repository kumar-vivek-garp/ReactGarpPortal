import { screen } from "@testing-library/react"
import { describe, expect, it } from "vitest"

import type { CaseSummary } from "@/api/help-center"
import { HelpCenterRequests } from "@/components/molecules/help-center-requests"
import { renderWithProviders } from "@/testing/render"

function caseSummary(overrides: Partial<CaseSummary> = {}): CaseSummary {
	return {
		id: "case-1",
		caseNumber: "00012345",
		subject: "Exam voucher not applied",
		status: "In Progress",
		createdDate: "2026-08-30T10:00:00.000Z",
		...overrides,
	}
}

describe("the requests list", () => {
	it("renders one row per case with number, subject and status", () => {
		renderWithProviders(
			<HelpCenterRequests
				cases={[
					caseSummary(),
					caseSummary({
						id: "case-2",
						caseNumber: "00012346",
						subject: "Membership renewal question",
						status: "Closed",
					}),
				]}
			/>,
		)
		expect(screen.getByText("00012345")).toBeInTheDocument()
		expect(screen.getByText("Exam voucher not applied")).toBeInTheDocument()
		expect(screen.getByText("In Progress")).toBeInTheDocument()
		expect(screen.getByText("Closed")).toBeInTheDocument()
	})

	it("shows the shared empty state when there are no cases", () => {
		renderWithProviders(<HelpCenterRequests cases={[]} />)
		expect(screen.queryByText("00012345")).not.toBeInTheDocument()
		// The zero-state block replaces the table entirely.
		expect(screen.queryByText("Case")).not.toBeInTheDocument()
	})
})
