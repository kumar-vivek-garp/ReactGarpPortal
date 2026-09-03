import { screen, within } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { describe, expect, it, vi } from "vitest"

import type { CountryOption } from "@/api/personal-info/types"
import { PersonalInfoEditForm } from "@/components/organisms/personal-info-edit-form"
import { personalInfoEditData } from "@/testing/factories/personal-info"
import { personalInfoGraphqlResolvers } from "@/testing/factories/personal-info-graphql"
import { sdkGraphqlHandler } from "@/testing/msw/handlers/sdk-graphql"
import { server } from "@/testing/msw/server"
import { renderWithProviders } from "@/testing/render"

const COUNTRIES: CountryOption[] = [
	{ label: "United States", value: "United States", phoneCode: "+1" },
	{ label: "United Kingdom", value: "United Kingdom", phoneCode: "+44" },
]

/** One handler carrying both reads plus a save spy — later `use` calls shadow. */
function serveOrg(data = personalInfoEditData()) {
	const saves: Array<Record<string, unknown>> = []
	server.use(
		sdkGraphqlHandler({
			...personalInfoGraphqlResolvers(data, COUNTRIES),
			SavePersonalInfo: (variables) => {
				saves.push(variables)
				return {
					data: {
						uiapi: {
							AccountUpdate: { success: true },
							ContactUpdate: { success: true },
						},
					},
				}
			},
		}),
	)
	return { saves }
}

function renderForm(contactId = "003-member") {
	const onSaved = vi.fn()
	const view = renderWithProviders(
		<PersonalInfoEditForm contactId={contactId} onSaved={onSaved} />,
	)
	return { ...view, onSaved }
}

function addressSection(title: string) {
	const heading = screen.getByRole("heading", { name: title })
	return within(heading.closest("section") as HTMLElement)
}

async function findSaveButton() {
	return await screen.findByRole("button", { name: "Save" })
}

describe("hydration", () => {
	it("seeds identity and both addresses from the org", async () => {
		serveOrg()
		renderForm()

		expect(await screen.findByLabelText("First name")).toHaveValue("Ada")
		expect(screen.getByLabelText("Last name")).toHaveValue("Lovelace")
		expect(screen.getByLabelText("Email")).toHaveValue("ada@example.org")
		expect(screen.getByLabelText("Mobile number")).toHaveValue("5551234")
		/*
		 * Pins a suspected defect, deliberately: the mobile-code Select is the
		 * one Select here WITHOUT the remount `key` workaround, so when the
		 * stored "+1" arrives it latches onto the placeholder — and, worse, the
		 * stored code is wiped on save (see the submit suite). Flip these
		 * assertions to "+1" when the form is fixed.
		 */
		expect(
			screen.getByRole("combobox", { name: "Mobile country code" }),
		).toHaveTextContent("Select country code")

		const billing = addressSection("Billing address")
		expect(billing.getByLabelText("Address line 1")).toHaveValue("1 Main St")
		expect(billing.getByLabelText("City")).toHaveValue("Hoboken")
		expect(billing.getByRole("combobox", { name: "Country" })).toHaveTextContent(
			"United States",
		)

		// The factory's mailing differs from billing, so the tick starts off and
		// the mailing block stays editable with its own values.
		const mailing = addressSection("Mailing address")
		expect(mailing.getByLabelText("Address line 1")).toHaveValue("2 Ship St")
		expect(mailing.getByLabelText("Address line 1")).toBeEnabled()
		expect(
			screen.getByRole("checkbox", {
				name: "Mailing address is the same as billing address",
			}),
		).not.toBeChecked()
	})

	it("admits a failed load in words and keeps Save locked", async () => {
		server.use(
			sdkGraphqlHandler({
				PersonalInfoEditContact: () => ({
					errors: [{ message: "Contact not accessible" }],
				}),
				PersonalInfoCountries:
					personalInfoGraphqlResolvers(personalInfoEditData(), COUNTRIES)
						.PersonalInfoCountries,
			}),
		)
		renderForm()

		expect(
			await screen.findByText(/couldn't load your personal information/),
		).toBeInTheDocument()
		expect(await findSaveButton()).toBeDisabled()
	})

	it("explains a contact with no billing account instead of half a form", async () => {
		serveOrg(personalInfoEditData({ accountId: null, sameAsBilling: false }))
		renderForm()

		expect(
			await screen.findByText(/Billing account is unavailable/),
		).toBeInTheDocument()
		expect(screen.queryByLabelText("First name")).not.toBeInTheDocument()
		expect(await findSaveButton()).toBeDisabled()
	})
})

describe("validation", () => {
	it("requires first name, last name and email, and sends nothing", async () => {
		const org = serveOrg()
		const user = userEvent.setup()
		const { onSaved } = renderForm()

		await user.clear(await screen.findByLabelText("First name"))
		await user.clear(screen.getByLabelText("Last name"))
		await user.clear(screen.getByLabelText("Email"))
		await user.click(await findSaveButton())

		expect(await screen.findByText("First name is required")).toBeInTheDocument()
		expect(screen.getByText("Last name is required")).toBeInTheDocument()
		expect(screen.getByText("Email is required")).toBeInTheDocument()
		expect(org.saves).toHaveLength(0)
		expect(onSaved).not.toHaveBeenCalled()
	})

	it("rejects a malformed email inline", async () => {
		const org = serveOrg()
		const user = userEvent.setup()
		renderForm()

		const email = await screen.findByLabelText("Email")
		await user.clear(email)
		await user.type(email, "not-an-email")
		await user.click(await findSaveButton())

		expect(
			await screen.findByText("Enter a valid email address"),
		).toBeInTheDocument()
		expect(email).toHaveAttribute("aria-invalid", "true")
		expect(org.saves).toHaveLength(0)
	})

	it("requires the billing address lines the org demands", async () => {
		const org = serveOrg()
		const user = userEvent.setup()
		renderForm()

		await screen.findByLabelText("First name")
		const billing = addressSection("Billing address")
		await user.clear(billing.getByLabelText("Address line 1"))
		await user.clear(billing.getByLabelText("City"))
		await user.clear(billing.getByLabelText("Postal code"))
		await user.click(await findSaveButton())

		expect(await billing.findByText("Address is required")).toBeInTheDocument()
		expect(billing.getByText("City is required")).toBeInTheDocument()
		expect(billing.getByText("Postal code is required")).toBeInTheDocument()
		expect(org.saves).toHaveLength(0)
	})
})
