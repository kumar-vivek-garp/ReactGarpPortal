import { screen, waitFor, within } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { describe, expect, it, vi } from "vitest"

import type { CurrentUser } from "@/api/auth/current-user"
import { personalInfoQueryKeys } from "@/api/personal-info/query-options"
import { ExamRegistrationPanel } from "@/components/forms/exam-registration/exam-registration-panel"
import { EXAM_PROGRAMS } from "@/config/registration"
import {
	examRegisterResult,
	feesResult,
	verifyCustomerResult,
} from "@/testing/factories/exam"
import {
	chooseExamPartAndSite,
	pricedExamLoad,
	tickExamAcknowledgements,
} from "@/testing/exam-registration-ui"
import { personalInfoEditData } from "@/testing/factories/personal-info"
import { examregGet, examregPost } from "@/testing/msw/handlers/examreg"
import { server } from "@/testing/msw/server"
import { createTestQueryClient } from "@/testing/query-client"
import { renderWithRouterProviders } from "@/testing/router"

const MEMBER: CurrentUser = {
	id: "005-member",
	name: "Ada Lovelace",
	garpId: "G-1",
	contactId: "003-member",
	photoUrl: null,
}

/**
 * The whole journey through the PANEL: load → form → confirm → outcome. The
 * outcome must REPLACE the form — a filled-in registration left behind a
 * success message is an invitation to submit it again.
 */
describe("ExamRegistrationPanel — registration outcome", () => {
	it("swaps the form for the outcome screen once registration completes", async () => {
		const info = examregGet("info", () =>
			pricedExamLoad({ isAuthenticated: true }),
		)
		const verify = examregPost("verifyCustomer", () => verifyCustomerResult())
		const fees = examregPost("fees", () => feesResult(0))
		const register = examregPost("register", () =>
			examRegisterResult({
				orderId: null,
				orderNumber: "ORD-88",
				hasBilling: false,
				total: 0,
			}),
		)
		server.use(info.handler, verify.handler, fees.handler, register.handler)

		const queryClient = createTestQueryClient(MEMBER)
		queryClient.setQueryData(
			personalInfoQueryKeys.edit(MEMBER.contactId as string),
			personalInfoEditData({ contactId: MEMBER.contactId as string }),
		)
		const user = userEvent.setup()
		await renderWithRouterProviders(
			<ExamRegistrationPanel
				program={EXAM_PROGRAMS.frm}
				programType="frm"
				onNavigateBack={vi.fn()}
			/>,
			{ user: MEMBER, queryClient },
		)

		await screen.findByText("Contact details")
		await chooseExamPartAndSite(user)
		await tickExamAcknowledgements(user)

		const submit = screen.getByRole("button", { name: "Register" })
		await waitFor(() => {
			expect(submit).toBeEnabled()
		})
		await user.click(submit)

		const dialog = await screen.findByRole("dialog", {
			name: "Confirm your registration",
		})
		await user.click(within(dialog).getByRole("button", { name: "Register" }))

		// The outcome IS the page now: order number up front, form gone.
		expect(
			await screen.findByRole("heading", { name: "You're registered" }),
		).toBeInTheDocument()
		expect(screen.getByText("ORD-88")).toBeInTheDocument()
		expect(screen.queryByText("Contact details")).not.toBeInTheDocument()
		expect(
			screen.queryByRole("button", { name: "Register" }),
		).not.toBeInTheDocument()
		// A member's outcome offers the in-app destinations.
		expect(
			screen.getByRole("link", { name: "Go to dashboard" }),
		).toBeInTheDocument()
		expect(register.spy.hits).toBe(1)
	})
})
