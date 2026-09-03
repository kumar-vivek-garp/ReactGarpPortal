import { createFileRoute } from "@tanstack/react-router"
import { screen } from "@testing-library/react"
import { describe, expect, it } from "vitest"

import { renderFileRoute } from "@/testing/file-route"

import { ExamResultsPending } from "./exam-results-pending"

const ROUTE_ID = "/_appLayout/programs/$programType/results/"

describe("ExamResultsPending — route wrapper", () => {
	it("keeps the back link to the program while results load", async () => {
		const route = createFileRoute(ROUTE_ID)({
			component: ExamResultsPending,
		})
		await renderFileRoute(route, {
			id: ROUTE_ID,
			path: "/programs/$programType/results/",
			initialEntries: ["/programs/frm/results"],
		})

		expect(screen.getByLabelText("Loading exam results")).toHaveAttribute(
			"aria-busy",
		)
		// The route param feeds the back label, so the header matches the page.
		expect(screen.getByRole("link", { name: /FRM/ })).toBeInTheDocument()
	})
})
