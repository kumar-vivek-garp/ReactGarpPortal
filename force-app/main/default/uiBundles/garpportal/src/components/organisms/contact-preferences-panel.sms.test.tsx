import { screen, waitFor } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { describe, expect, it } from "vitest"

import { ContactPreferencesPanel } from "@/components/organisms/contact-preferences-panel"
import { server } from "@/testing/msw/server"
import { sdkGraphqlHandler } from "@/testing/msw/handlers/sdk-graphql"
import { renderWithProviders } from "@/testing/render"

const CONTACT_ID = "003XX0000012345"

type SmsState = { smsPromotional: boolean; smsRegistration: boolean }

/**
 * A tiny stateful org: the mutation writes what the next query reads, so the
 * post-save cache invalidation refetches the value the member just chose
 * rather than snapping back to the fixture's initial one.
 */
function smsOrg({
	initial = { smsPromotional: false, smsRegistration: false },
	gate,
	fail = false,
}: {
	initial?: SmsState
	/** The mutation blocks on this until the test releases it. */
	gate?: Promise<void>
	fail?: boolean
} = {}) {
	const state: SmsState = { ...initial }
	const updates: Array<Record<string, unknown>> = []

	server.use(
		sdkGraphqlHandler({
			ContactPreferences: () => ({
				data: {
					uiapi: {
						query: {
							Contact: {
								edges: [
									{
										node: {
											Id: CONTACT_ID,
											Email: { value: "ada@example.com" },
											MobilePhone: { value: "5551234567" },
											Mobile_Phone_Code__c: { value: "1" },
											SMS_Promotional_Updates__c: {
												value: state.smsPromotional,
											},
											SMS_Registration_Updates__c: {
												value: state.smsRegistration,
											},
										},
									},
								],
							},
						},
					},
				},
			}),
			UpdateSmsPreferences: async (variables) => {
				updates.push(variables)
				if (gate) await gate
				if (fail) return { errors: [{ message: "SMS provider is down" }] }
				state.smsPromotional = variables.smsPromotional === true
				state.smsRegistration = variables.smsRegistration === true
				return {
					data: {
						uiapi: {
							ContactUpdate: {
								success: true,
								Record: {
									SMS_Promotional_Updates__c: {
										value: state.smsPromotional,
									},
									SMS_Registration_Updates__c: {
										value: state.smsRegistration,
									},
								},
							},
						},
					},
				}
			},
		}),
	)

	return { state, updates }
}

const registrationBox = () =>
	screen.getByRole("checkbox", { name: /time-sensitive/i })
const promotionalBox = () =>
	screen.getByRole("checkbox", { name: /marketing and promotional/i })

describe("ContactPreferencesPanel — SMS optimistic toggle", () => {
	it("ticks immediately, then the server write confirms and it stays ticked", async () => {
		const { updates } = smsOrg()
		const user = userEvent.setup()
		const { queryClient } = renderWithProviders(
			<ContactPreferencesPanel contactId={CONTACT_ID} />,
		)
		await screen.findByText("ada@example.com")

		expect(registrationBox()).not.toBeChecked()
		await user.click(registrationBox())

		await waitFor(() => expect(registrationBox()).toBeEnabled())
		await waitFor(() => expect(queryClient.isFetching()).toBe(0))
		expect(registrationBox()).toBeChecked()
		// Both flags travel together — the untouched one keeps its value.
		expect(updates[0]).toMatchObject({
			contactId: CONTACT_ID,
			smsPromotional: false,
			smsRegistration: true,
		})
	})

	it("shows the draft and locks both boxes while the write is in flight", async () => {
		let release!: () => void
		smsOrg({
			gate: new Promise<void>((resolve) => {
				release = resolve
			}),
		})
		const user = userEvent.setup()
		renderWithProviders(<ContactPreferencesPanel contactId={CONTACT_ID} />)
		await screen.findByText("ada@example.com")

		await user.click(registrationBox())

		// The tick shows before the server has answered …
		expect(registrationBox()).toBeChecked()
		// … and neither preference can be changed underneath the save.
		expect(registrationBox()).toBeDisabled()
		expect(promotionalBox()).toBeDisabled()

		release()
		await waitFor(() => expect(registrationBox()).toBeEnabled())
		expect(registrationBox()).toBeChecked()
	})

	it("reverts the tick when the server refuses the write", async () => {
		smsOrg({ fail: true })
		const user = userEvent.setup()
		renderWithProviders(<ContactPreferencesPanel contactId={CONTACT_ID} />)
		await screen.findByText("ada@example.com")

		await user.click(registrationBox())

		// In flight the box is ticked and locked; a settled failure unlocks it
		// with the tick rolled back.
		await waitFor(() => expect(registrationBox()).toBeEnabled())
		expect(registrationBox()).not.toBeChecked()
		expect(promotionalBox()).not.toBeChecked()
	})

	it("reverting one toggle does not disturb the other's saved value", async () => {
		smsOrg({
			initial: { smsPromotional: true, smsRegistration: false },
			fail: true,
		})
		const user = userEvent.setup()
		renderWithProviders(<ContactPreferencesPanel contactId={CONTACT_ID} />)
		await screen.findByText("ada@example.com")
		expect(promotionalBox()).toBeChecked()

		await user.click(registrationBox())

		await waitFor(() => expect(registrationBox()).toBeEnabled())
		expect(registrationBox()).not.toBeChecked()
		expect(promotionalBox()).toBeChecked()
	})

	it("the promotional toggle carries the registration value along unchanged", async () => {
		const { updates } = smsOrg({
			initial: { smsPromotional: false, smsRegistration: true },
		})
		const user = userEvent.setup()
		renderWithProviders(<ContactPreferencesPanel contactId={CONTACT_ID} />)
		await screen.findByText("ada@example.com")

		await user.click(promotionalBox())

		await waitFor(() => expect(promotionalBox()).toBeEnabled())
		expect(updates[0]).toMatchObject({
			contactId: CONTACT_ID,
			smsPromotional: true,
			smsRegistration: true,
		})
	})
})
