import { screen, within } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { http, HttpResponse } from "msw"
import { describe, expect, it, vi } from "vitest"

import { PersonalInfoEditForm } from "@/components/organisms/personal-info-edit-form"
import { memberPortalError } from "@/testing/factories/envelope"
import {
	accountViewFromPersonalInfo,
	billingCompanyResolver,
	personalInfoEditData,
} from "@/testing/factories/personal-info"
import { ACCOUNT_PATH, myAccountOrg } from "@/testing/msw/handlers/account"
import { personalInfoWriteHandlers } from "@/testing/msw/handlers/personal-info"
import { sdkGraphqlHandler } from "@/testing/msw/handlers/sdk-graphql"
import { server } from "@/testing/msw/server"
import { renderWithProviders } from "@/testing/render"

/**
 * The whole org surface the dialog touches: the account + options reads, the
 * billing-company read, and spies on the two writes — later `use` calls shadow.
 */
function serveOrg(data = personalInfoEditData()) {
	const account = myAccountOrg({ view: accountViewFromPersonalInfo(data) })
	const writes = personalInfoWriteHandlers()
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
		// The stored code is one of the org's own option strings, so the
		// Select shows it rather than latching onto its placeholder.
		expect(
			screen.getByRole("combobox", { name: "Mobile country code" }),
		).toHaveTextContent("United States (+1)")

		const billing = addressSection("Billing address")
		expect(billing.getByLabelText("Address line 1")).toHaveValue("1 Main St")
		expect(billing.getByLabelText("City")).toHaveValue("Hoboken")
		expect(billing.getByRole("combobox", { name: "Country" })).toHaveTextContent(
			"United States",
		)

		// The factory's mailing differs from billing and the server says so, so
		// the tick starts off and the mailing block stays editable.
		const mailing = addressSection("Mailing address")
		expect(mailing.getByLabelText("Address line 1")).toHaveValue("2 Ship St")
		expect(mailing.getByLabelText("Address line 1")).toBeEnabled()
		expect(
			screen.getByRole("checkbox", {
				name: "Mailing address is the same as billing address",
			}),
		).not.toBeChecked()
	})

	it("hydrates the billing company from its own read, never as blank", async () => {
		serveOrg(
			personalInfoEditData({
				billing: { ...personalInfoEditData().billing, company: "Analytical Engines" },
			}),
		)
		renderForm()

		await screen.findByLabelText("First name")
		expect(addressSection("Billing address").getByLabelText("Company")).toHaveValue(
			"Analytical Engines",
		)
	})

	it("admits a failed load in words and keeps Save locked", async () => {
		serveOrg()
		server.use(
			http.get(ACCOUNT_PATH, () =>
				HttpResponse.json(memberPortalError(500, "Contact not accessible"), {
					status: 500,
				}),
			),
		)
		renderForm()

		expect(
			await screen.findByText(/couldn't load your personal information/),
		).toBeInTheDocument()
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
		expect(org.profileSpy.hits).toBe(0)
		expect(org.addressesSpy.hits).toBe(0)
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
		expect(org.profileSpy.hits).toBe(0)
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
		expect(org.addressesSpy.hits).toBe(0)
	})
})
