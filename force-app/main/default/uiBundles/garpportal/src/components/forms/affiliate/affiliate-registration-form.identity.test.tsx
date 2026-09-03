import { screen } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { describe, expect, it, vi } from "vitest"

import { AffiliateRegistrationForm } from "@/components/forms/affiliate/affiliate-registration-form"
import { fillAffiliateForm, registerButton } from "@/testing/affiliate-form"
import { affiliateLoad } from "@/testing/factories/affiliate"
import { verifyCustomerResult } from "@/testing/factories/exam"
import { examregPost } from "@/testing/msw/handlers/examreg"
import { server } from "@/testing/msw/server"
import { renderWithRouterProviders } from "@/testing/router"
import { skipSpringAnimations } from "@/testing/springs"

skipSpringAnimations()

async function renderForm() {
	const onRegistered = vi.fn()
	const rendered = await renderWithRouterProviders(
		<AffiliateRegistrationForm load={affiliateLoad()} onRegistered={onRegistered} />,
		{ path: "/registration/affiliate" },
	)
	return { ...rendered, onRegistered }
}

async function typeIdentity(user: ReturnType<typeof userEvent.setup>) {
	await user.type(screen.getByRole("textbox", { name: /first name/i }), "Ada")
	await user.type(
		screen.getByRole("textbox", { name: /last name/i }),
		"Lovelace",
	)
	await user.type(
		screen.getByRole("textbox", { name: /email address/i }),
		"ada@garp.org",
	)
	await user.tab()
}

describe("the email-blur identity check", () => {
	it("runs once per address, sending all three identity fields", async () => {
		const verify = examregPost("verifyCustomer", () => verifyCustomerResult())
		server.use(verify.handler)
		const user = userEvent.setup()
		await renderForm()

		await typeIdentity(user)
		await vi.waitFor(() => {
			expect(verify.spy.hits).toBe(1)
		})
		expect(verify.spy.bodies[0]).toEqual({
			type: "affiliate",
			email: "ada@garp.org",
			firstName: "Ada",
			lastName: "Lovelace",
		})

		// Blurring the same address again reuses the answer — one call, not two.
		await user.click(screen.getByRole("textbox", { name: /email address/i }))
		await user.tab()
		expect(verify.spy.hits).toBe(1)
	})

	it("does not run for an address that is not yet a valid email", async () => {
		const verify = examregPost("verifyCustomer", () => verifyCustomerResult())
		server.use(verify.handler)
		const user = userEvent.setup()
		await renderForm()

		await user.type(
			screen.getByRole("textbox", { name: /email address/i }),
			"not-an-email",
		)
		await user.tab()
		expect(verify.spy.hits).toBe(0)
	})

	it("tells an existing customer they may carry on", async () => {
		const verify = examregPost("verifyCustomer", () =>
			verifyCustomerResult({ isExistingCustomer: true }),
		)
		server.use(verify.handler)
		const user = userEvent.setup()
		await renderForm()

		await typeIdentity(user)

		const alert = await screen.findByText("We found your record")
		expect(alert).toBeInTheDocument()
		expect(
			screen.getByText(
				"We already hold a record for this email address. You can carry on — this membership will be added to it.",
			),
		).toBeInTheDocument()
		expect(
			screen.queryByText("You already have an account"),
		).not.toBeInTheDocument()
	})
})

describe("mustSignIn", () => {
	it("answers a member email with the honest sign-in message and a real link", async () => {
		const verify = examregPost("verifyCustomer", () =>
			verifyCustomerResult({ mustSignIn: true }),
		)
		server.use(verify.handler)
		const user = userEvent.setup()
		await renderForm()

		await typeIdentity(user)

		expect(
			await screen.findByText("You already have an account"),
		).toBeInTheDocument()
		// The plain warning: signing in discards what was typed here.
		expect(
			screen.getByText(
				"An account already exists for this email address. Please sign in instead — you will start again from the sign-in page, so nothing typed here is kept.",
			),
		).toBeInTheDocument()
		expect(
			screen.getByRole("link", { name: "Sign in and start again" }),
		).toHaveAttribute("href", "/Login?startUrl=%2Fregistration%2Faffiliate")
	})

	it("binds at submit: register is never called for a member email", async () => {
		const verify = examregPost("verifyCustomer", () =>
			verifyCustomerResult({ mustSignIn: true }),
		)
		const register = examregPost("register", () => ({}))
		server.use(verify.handler, register.handler)
		const user = userEvent.setup()
		const { onRegistered } = await renderForm()

		await fillAffiliateForm(user)
		await user.click(registerButton())

		expect(
			await screen.findByText("You already have an account"),
		).toBeInTheDocument()
		expect(register.spy.hits).toBe(0)
		expect(onRegistered).not.toHaveBeenCalled()
	})
})
