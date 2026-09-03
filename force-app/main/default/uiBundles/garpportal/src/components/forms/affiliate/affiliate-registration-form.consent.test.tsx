import { screen } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { describe, expect, it, vi } from "vitest"

import type { AffiliateRegisterRequest } from "@/api/registration"
import { AffiliateRegistrationForm } from "@/components/forms/affiliate/affiliate-registration-form"
import {
	fillAffiliateForm,
	pickRadixOption,
	registerButton,
} from "@/testing/affiliate-form"
import {
	affiliateLoad,
	affiliateRegisterResult,
} from "@/testing/factories/affiliate"
import { verifyCustomerResult } from "@/testing/factories/exam"
import { examregPost } from "@/testing/msw/handlers/examreg"
import { server } from "@/testing/msw/server"
import { renderWithRouterProviders } from "@/testing/router"
import { skipSpringAnimations } from "@/testing/springs"

skipSpringAnimations()

const POLICY_TICKS = [
	/privacy notice/i,
	/limitation of liability/i,
	/waiver and release/i,
]

async function renderForm() {
	const onRegistered = vi.fn()
	const rendered = await renderWithRouterProviders(
		<AffiliateRegistrationForm load={affiliateLoad()} onRegistered={onRegistered} />,
		{ path: "/registration/affiliate" },
	)
	return { ...rendered, onRegistered }
}

function stubVerify() {
	const verify = examregPost("verifyCustomer", () => verifyCustomerResult())
	server.use(verify.handler)
	return verify
}

describe("consents", () => {
	it("starts the promotional SMS opt-in unticked", async () => {
		await renderForm()

		expect(
			screen.getByRole("checkbox", { name: /promotional text messages/i }),
		).not.toBeChecked()
	})

	it("shows the implicit notice, not ticks, for a non-compliance country", async () => {
		stubVerify()
		const user = userEvent.setup()
		await renderForm()

		await fillAffiliateForm(user, { countryName: "United States" })

		for (const name of POLICY_TICKS) {
			expect(screen.queryByRole("checkbox", { name })).not.toBeInTheDocument()
		}
		expect(
			screen.getByText(/by selecting/i, { exact: false }),
		).toBeInTheDocument()
		expect(registerButton()).toBeEnabled()
	})

	it("requires three unticked-by-default policy ticks for a compliance country", async () => {
		stubVerify()
		const user = userEvent.setup()
		await renderForm()

		await fillAffiliateForm(user, {
			countryName: "Germany",
			phoneCodeOption: "Germany (+49)",
		})

		const ticks = POLICY_TICKS.map((name) =>
			screen.getByRole("checkbox", { name }),
		)
		for (const tick of ticks) {
			expect(tick).not.toBeChecked()
		}
		expect(registerButton()).toBeDisabled()

		for (const tick of ticks) {
			await user.click(tick)
		}
		expect(registerButton()).toBeEnabled()
	})

	it("re-enables submit when switching to a non-compliance country with ticks unmade", async () => {
		stubVerify()
		const user = userEvent.setup()
		await renderForm()

		await fillAffiliateForm(user, {
			countryName: "Germany",
			phoneCodeOption: "Germany (+49)",
		})
		expect(registerButton()).toBeDisabled()

		// Unmounted fields stop counting towards `isValid` — nobody is stranded
		// behind a rule with no visible control to satisfy it.
		await pickRadixOption(
			user,
			screen.getByRole("combobox", { name: /location/i }),
			"United States",
		)
		expect(registerButton()).toBeEnabled()
	})

	it("collapses the three ticks into one consent on the wire", async () => {
		stubVerify()
		const register = examregPost<AffiliateRegisterRequest>("register", () =>
			affiliateRegisterResult(),
		)
		const pay = examregPost("payOrder", () => ({ completed: true }))
		server.use(register.handler, pay.handler)

		const user = userEvent.setup()
		const { onRegistered } = await renderForm()

		await fillAffiliateForm(user, {
			countryName: "Germany",
			phoneCodeOption: "Germany (+49)",
		})
		for (const name of POLICY_TICKS) {
			await user.click(screen.getByRole("checkbox", { name }))
		}
		await user.click(
			screen.getByRole("checkbox", { name: /promotional text messages/i }),
		)
		await user.click(registerButton())

		await vi.waitFor(() => {
			expect(onRegistered).toHaveBeenCalledTimes(1)
		})
		expect(register.spy.bodies[0].consent).toEqual({ privacyPolicy: true })
		expect(register.spy.bodies[0].billingAddress).toEqual({
			country: "Germany",
		})
		expect(register.spy.bodies[0].customer.smsPromotionalUpdates).toBe(true)
	})

	it("offers only countries with a dial code as phone codes", async () => {
		const user = userEvent.setup()
		await renderForm()

		await user.click(
			screen.getByRole("combobox", { name: /mobile phone country code/i }),
		)

		expect(
			await screen.findByRole("option", { name: "United States (+1)" }),
		).toBeInTheDocument()
		expect(
			screen.getByRole("option", { name: "Germany (+49)" }),
		).toBeInTheDocument()
		// Atlantis has no dial code, so it must not be offered here…
		expect(
			screen.queryByRole("option", { name: /atlantis/i }),
		).not.toBeInTheDocument()
	})
})
