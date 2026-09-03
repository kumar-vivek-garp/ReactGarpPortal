import { screen } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { http, HttpResponse } from "msw"
import { describe, expect, it, vi } from "vitest"

import type { AffiliateRegisterRequest } from "@/api/registration"
import { AffiliateRegistrationForm } from "@/components/forms/affiliate/affiliate-registration-form"
import { AffiliateRegistrationPanel } from "@/components/forms/affiliate/affiliate-registration-panel"
import { fillAffiliateForm, registerButton } from "@/testing/affiliate-form"
import {
	affiliateLoad,
	affiliateRegisterResult,
} from "@/testing/factories/affiliate"
import { memberPortalError } from "@/testing/factories/envelope"
import { verifyCustomerResult } from "@/testing/factories/exam"
import {
	examregGet,
	examregPost,
	EXAMREG_PATH,
} from "@/testing/msw/handlers/examreg"
import { server } from "@/testing/msw/server"
import { renderWithRouterProviders } from "@/testing/router"

/*
 * Deliberately NO `skipSpringAnimations()` here: with `skipAnimation` on,
 * rendering the panel (whose `useSubpageTransition` spring gets fresh props
 * every render) livelocks the worker. The real springs settle in well under
 * a `findBy*` wait.
 */

describe("a successful registration, end to end through the panel", () => {
	it("verifies once, registers with trimmed fields, settles the order, shows the outcome", async () => {
		const info = examregGet("info", () => affiliateLoad())
		const verify = examregPost("verifyCustomer", () => verifyCustomerResult())
		const register = examregPost<AffiliateRegisterRequest>("register", () =>
			affiliateRegisterResult(),
		)
		const pay = examregPost<{ orderId?: string }>("payOrder", () => ({
			completed: true,
		}))
		server.use(info.handler, verify.handler, register.handler, pay.handler)

		const user = userEvent.setup()
		await renderWithRouterProviders(<AffiliateRegistrationPanel />, {
			path: "/registration/affiliate",
		})
		await screen.findByRole("heading", { level: 1 })

		// Names carry stray spaces; the email may not (its own pattern runs
		// against the raw value), so it is typed clean.
		await fillAffiliateForm(user, {
			firstName: " Ada ",
			lastName: " Lovelace ",
		})
		await user.click(registerButton())

		// The outcome replaces the form — a second submit would come back
		// `mustSignIn`, because the first one just created the account.
		expect(
			await screen.findByRole("heading", {
				name: "You’re an Affiliate Member",
			}),
		).toBeInTheDocument()
		expect(
			screen.queryByRole("button", { name: "Register" }),
		).not.toBeInTheDocument()

		// Both destinations sit outside the session guard: garp.org and Login.
		expect(screen.getByRole("link", { name: "Back to GARP.org" })).toHaveAttribute(
			"href",
			"https://www.garp.org",
		)
		expect(screen.getByRole("link", { name: "Sign in" })).toHaveAttribute(
			"href",
			"/Login",
		)

		// One identity call for the whole journey — the blur session is reused.
		expect(verify.spy.hits).toBe(1)
		expect(register.spy.hits).toBe(1)
		expect(register.spy.bodies[0]).toEqual({
			type: "affiliate",
			sessionId: "S-1",
			customer: {
				contactId: "003-verified",
				accountId: "001-verified",
				leadId: null,
				firstName: "Ada",
				lastName: "Lovelace",
				email: "ada@garp.org",
				mobilePhoneCode: "United States (+1)",
				mobilePhone: "5551234",
				smsPromotionalUpdates: false,
			},
			billingAddress: { country: "United States" },
			billingAndShippingSame: true,
			consent: { privacyPolicy: true },
		})
		// payOrder is not idempotent server-side — exactly once.
		expect(pay.spy.hits).toBe(1)
		expect(pay.spy.bodies[0]).toEqual({ orderId: "801-aff" })
	})
})

describe("a failed registration", () => {
	it("surfaces the server's sentence inline and stays on the form", async () => {
		const verify = examregPost("verifyCustomer", () => verifyCustomerResult())
		server.use(
			verify.handler,
			http.post(`${EXAMREG_PATH}/register`, () =>
				HttpResponse.json(
					memberPortalError(500, "Membership contract could not be created."),
					{ status: 500 },
				),
			),
		)

		const user = userEvent.setup()
		const onRegistered = vi.fn()
		await renderWithRouterProviders(
			<AffiliateRegistrationForm
				load={affiliateLoad()}
				onRegistered={onRegistered}
			/>,
			{ path: "/registration/affiliate" },
		)

		await fillAffiliateForm(user)
		await user.click(registerButton())

		expect(
			await screen.findByText("Unable to complete your registration"),
		).toBeInTheDocument()
		expect(
			screen.getByText("Membership contract could not be created."),
		).toBeInTheDocument()
		expect(onRegistered).not.toHaveBeenCalled()
		// The form is still there to fix and resubmit.
		expect(registerButton()).toBeEnabled()
	})
})
