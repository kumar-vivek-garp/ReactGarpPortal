import { screen, waitFor } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { http } from "msw"
import { describe, expect, it } from "vitest"

import { feesResult } from "@/testing/factories/exam"
import {
	chooseExamPartAndSite,
	renderExamForm,
	tickExamAcknowledgements,
} from "@/testing/exam-registration-ui"
import { EXAMREG_PATH, examregPost } from "@/testing/msw/handlers/examreg"
import { server } from "@/testing/msw/server"

/**
 * The submit gate (`registration-forms.md` §8): disabled on an empty form,
 * enabled only when complete, and disabled AGAIN when a required answer is
 * removed. Zero-total pricing keeps the payment/address sections out of the
 * way so the gate itself is what is exercised.
 */
function armZeroCostFees() {
	const fees = examregPost("fees", () => feesResult(0))
	server.use(fees.handler)
	return fees
}

const submitButton = () => screen.getByRole("button", { name: "Register" })

describe("ExamRegistrationForm — submit gate", () => {
	it("starts disabled on an empty guest form, with the reason on the button", async () => {
		armZeroCostFees()
		await renderExamForm({ profile: null, isAuthenticated: false })

		const button = submitButton()
		expect(button).toBeDisabled()
		expect(button).toHaveAttribute(
			"title",
			"Complete the required fields to continue.",
		)
	})

	it("opens only when complete, and closes again when an answer is removed", async () => {
		armZeroCostFees()
		const user = userEvent.setup()
		await renderExamForm()

		// Prefilled member details are not enough: no exam, no acknowledgements.
		expect(submitButton()).toBeDisabled()

		await chooseExamPartAndSite(user)
		expect(submitButton()).toBeDisabled()

		await tickExamAcknowledgements(user)
		await waitFor(() => {
			expect(submitButton()).toBeEnabled()
		})

		// §8: removing a required answer must close the gate again.
		await user.click(screen.getByRole("checkbox", { name: /Exam Policies/ }))
		await waitFor(() => {
			expect(submitButton()).toBeDisabled()
		})

		// And restoring it reopens — the gate is live, not one-shot.
		await user.click(screen.getByRole("checkbox", { name: /Exam Policies/ }))
		await waitFor(() => {
			expect(submitButton()).toBeEnabled()
		})
	})

	it("stays closed while the exam choice is missing even though every field is valid", async () => {
		armZeroCostFees()
		const user = userEvent.setup()
		await renderExamForm()

		// The exam selection lives OUTSIDE react-hook-form (cascading state), so
		// `isValid` alone cannot be the gate — this is the check that it is not.
		await tickExamAcknowledgements(user)

		const button = submitButton()
		expect(button).toBeDisabled()
		expect(button).toHaveAttribute(
			"title",
			"Complete the required fields to continue.",
		)
	})

	it("stays closed until the cart has actually priced", async () => {
		// The pricing request hangs for ever, so `fees` never exists.
		server.use(
			http.post(
				`${EXAMREG_PATH}/fees`,
				() => new Promise<never>(() => undefined),
			),
		)
		const user = userEvent.setup()
		await renderExamForm()

		await chooseExamPartAndSite(user)
		await tickExamAcknowledgements(user)

		// Everything is answered, but submitting before a total exists would be
		// agreeing to a figure nobody has seen.
		expect(submitButton()).toBeDisabled()
	})
})
