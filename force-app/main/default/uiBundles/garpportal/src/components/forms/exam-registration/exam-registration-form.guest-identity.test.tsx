import { screen, waitFor } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { describe, expect, it } from "vitest"

import type { ExamVerifyCustomerRequest } from "@/api/registration/exam-types"
import { feesResult, verifyCustomerResult } from "@/testing/factories/exam"
import { renderExamForm } from "@/testing/exam-registration-ui"
import { examregPost } from "@/testing/msw/handlers/examreg"
import { server } from "@/testing/msw/server"

/**
 * The identity check GarpAppv1 runs on blur, so a guest whose email already
 * belongs to an account learns it before filling the rest of the form.
 */
function armGuest(verifyOverrides: Parameters<typeof verifyCustomerResult>[0] = {}) {
	const verify = examregPost<ExamVerifyCustomerRequest>("verifyCustomer", () =>
		verifyCustomerResult(verifyOverrides),
	)
	const fees = examregPost("fees", () => feesResult(100))
	server.use(verify.handler, fees.handler)
	return { verify, fees }
}

async function typeIdentity(
	user: ReturnType<typeof userEvent.setup>,
	email: string,
) {
	await user.type(screen.getByLabelText(/First name/), "Jo")
	await user.type(screen.getByLabelText(/Last name/), "March")
	await user.type(screen.getByLabelText(/Email/), email)
	await user.tab()
}

describe("ExamRegistrationForm — guest identity check", () => {
	it("verifies a valid email on blur and reports an existing record", async () => {
		const { verify } = armGuest({ isExistingCustomer: true, mustSignIn: false })
		const user = userEvent.setup()
		await renderExamForm({ profile: null, isAuthenticated: false })

		await typeIdentity(user, "jo@example.org")

		await waitFor(() => {
			expect(verify.spy.hits).toBe(1)
		})
		expect(verify.spy.bodies[0]).toMatchObject({
			type: "frm",
			email: "jo@example.org",
			firstName: "Jo",
			lastName: "March",
		})
		// Reassurance, not a wall: the registration joins the existing record.
		expect(
			await screen.findByText("We found your record"),
		).toBeInTheDocument()
	})

	it("tells a member-owned email to sign in, with an honest link", async () => {
		armGuest({ mustSignIn: true })
		const user = userEvent.setup()
		await renderExamForm({ profile: null, isAuthenticated: false })

		await typeIdentity(user, "member@example.org")

		expect(
			await screen.findByText("You already have an account"),
		).toBeInTheDocument()
		// "start again" is the honest part — signing in discards the form.
		const link = screen.getByRole("link", { name: "Sign in and start again" })
		expect(link.getAttribute("href")).toContain("/Login?startUrl=")
	})

	it("does not fire while the email is not yet a valid address", async () => {
		const { verify } = armGuest()
		const user = userEvent.setup()
		await renderExamForm({ profile: null, isAuthenticated: false })

		await typeIdentity(user, "not-an-email")

		expect(verify.spy.hits).toBe(0)
		// The field's own error handles it instead.
		expect(
			await screen.findByText("Please enter a valid email address."),
		).toBeInTheDocument()
	})

	it("checks each address once — a repeat blur reuses the answer", async () => {
		const { verify } = armGuest({ isExistingCustomer: true })
		const user = userEvent.setup()
		await renderExamForm({ profile: null, isAuthenticated: false })

		await typeIdentity(user, "jo@example.org")
		await screen.findByText("We found your record")

		// Blur the same address again: the result doubles as the registration's
		// session, so re-checking would burn it for nothing.
		await user.click(screen.getByLabelText(/Email/))
		await user.tab()

		expect(verify.spy.hits).toBe(1)
	})
})
