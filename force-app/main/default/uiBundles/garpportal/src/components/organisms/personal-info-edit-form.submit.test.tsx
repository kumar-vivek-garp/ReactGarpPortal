import { screen, within } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { describe, expect, it, vi } from "vitest"

import { PersonalInfoEditForm } from "@/components/organisms/personal-info-edit-form"
import {
	accountViewFromPersonalInfo,
	billingCompanyResolver,
	personalInfoEditData,
} from "@/testing/factories/personal-info"
import { myAccountOrg } from "@/testing/msw/handlers/account"
import { personalInfoWriteHandlers } from "@/testing/msw/handlers/personal-info"
import { sdkGraphqlHandler } from "@/testing/msw/handlers/sdk-graphql"
import { server } from "@/testing/msw/server"
import { renderWithProviders } from "@/testing/render"

function serveOrg({
	data = personalInfoEditData(),
	addressesRespond,
}: {
	data?: ReturnType<typeof personalInfoEditData>
	addressesRespond?: Parameters<typeof personalInfoWriteHandlers>[0] extends
		| { addressesRespond?: infer R }
		| undefined
		? R
		: never
} = {}) {
	const account = myAccountOrg({ view: accountViewFromPersonalInfo(data) })
	const writes = personalInfoWriteHandlers({ addressesRespond })
	server.use(
		...account.handlers,
		...writes.handlers,
		sdkGraphqlHandler(billingCompanyResolver(data)),
	)
	return { profileSpy: account.profileSpy, addressesSpy: writes.addressesSpy }
}

function renderForm() {
	const onSaved = vi.fn()
	const view = renderWithProviders(<PersonalInfoEditForm onSaved={onSaved} />)
	return { ...view, onSaved }
}

function addressSection(title: string) {
	const heading = screen.getByRole("heading", { name: title })
	return within(heading.closest("section") as HTMLElement)
}

async function save(user: ReturnType<typeof userEvent.setup>) {
	await user.click(screen.getByRole("button", { name: "Save" }))
}

describe("submitting", () => {
	it("posts only the changed identity field, then both addresses", async () => {
		const org = serveOrg()
		const user = userEvent.setup()
		const { onSaved } = renderForm()

		const firstName = await screen.findByLabelText("First name")
		await user.clear(firstName)
		await user.type(firstName, "Grace")
		await save(user)

		await vi.waitFor(() => {
			expect(onSaved).toHaveBeenCalledTimes(1)
		})
		// Only what changed; the stored mobile code survives untouched.
		expect(org.profileSpy.bodies).toEqual([{ FirstName: "Grace" }])
		expect(org.addressesSpy.bodies).toHaveLength(1)
		expect(org.addressesSpy.bodies[0]).toMatchObject({
			isBillingAndMailingAddressSame: false,
			billingAddress: { street1: "1 Main St", city: "Hoboken", phone: "5551234" },
			mailingAddress: { street1: "2 Ship St", city: "Boston" },
		})
	})

	it("skips the profile write entirely when only an address changed", async () => {
		const org = serveOrg()
		const user = userEvent.setup()
		const { onSaved } = renderForm()

		await screen.findByLabelText("First name")
		const city = addressSection("Billing address").getByLabelText("City")
		await user.clear(city)
		await user.type(city, "Jersey City")
		await save(user)

		await vi.waitFor(() => {
			expect(onSaved).toHaveBeenCalledTimes(1)
		})
		expect(org.profileSpy.hits).toBe(0)
		expect(org.addressesSpy.bodies[0].billingAddress.city).toBe("Jersey City")
	})

	it("copies billing over mailing when same-as-billing is ticked", async () => {
		const org = serveOrg()
		const user = userEvent.setup()
		const { onSaved } = renderForm()

		await screen.findByLabelText("First name")
		await user.click(
			screen.getByRole("checkbox", {
				name: "Mailing address is the same as billing address",
			}),
		)

		// The mailing controls mirror billing and lock.
		const mailing = addressSection("Mailing address")
		expect(mailing.getByLabelText("Address line 1")).toHaveValue("1 Main St")
		expect(mailing.getByLabelText("Address line 1")).toBeDisabled()
		expect(mailing.getByLabelText("City")).toHaveValue("Hoboken")

		await save(user)

		await vi.waitFor(() => {
			expect(onSaved).toHaveBeenCalledTimes(1)
		})
		const body = org.addressesSpy.bodies[0]
		expect(body.isBillingAndMailingAddressSame).toBe(true)
		expect(body.mailingAddress).toMatchObject({
			street1: "1 Main St",
			city: "Hoboken",
			state: "NJ",
			postalCode: "07030",
		})
	})

	it("frees a mailing address blanked by the org — disabled fields stop validating", async () => {
		const org = serveOrg({
			data: personalInfoEditData({
				mailing: {
					company: "",
					address1: "",
					address2: "",
					address3: "",
					country: "",
					city: "",
					state: "",
					postalCode: "",
					phone: "",
				},
			}),
		})
		const user = userEvent.setup()
		const { onSaved } = renderForm()

		await screen.findByLabelText("First name")
		// Without the tick the empty mailing block blocks the save…
		await user.click(screen.getByRole("button", { name: "Save" }))
		const mailing = addressSection("Mailing address")
		expect(await mailing.findByText("Address is required")).toBeInTheDocument()
		expect(org.addressesSpy.hits).toBe(0)

		// …and with it the requirement follows the disabled state.
		await user.click(
			screen.getByRole("checkbox", {
				name: "Mailing address is the same as billing address",
			}),
		)
		await save(user)

		await vi.waitFor(() => {
			expect(onSaved).toHaveBeenCalledTimes(1)
		})
		expect(org.addressesSpy.hits).toBe(1)
	})

	it("keeps the dialog open and re-enables Save when the org refuses", async () => {
		const org = serveOrg({
			addressesRespond: () => ({
				statusMessage: "Contact updated; Account billing address failed.",
				statusCode: 501,
				appliedBillingToMailing: false,
			}),
		})
		const user = userEvent.setup()
		const { onSaved } = renderForm()

		await screen.findByLabelText("First name")
		await save(user)

		await vi.waitFor(() => {
			expect(org.addressesSpy.hits).toBe(1)
		})
		expect(onSaved).not.toHaveBeenCalled()
		// The draft survives for another attempt.
		expect(screen.getByLabelText("First name")).toHaveValue("Ada")
		await vi.waitFor(() => {
			expect(screen.getByRole("button", { name: "Save" })).toBeEnabled()
		})
	})
})
