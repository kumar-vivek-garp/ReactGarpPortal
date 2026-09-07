import { screen, waitFor } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { http, HttpResponse } from "msw"
import { describe, expect, it } from "vitest"

import { ContactPreferencesPanel } from "@/components/organisms/contact-preferences-panel"
import { accountView } from "@/testing/factories/account"
import { memberPortalError } from "@/testing/factories/envelope"
import { ACCOUNT_PATH, myAccountOrg } from "@/testing/msw/handlers/account"
import { emailPreferenceHandler } from "@/testing/msw/handlers/contact-preferences"
import { server } from "@/testing/msw/server"
import { renderWithProviders } from "@/testing/render"

const EMAIL_SUCCESS =
	"An email has been sent to your account with instructions on how to update your preferences."

type Personal = {
	email?: string | null
	mobilePhone?: string | null
	mobilePhoneCode?: string | null
}

/** The account view the tab reads, with the display fields under test. */
function serveAccount({
	email = "ada@example.com",
	mobilePhone = "5551234567",
	mobilePhoneCode = "United States (+1)",
}: Personal = {}) {
	server.use(
		...myAccountOrg({
			view: accountView({ personal: { email, mobilePhone, mobilePhoneCode } }),
		}).handlers,
	)
}

describe("ContactPreferencesPanel — loading and display", () => {
	it("shows the contact's email and the dialing code from the stored location", async () => {
		serveAccount()
		renderWithProviders(<ContactPreferencesPanel />)

		expect(await screen.findByText("ada@example.com")).toBeInTheDocument()
		expect(screen.getByText("+1 5551234567")).toBeInTheDocument()
	})

	it("still shows a bare legacy code with a plus", async () => {
		serveAccount({ mobilePhoneCode: "44" })
		renderWithProviders(<ContactPreferencesPanel />)

		expect(await screen.findByText("+44 5551234567")).toBeInTheDocument()
	})

	it("falls back to em dashes when the contact has no email or mobile", async () => {
		serveAccount({ email: null, mobilePhone: null })
		renderWithProviders(<ContactPreferencesPanel />)

		expect(await screen.findAllByText("—")).toHaveLength(2)
	})

	it("reports a failed load instead of rendering empty preferences", async () => {
		server.use(
			http.get(ACCOUNT_PATH, () =>
				HttpResponse.json(memberPortalError(500, "no access"), { status: 500 }),
			),
		)
		renderWithProviders(<ContactPreferencesPanel />)

		expect(
			await screen.findByText(/couldn't load your contact preferences/i),
		).toBeInTheDocument()
		expect(screen.queryByRole("checkbox")).not.toBeInTheDocument()
	})
})

describe("ContactPreferencesPanel — the one-shot email request", () => {
	it("swaps the button for the confirmation, and it stays swapped", async () => {
		serveAccount()
		const email = emailPreferenceHandler()
		server.use(email.handler)
		const user = userEvent.setup()
		const { queryClient } = renderWithProviders(<ContactPreferencesPanel />)

		await user.click(
			await screen.findByRole("button", { name: /manage email preferences/i }),
		)

		expect(await screen.findByText(EMAIL_SUCCESS)).toBeInTheDocument()
		expect(email.spy.hits).toBe(1)
		// Success invalidates the account cache; the refetch must not resurrect
		// the button — the latch is component state, not server state.
		await waitFor(() => expect(queryClient.isFetching()).toBe(0))
		expect(
			screen.queryByRole("button", { name: /manage email preferences/i }),
		).not.toBeInTheDocument()
		expect(screen.getByText(EMAIL_SUCCESS)).toBeInTheDocument()
	})

	it("disables everything while the request is in flight", async () => {
		let release!: () => void
		const gate = new Promise<void>((resolve) => {
			release = resolve
		})
		serveAccount()
		server.use(
			http.post(
				"/services/apexrest/memberportal/emailPreferenceUpdate",
				async () => {
					await gate
					return HttpResponse.json({
						status: "Success",
						statusCode: 200,
						errorMessage: null,
						data: { statusMessage: "Email Pref Date Updated", statusCode: 200 },
					})
				},
			),
		)
		const user = userEvent.setup()
		renderWithProviders(<ContactPreferencesPanel />)

		await user.click(
			await screen.findByRole("button", { name: /manage email preferences/i }),
		)

		const pending = await screen.findByRole("button", {
			name: /processing your request/i,
		})
		expect(pending).toBeDisabled()
		// isBusy also locks the SMS checkboxes against a concurrent write.
		expect(
			screen.getByRole("checkbox", { name: /time-sensitive/i }),
		).toBeDisabled()

		release()
		expect(await screen.findByText(EMAIL_SUCCESS)).toBeInTheDocument()
	})

	it("keeps the button on failure so the member can try again", async () => {
		serveAccount()
		server.use(
			emailPreferenceHandler(() => ({
				statusMessage: "flow is broken",
				statusCode: 501,
			})).handler,
		)
		const user = userEvent.setup()
		renderWithProviders(<ContactPreferencesPanel />)

		await user.click(
			await screen.findByRole("button", { name: /manage email preferences/i }),
		)

		// Post-settle the button is back and enabled (it is disabled in flight),
		// and no confirmation was latched.
		const manage = await screen.findByRole("button", {
			name: /manage email preferences/i,
		})
		await waitFor(() => expect(manage).toBeEnabled())
		expect(screen.queryByText(EMAIL_SUCCESS)).not.toBeInTheDocument()
	})
})

describe("ContactPreferencesPanel — editing contact information", () => {
	/*
	 * The card used to be read-only. It now opens the SAME editor Account
	 * Information uses, rather than a second one: `savePersonalInfo` already
	 * writes these exact fields, and the save invalidates the composed account
	 * view this card reads from, so the values come back here on their own.
	 */
	it("offers an Edit control that opens the personal information dialog", async () => {
		serveAccount()
		const user = userEvent.setup()
		renderWithProviders(<ContactPreferencesPanel />)
		await screen.findByText("ada@example.com")

		await user.click(screen.getByRole("button", { name: "Edit" }))

		expect(
			await screen.findByRole("dialog", { name: "Edit Personal Information" }),
		).toBeInTheDocument()
	})

	it("keeps the fields read-only until the dialog is asked for", async () => {
		serveAccount()
		renderWithProviders(<ContactPreferencesPanel />)
		await screen.findByText("ada@example.com")

		expect(screen.queryByRole("dialog")).not.toBeInTheDocument()
	})
})
