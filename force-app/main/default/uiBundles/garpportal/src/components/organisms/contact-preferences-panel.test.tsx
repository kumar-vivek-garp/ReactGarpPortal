import { screen, waitFor } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { describe, expect, it } from "vitest"

import { ContactPreferencesPanel } from "@/components/organisms/contact-preferences-panel"
import { server } from "@/testing/msw/server"
import { sdkGraphqlHandler } from "@/testing/msw/handlers/sdk-graphql"
import { renderWithProviders } from "@/testing/render"

const CONTACT_ID = "003XX0000012345"
const EMAIL_SUCCESS =
	"An email has been sent to your account with instructions on how to update your preferences."

type PrefsNode = {
	smsPromotional?: boolean
	smsRegistration?: boolean
	email?: string | null
	mobilePhone?: string | null
	mobilePhoneCode?: string | null
}

function queryResult({
	smsPromotional = false,
	smsRegistration = false,
	email = "ada@example.com",
	mobilePhone = "5551234567",
	mobilePhoneCode = "1",
}: PrefsNode = {}) {
	return {
		data: {
			uiapi: {
				query: {
					Contact: {
						edges: [
							{
								node: {
									Id: CONTACT_ID,
									Email: { value: email },
									MobilePhone: { value: mobilePhone },
									Mobile_Phone_Code__c: { value: mobilePhoneCode },
									SMS_Promotional_Updates__c: { value: smsPromotional },
									SMS_Registration_Updates__c: { value: smsRegistration },
								},
							},
						],
					},
				},
			},
		},
	}
}

const emailSuccessResult = {
	data: { uiapi: { ContactUpdate: { success: true } } },
}

describe("ContactPreferencesPanel — loading and display", () => {
	it("shows the contact's email and combined mobile number once loaded", async () => {
		server.use(sdkGraphqlHandler({ ContactPreferences: () => queryResult() }))
		renderWithProviders(<ContactPreferencesPanel contactId={CONTACT_ID} />)

		expect(await screen.findByText("ada@example.com")).toBeInTheDocument()
		expect(screen.getByText("+1 5551234567")).toBeInTheDocument()
	})

	it("falls back to em dashes when the contact has no email or mobile", async () => {
		server.use(
			sdkGraphqlHandler({
				ContactPreferences: () =>
					queryResult({ email: null, mobilePhone: null, mobilePhoneCode: "1" }),
			}),
		)
		renderWithProviders(<ContactPreferencesPanel contactId={CONTACT_ID} />)

		expect(await screen.findAllByText("—")).toHaveLength(2)
	})

	it("reports a failed load instead of rendering empty preferences", async () => {
		server.use(
			sdkGraphqlHandler({
				ContactPreferences: () => ({ errors: [{ message: "no access" }] }),
			}),
		)
		renderWithProviders(<ContactPreferencesPanel contactId={CONTACT_ID} />)

		expect(
			await screen.findByText(/couldn't load your contact preferences/i),
		).toBeInTheDocument()
		expect(screen.queryByRole("checkbox")).not.toBeInTheDocument()
	})
})

describe("ContactPreferencesPanel — the one-shot email request", () => {
	it("swaps the button for the confirmation, and it stays swapped", async () => {
		server.use(
			sdkGraphqlHandler({
				ContactPreferences: () => queryResult(),
				RequestEmailPreferences: () => emailSuccessResult,
			}),
		)
		const user = userEvent.setup()
		const { queryClient } = renderWithProviders(
			<ContactPreferencesPanel contactId={CONTACT_ID} />,
		)

		await user.click(
			await screen.findByRole("button", { name: /manage email preferences/i }),
		)

		expect(await screen.findByText(EMAIL_SUCCESS)).toBeInTheDocument()
		// Success invalidates the prefs cache; the refetch must not resurrect
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
		server.use(
			sdkGraphqlHandler({
				ContactPreferences: () => queryResult(),
				RequestEmailPreferences: async () => {
					await gate
					return emailSuccessResult
				},
			}),
		)
		const user = userEvent.setup()
		renderWithProviders(<ContactPreferencesPanel contactId={CONTACT_ID} />)

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
		server.use(
			sdkGraphqlHandler({
				ContactPreferences: () => queryResult(),
				RequestEmailPreferences: () => ({
					errors: [{ message: "flow is broken" }],
				}),
			}),
		)
		const user = userEvent.setup()
		renderWithProviders(<ContactPreferencesPanel contactId={CONTACT_ID} />)

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
