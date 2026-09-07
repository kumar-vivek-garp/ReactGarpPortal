import { screen, waitFor } from "@testing-library/react"
import { describe, expect, it, vi } from "vitest"

import { ExamRegistrationPanel } from "@/components/forms/exam-registration/exam-registration-panel"
import { EXAM_PROGRAMS } from "@/config/registration"
import {
	examCustomer,
	examRegisterRequest,
	feesResult,
} from "@/testing/factories/exam"
import { resumeResult } from "@/testing/factories/exam-payment"
import { pricedExamLoad } from "@/testing/exam-registration-ui"
import { examregGet, examregPost } from "@/testing/msw/handlers/examreg"
import { server } from "@/testing/msw/server"
import { renderWithRouterProviders } from "@/testing/router"

async function renderResume(stagedId: string) {
	return renderWithRouterProviders(
		<ExamRegistrationPanel
			program={EXAM_PROGRAMS.frm}
			programType="frm"
			onNavigateBack={vi.fn()}
			resumeStagedId={stagedId}
		/>,
		{ user: null },
	)
}

function armForm() {
	const info = examregGet("info", () => pricedExamLoad())
	const fees = examregPost("fees", () => feesResult(600))
	const rollback = examregPost("rollback", () => ({}))
	server.use(info.handler, fees.handler, rollback.handler)
	return { info, fees, rollback }
}

/**
 * Back from the payment page under the deferred flow: the form is rebuilt
 * from what the server banked, not from what the browser remembered.
 */
describe("ExamRegistrationPanel — resume", () => {
	it("holds the skeleton until the saved payload is in hand, then restores what was typed and chosen", async () => {
		const spies = armForm()
		const resume = examregGet("resume", () =>
			resumeResult({
				stagedId: "a0H-staged",
				payload: examRegisterRequest({
					customer: examCustomer({
						firstName: "Resumed",
						lastName: "Candidate",
						email: "resumed@example.com",
					}),
					selection: {
						partSelected: "FRM Exam Part I",
						part1: { rateId: "rate-1a", siteId: "site-a2" },
						part2: null,
					},
					materials: ["SM-GEN"],
					paymentType: "Stripe",
				}),
			}),
		)
		server.use(resume.handler)

		await renderResume("a0H-staged")

		// The form seeds itself at mount, so it must not mount before this
		// answers — the skeleton stands in until then.
		expect(screen.getByText("Loading your registration…")).toBeInTheDocument()

		expect(await screen.findByLabelText(/Email/)).toHaveValue("resumed@example.com")
		expect(screen.getByLabelText(/First name/)).toHaveValue("Resumed")
		// The exam choice is state, not a field — restored into the state hook.
		expect(screen.getByRole("combobox", { name: "Exam part" })).toHaveTextContent(
			"FRM Exam Part I",
		)
		expect(
			screen.getByRole("combobox", { name: "Where you will sit" }),
		).toHaveTextContent("Chicago")
		// The cart, too: exactly one material — the chosen one — offers Remove.
		await waitFor(() => {
			expect(screen.getAllByRole("button", { name: "Remove" })).toHaveLength(1)
		})
		expect(screen.getByText("Practice Exams")).toBeInTheDocument()
		expect(resume.spy.hits).toBe(1)
		// Nothing to undo: a staged registration created no records.
		expect(spies.rollback.spy.hits).toBe(0)
	})

	it("a registration that is no longer resumable is a plain empty form, not an error", async () => {
		armForm()
		const resume = examregGet("resume", () => ({
			resumable: false,
			payload: null,
			registrationRef: null,
		}))
		server.use(resume.handler)

		await renderResume("a0H-expired")

		expect(await screen.findByLabelText(/Email/)).toHaveValue("")
		expect(
			screen.queryByRole("heading", { name: "Unable to open registration" }),
		).not.toBeInTheDocument()
		expect(resume.spy.hits).toBe(1)
	})
})
