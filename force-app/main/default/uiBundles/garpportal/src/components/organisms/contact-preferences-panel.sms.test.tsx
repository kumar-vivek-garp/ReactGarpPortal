import { screen, waitFor } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { http, HttpResponse } from "msw"
import { describe, expect, it } from "vitest"

import type { AccountProfileValues } from "@/api/account/save-profile"
import { ContactPreferencesPanel } from "@/components/organisms/contact-preferences-panel"
import { accountView, completeness } from "@/testing/factories/account"
import { memberPortalEnvelope } from "@/testing/factories/envelope"
import { myAccountOrg, PROFILE_PATH } from "@/testing/msw/handlers/account"
import { server } from "@/testing/msw/server"
import { renderWithProviders } from "@/testing/render"

type SmsState = { smsPromotional: boolean; smsRegistration: boolean }

/**
 * A tiny stateful org: the profile write changes what the next account read
 * returns, so the post-save cache invalidation refetches the value the member
 * just chose rather than snapping back to the fixture's initial one.
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
	const updates: AccountProfileValues[] = []

	const org = myAccountOrg({
		view: () =>
			accountView({
				personal: {
					email: "ada@example.com",
					mobilePhone: "5551234567",
					mobilePhoneCode: "United States (+1)",
				},
				preferences: { ...state },
			}),
	})
	// First wins in MSW, so the stateful write shadows the org's default one.
	server.use(
		http.post(PROFILE_PATH, async ({ request }) => {
			const body = (await request.json()) as { values: AccountProfileValues }
			updates.push(body.values)
			if (gate) await gate
			if (fail) {
				return HttpResponse.json(
					memberPortalEnvelope({
						applied: [],
						rejected: Object.keys(body.values),
						completeness: completeness(),
					}),
				)
			}
			state.smsPromotional = body.values.SMS_Promotional_Updates__c === true
			state.smsRegistration = body.values.SMS_Registration_Updates__c === true
			return HttpResponse.json(
				memberPortalEnvelope({
					applied: Object.keys(body.values),
					rejected: [],
					completeness: completeness(),
				}),
			)
		}),
		...org.handlers,
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
		const { queryClient } = renderWithProviders(<ContactPreferencesPanel />)
		await screen.findByText("ada@example.com")

		expect(registrationBox()).not.toBeChecked()
		await user.click(registrationBox())

		await waitFor(() => expect(registrationBox()).toBeEnabled())
		await waitFor(() => expect(queryClient.isFetching()).toBe(0))
		expect(registrationBox()).toBeChecked()
		// Both flags travel together — the untouched one keeps its value.
		expect(updates[0]).toEqual({
			SMS_Promotional_Updates__c: false,
			SMS_Registration_Updates__c: true,
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
		renderWithProviders(<ContactPreferencesPanel />)
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
		renderWithProviders(<ContactPreferencesPanel />)
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
		renderWithProviders(<ContactPreferencesPanel />)
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
		renderWithProviders(<ContactPreferencesPanel />)
		await screen.findByText("ada@example.com")

		await user.click(promotionalBox())

		await waitFor(() => expect(promotionalBox()).toBeEnabled())
		expect(updates[0]).toEqual({
			SMS_Promotional_Updates__c: true,
			SMS_Registration_Updates__c: true,
		})
	})
})

describe("ContactPreferencesPanel — the SMS card's save indicator", () => {
	/*
	 * These boxes autosave, and the only confirmation used to be a global toast
	 * that appears away from the box the member just clicked. The card header now
	 * says so in place, matching the autosaving cards on Account Information.
	 */
	it("says Saving while the write is in flight, then Saved", async () => {
		let release!: () => void
		smsOrg({
			gate: new Promise<void>((resolve) => {
				release = resolve
			}),
		})
		const user = userEvent.setup()
		renderWithProviders(<ContactPreferencesPanel />)
		await screen.findByText("ada@example.com")

		// Nothing has been saved yet, so the header carries no status.
		expect(screen.queryByText("Saving…")).not.toBeInTheDocument()
		expect(screen.queryByText("Saved")).not.toBeInTheDocument()

		await user.click(registrationBox())
		expect(await screen.findByText("Saving…")).toBeInTheDocument()

		release()
		expect(await screen.findByText("Saved")).toBeInTheDocument()
		expect(screen.queryByText("Saving…")).not.toBeInTheDocument()
	})
})
