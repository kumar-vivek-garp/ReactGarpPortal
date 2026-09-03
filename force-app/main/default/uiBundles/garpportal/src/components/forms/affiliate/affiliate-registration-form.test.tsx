import { screen } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { describe, expect, it, vi } from "vitest"

import { AffiliateRegistrationForm } from "@/components/forms/affiliate/affiliate-registration-form"
import {
	fillAffiliateForm,
	registerButton,
} from "@/testing/affiliate-form"
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

/** Every fill blurs a valid email, and MSW runs strict — answer the check. */
function stubVerify() {
	const verify = examregPost("verifyCustomer", () => verifyCustomerResult())
	server.use(verify.handler)
	return verify
}

describe("AffiliateRegistrationForm chrome", () => {
	it("titles the page with the h1 and the constant Free total", async () => {
		await renderForm()

		expect(
			screen.getByRole("heading", {
				level: 1,
				name: "Affiliate Membership Registration",
			}),
		).toBeInTheDocument()
		// The bar and the rail both state it — the figure is a constant.
		expect(screen.getAllByText("Free").length).toBeGreaterThan(0)
	})

	it("offers sign-in up front, carrying the return path — and no back link", async () => {
		await renderForm()

		const signIn = screen.getByRole("link", {
			name: "Already have an account? Sign in",
		})
		expect(signIn).toHaveAttribute(
			"href",
			"/Login?startUrl=%2Fregistration%2Faffiliate",
		)
		// Guest-only route: every in-app parent is behind the session guard.
		expect(
			screen.queryByRole("link", { name: /back/i }),
		).not.toBeInTheDocument()
	})
})

describe("AffiliateRegistrationForm submit gating", () => {
	it("disables submit on the empty form, with a hint in the title", async () => {
		await renderForm()

		const button = registerButton()
		expect(button).toBeDisabled()
		expect(button).toHaveAttribute(
			"title",
			"Complete the required fields to continue.",
		)
	})

	it("enables once every required answer is in, then disables again when one is removed", async () => {
		stubVerify()
		const user = userEvent.setup()
		await renderForm()

		await fillAffiliateForm(user)
		expect(registerButton()).toBeEnabled()
		expect(registerButton()).not.toHaveAttribute("title")

		await user.clear(screen.getByRole("textbox", { name: /first name/i }))
		expect(registerButton()).toBeDisabled()
		expect(
			screen.getByText("Please enter your first name / given name."),
		).toBeInTheDocument()
	})

	it("stays disabled while a field is invalid, with the error inline", async () => {
		stubVerify()
		const user = userEvent.setup()
		await renderForm()

		await fillAffiliateForm(user, { mobilePhone: "12345" })
		// `onTouched` shows the error only once the field blurs.
		await user.tab()
		expect(registerButton()).toBeDisabled()
		expect(
			screen.getByText("Please enter between 7 and 15 numbers."),
		).toBeInTheDocument()
	})

	it("rejects a non-English name character-for-character", async () => {
		stubVerify()
		const user = userEvent.setup()
		await renderForm()

		await fillAffiliateForm(user, { firstName: "Ada7" })
		expect(
			screen.getByText("Please enter only English characters."),
		).toBeInTheDocument()
		expect(registerButton()).toBeDisabled()
	})

	it("flags an invalid email on blur, not while typing", async () => {
		const user = userEvent.setup()
		await renderForm()

		const email = screen.getByRole("textbox", { name: /email address/i })
		await user.type(email, "not-an-email")
		expect(
			screen.queryByText("Please enter a valid email address."),
		).not.toBeInTheDocument()

		await user.tab()
		expect(
			screen.getByText("Please enter a valid email address."),
		).toBeInTheDocument()
	})
})
