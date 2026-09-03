import { screen } from "@testing-library/react"
import { http, HttpResponse } from "msw"
import { describe, expect, it } from "vitest"

import { ExamSetupPanel } from "@/components/organisms/exam-setup-panel"
import { memberPortalEnvelope, memberPortalError } from "@/testing/factories/envelope"
import { examSetupView } from "@/testing/factories/exam-setup"
import { server } from "@/testing/msw/server"
import { renderWithRouterProviders } from "@/testing/router"

const FORM_PATH = "/services/apexrest/memberportal/examSetup"

async function renderPanel(slug = "scr") {
	return renderWithRouterProviders(<ExamSetupPanel programType={slug} />)
}

describe("ExamSetupPanel — view states", () => {
	it("refuses an unknown programme without fetching anything", async () => {
		// No handler registered: a request would fail the strict MSW server.
		await renderPanel("cpd")

		expect(
			screen.getByText("This programme doesn't use the exam setup wizard."),
		).toBeInTheDocument()
	})

	it("shows the skeleton while the form loads", async () => {
		server.use(
			http.get(FORM_PATH, () => new Promise<never>(() => undefined)),
		)

		await renderPanel()

		expect(screen.getByLabelText("Loading exam setup")).toBeInTheDocument()
		expect(screen.queryByText("Choose your sitting")).not.toBeInTheDocument()
	})

	it("renders the two wizard sections once the form lands", async () => {
		server.use(
			http.get(FORM_PATH, () =>
				HttpResponse.json(memberPortalEnvelope(examSetupView())),
			),
		)

		await renderPanel()

		expect(await screen.findByText("Choose your sitting")).toBeInTheDocument()
		expect(screen.getByText("Confirm your ID")).toBeInTheDocument()
		expect(
			screen.getByRole("heading", { name: "Exam setup" }),
		).toBeInTheDocument()
	})

	it("shows the no-dates state when the form is open but offers nothing", async () => {
		server.use(
			http.get(FORM_PATH, () =>
				HttpResponse.json(
					memberPortalEnvelope(
						examSetupView({
							examPart1SelectionInfo: [],
							examPart2SelectionInfo: [],
						}),
					),
				),
			),
		)

		await renderPanel()

		expect(
			await screen.findByText("No exam dates are open"),
		).toBeInTheDocument()
	})

	it("falls back to the unavailable state when the load fails", async () => {
		server.use(
			http.get(FORM_PATH, () =>
				HttpResponse.json(memberPortalError(500, "Exam setup down"), {
					status: 500,
				}),
			),
		)

		await renderPanel()

		expect(
			await screen.findByText(/couldn.t load your exam setup/),
		).toBeInTheDocument()
	})

	/**
	 * Pinned, not endorsed: Apex's 502 means "an unpaid reschedule order
	 * already exists" and the panel HAS dedicated copy for it
	 * (EXAM_SETUP_REFUSALS.pendingReschedule) — but `fetchExamSetupForm`
	 * throws on every non-200 `statusCode`, the query surfaces only `isError`,
	 * and nothing maps the thrown status back to a state (the docstring's
	 * `examSetupRefusal` helper does not exist). So today the member is told
	 * "try again", which for a 502 is exactly wrong. If this test starts
	 * failing because the pendingReschedule copy shows up instead, the bug got
	 * fixed — update the assertion, don't resurrect this behavior.
	 */
	it("currently shows the generic unavailable copy for the 502 pending-reschedule refusal", async () => {
		server.use(
			http.get(FORM_PATH, () =>
				HttpResponse.json(
					{
						status: "Error",
						statusCode: 502,
						errorMessage: "Pending reschedule order exists",
						data: {
							statusMessage: "Pending reschedule order exists",
							statusCode: 502,
						},
					},
					{ status: 502 },
				),
			),
		)

		await renderPanel()

		expect(
			await screen.findByText(/couldn.t load your exam setup/),
		).toBeInTheDocument()
		expect(
			screen.queryByText("You already have a reschedule in progress"),
		).not.toBeInTheDocument()
	})
})
