import { screen } from "@testing-library/react"
import { describe, expect, it } from "vitest"

import { ExamResultCard } from "@/components/molecules/exam-result-card"
import type { ExamResultCardPresentation } from "@/lib/exam-results-presentation"
import { renderWithRouterProviders } from "@/testing/router"

function result(
	overrides: Partial<ExamResultCardPresentation> = {},
): ExamResultCardPresentation {
	return {
		id: "res-1",
		title: "FRM Exam Part I",
		administration: "May 2026",
		examDateLabel: "May 8, 2026",
		outcome: { label: "Passed", tone: "success" },
		resultLabel: null,
		message: "Congratulations on passing.",
		pendingReleaseLabel: null,
		showQuartiles: false,
		quartiles: [],
		resultsLetterHref: null,
		performanceHref: null,
		contactMemberServices: false,
		...overrides,
	}
}

describe("one attempt's card", () => {
	it("shows outcome, dates and message, preferring the explicit result label", async () => {
		await renderWithRouterProviders(
			<ExamResultCard result={result({ resultLabel: "Pass — top quartile" })} />,
		)
		expect(screen.getByText("Pass — top quartile")).toBeInTheDocument()
		expect(screen.getByText(/Exam date May 8, 2026/)).toBeInTheDocument()
		expect(screen.getByText("Congratulations on passing.")).toBeInTheDocument()
		// No links granted: the footer stays away entirely.
		expect(screen.queryByRole("link")).not.toBeInTheDocument()
	})

	it("draws one quartile row per topic with an accessible rank", async () => {
		await renderWithRouterProviders(
			<ExamResultCard
				result={result({
					showQuartiles: true,
					quartiles: [
						{ topic: 1, name: "Market Risk", rank: 1 },
						{ topic: 2, name: "Credit Risk", rank: 3 },
					],
				})}
			/>,
		)
		expect(screen.getByText("Quartile rankings")).toBeInTheDocument()
		expect(screen.getByText("Market Risk")).toBeInTheDocument()
		expect(screen.getByLabelText("Quartile 3 of 4")).toBeInTheDocument()
	})

	it("links the letters it has, and routes member services in-app", async () => {
		await renderWithRouterProviders(
			<ExamResultCard
				result={result({
					resultsLetterHref: "https://letters.example.test/1",
					performanceHref: "https://letters.example.test/2",
					contactMemberServices: true,
				})}
			/>,
		)
		expect(screen.getByRole("link", { name: "Results letter" })).toHaveAttribute(
			"href",
			"https://letters.example.test/1",
		)
		expect(
			screen.getByRole("link", { name: "Performance analysis" }),
		).toHaveAttribute("href", "https://letters.example.test/2")
		expect(
			screen
				.getByRole("link", { name: "Contact member services" })
				.getAttribute("href"),
		).toContain("/help-center")
	})

	it("holds the pending-release line when results are not out yet", async () => {
		await renderWithRouterProviders(
			<ExamResultCard
				result={result({
					message: null,
					pendingReleaseLabel: "Results release on June 30, 2026.",
				})}
			/>,
		)
		expect(
			screen.getByText("Results release on June 30, 2026."),
		).toBeInTheDocument()
	})
})
