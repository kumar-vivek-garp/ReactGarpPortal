import { screen, waitFor, within } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { http, HttpResponse } from "msw"
import { describe, expect, it } from "vitest"

import type { ExamRegisterRequest } from "@/api/registration/exam-types"
import { memberPortalError } from "@/testing/factories/envelope"
import {
	examRegisterResult,
	feesResult,
	verifyCustomerResult,
} from "@/testing/factories/exam"
import {
	chooseExamPartAndSite,
	renderExamForm,
	tickExamAcknowledgements,
} from "@/testing/exam-registration-ui"
import { EXAMREG_PATH, examregPost } from "@/testing/msw/handlers/examreg"
import { server } from "@/testing/msw/server"

/**
 * The confirm-dialog contract: `handleSubmit` validates and STAGES the built
 * request; nothing goes on the wire until the dialog's own confirm. Past that
 * point `register` writes records and `payOrder` is not idempotent, so the
 * staging step is the last safe place to stop.
 */
function armHappyPath() {
	const verify = examregPost("verifyCustomer", () => verifyCustomerResult())
	const fees = examregPost("fees", () => feesResult(0))
	// No order id: nothing to pay, so the flow ends at `registered`.
	const register = examregPost<ExamRegisterRequest>("register", () =>
		examRegisterResult({
			orderId: null,
			orderNumber: "ORD-77",
			hasBilling: false,
			total: 0,
		}),
	)
	server.use(verify.handler, fees.handler, register.handler)
	return { verify, fees, register }
}

/** Completes the member form and clicks the bar's submit, opening the dialog. */
async function fillAndSubmit(user: ReturnType<typeof userEvent.setup>) {
	await chooseExamPartAndSite(user)
	await tickExamAcknowledgements(user)
	const submit = screen.getByRole("button", { name: "Register" })
	await waitFor(() => {
		expect(submit).toBeEnabled()
	})
	await user.click(submit)
	return screen.findByRole("dialog", { name: "Confirm your registration" })
}

describe("ExamRegistrationForm — confirm dialog", () => {
	it("stages the request without firing anything until the dialog confirms", async () => {
		const { verify, register } = armHappyPath()
		const user = userEvent.setup()
		await renderExamForm()

		const dialog = await fillAndSubmit(user)

		// Valid, built, staged — and NOTHING on the wire yet.
		expect(verify.spy.hits).toBe(0)
		expect(register.spy.hits).toBe(0)
		// The dialog repeats the figures where they have to be read.
		expect(within(dialog).getByText("Total")).toBeInTheDocument()
	})

	it("Back closes the dialog without registering anything", async () => {
		const { register } = armHappyPath()
		const user = userEvent.setup()
		const { onRegistered } = await renderExamForm()

		const dialog = await fillAndSubmit(user)
		await user.click(within(dialog).getByRole("button", { name: "Back" }))

		await waitFor(() => {
			expect(
				screen.queryByRole("dialog", { name: "Confirm your registration" }),
			).not.toBeInTheDocument()
		})
		expect(register.spy.hits).toBe(0)
		expect(onRegistered).not.toHaveBeenCalled()
	})

	it("confirm fires the mutation exactly once and reports the outcome", async () => {
		const { verify, register } = armHappyPath()
		const user = userEvent.setup()
		const { onRegistered } = await renderExamForm()

		const dialog = await fillAndSubmit(user)
		await user.click(within(dialog).getByRole("button", { name: "Register" }))

		await waitFor(() => {
			expect(onRegistered).toHaveBeenCalledTimes(1)
		})
		expect(onRegistered).toHaveBeenCalledWith(
			expect.objectContaining({
				kind: "registered",
				result: expect.objectContaining({ orderNumber: "ORD-77" }),
			}),
		)
		expect(verify.spy.hits).toBe(1)
		expect(register.spy.hits).toBe(1)

		// The staged request is the real one: the resolved exam choice, the
		// member's identity, and the verify session all made it to the wire.
		const body = register.spy.bodies[0]
		expect(body.selection.part1).toEqual({ rateId: "rate-1a", siteId: "site-a1" })
		expect(body.selection.part2).toBeNull()
		expect(body.customer.email).toBe("ada@example.org")
		expect(body.sessionId).toBe("S-1")
		expect(body.consent.examPolicy).toBe(true)

		// Done — the dialog goes away (Radix removes it after its exit state).
		await waitFor(() => {
			expect(
				screen.queryByRole("dialog", { name: "Confirm your registration" }),
			).not.toBeInTheDocument()
		})
	})

	it("a failure closes the dialog and surfaces the server message against the form", async () => {
		const verify = examregPost("verifyCustomer", () => verifyCustomerResult())
		const fees = examregPost("fees", () => feesResult(0))
		server.use(
			verify.handler,
			fees.handler,
			http.post(`${EXAMREG_PATH}/register`, () =>
				HttpResponse.json(
					memberPortalError(500, "No seats are left at this exam centre."),
					{ status: 500 },
				),
			),
		)
		const user = userEvent.setup()
		const { onRegistered } = await renderExamForm()

		const dialog = await fillAndSubmit(user)
		await user.click(within(dialog).getByRole("button", { name: "Register" }))

		// Closed, so the failure is read against the form it must be fixed in.
		await waitFor(() => {
			expect(
				screen.queryByRole("dialog", { name: "Confirm your registration" }),
			).not.toBeInTheDocument()
		})
		expect(
			screen.getByText("Unable to complete your registration"),
		).toBeInTheDocument()
		expect(
			screen.getByText("No seats are left at this exam centre."),
		).toBeInTheDocument()
		expect(onRegistered).not.toHaveBeenCalled()
	})
})
