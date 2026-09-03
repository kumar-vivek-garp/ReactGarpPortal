import { fireEvent, screen } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { http, HttpResponse } from "msw"
import { describe, expect, it, vi } from "vitest"

import type { CountryOption } from "@/api/personal-info/types"
import type { OstaView } from "@/api/osta"
import { OstaIdForm } from "@/components/organisms/osta-id-form"
import { memberPortalEnvelope } from "@/testing/factories/envelope"
import { personalInfoEditData } from "@/testing/factories/personal-info"
import { personalInfoGraphqlResolvers } from "@/testing/factories/personal-info-graphql"
import { sdkGraphqlHandler } from "@/testing/msw/handlers/sdk-graphql"
import { server } from "@/testing/msw/server"
import { renderWithProviders } from "@/testing/render"

const OSTA_PATH = "/services/apexrest/memberportal/osta"

const COUNTRIES: CountryOption[] = [
	{ label: "China", value: "China", phoneCode: "+86" },
	{ label: "United States", value: "United States", phoneCode: "+1" },
]

function ostaView(overrides: Partial<OstaView> = {}): OstaView {
	return {
		statusMessage: null,
		statusCode: 200,
		ostaIdInfo: {
			idType: "Passport",
			idLocation: "China",
			/** The masked tail — the read never returns the full number. */
			idNumber: "45678",
			idExpireDate: "04/09/2030",
			ostaConsent: false,
		},
		...overrides,
	}
}

function serveOrg({
	view = ostaView(),
	saveRespond = () =>
		HttpResponse.json(
			memberPortalEnvelope({
				statusMessage: "OSTA Information Updated",
				statusCode: 200,
			}),
		),
}: {
	view?: OstaView
	saveRespond?: () => Response
} = {}) {
	const saves: Array<Record<string, unknown>> = []
	server.use(
		sdkGraphqlHandler(
			personalInfoGraphqlResolvers(personalInfoEditData(), COUNTRIES),
		),
		http.get(OSTA_PATH, () => HttpResponse.json(memberPortalEnvelope(view))),
		http.post(OSTA_PATH, async ({ request }) => {
			saves.push((await request.json()) as Record<string, unknown>)
			return saveRespond()
		}),
	)
	return { saves }
}

function renderForm() {
	const onSaved = vi.fn()
	const onCancel = vi.fn()
	const rendered = renderWithProviders(
		<OstaIdForm onSaved={onSaved} onCancel={onCancel} />,
	)
	return { ...rendered, onSaved, onCancel }
}

const consentBox = () =>
	screen.getByRole("checkbox", { name: /I consent to GARP sharing/ })
const saveButton = () =>
	screen.getByRole("button", { name: "Save identity details" })

describe("hydration", () => {
	it("seeds type, country and expiry — but never the masked number", async () => {
		serveOrg()
		renderForm()

		expect(
			await screen.findByRole("combobox", { name: /ID type/ }),
		).toHaveTextContent("Passport")
		expect(screen.getByRole("combobox", { name: /Issued in/ })).toHaveTextContent(
			"China",
		)
		// Pre-filling the masked tail would let a plain re-save truncate the
		// real ID to five characters.
		expect(screen.getByLabelText(/ID number/)).toHaveValue("")
		expect(
			screen.getByText(
				"Currently ending 45678. Enter the full number to change it.",
			),
		).toBeInTheDocument()
		// MM/dd/yyyy off the wire, yyyy-MM-dd in the input.
		expect(screen.getByLabelText(/Expiry date/)).toHaveValue("2030-04-09")
		// Consent starts unticked every visit, even once given.
		expect(consentBox()).not.toBeChecked()
	})

	it("starts blank for a candidate with nothing on file", async () => {
		serveOrg({ view: ostaView({ ostaIdInfo: null }) })
		renderForm()

		expect(
			await screen.findByRole("combobox", { name: /ID type/ }),
		).toHaveTextContent("Select an ID type")
		expect(
			screen.getByText("Enter the number exactly as it appears on your ID."),
		).toBeInTheDocument()
		expect(screen.getByLabelText(/Expiry date/)).toHaveValue("")
	})

	it("keeps the number hidden until Show is pressed", async () => {
		serveOrg()
		const user = userEvent.setup()
		renderForm()

		const number = await screen.findByLabelText(/ID number/)
		expect(number).toHaveAttribute("type", "password")

		await user.click(screen.getByRole("button", { name: "Show" }))
		expect(number).toHaveAttribute("type", "text")

		await user.click(screen.getByRole("button", { name: "Hide" }))
		expect(number).toHaveAttribute("type", "password")
	})
})

describe("validation", () => {
	it("names all five missing answers and posts nothing", async () => {
		const org = serveOrg({ view: ostaView({ ostaIdInfo: null }) })
		const user = userEvent.setup()
		const { onSaved } = renderForm()

		await screen.findByRole("combobox", { name: /ID type/ })
		await user.click(saveButton())

		expect(
			await screen.findByText("An ID type is required."),
		).toBeInTheDocument()
		expect(screen.getByText("An issuing country is required.")).toBeInTheDocument()
		expect(screen.getByText("Your ID number is required.")).toBeInTheDocument()
		expect(screen.getByText("An expiry date is required.")).toBeInTheDocument()
		expect(
			screen.getByText("You must consent before these details can be saved."),
		).toBeInTheDocument()
		expect(org.saves).toHaveLength(0)
		expect(onSaved).not.toHaveBeenCalled()
	})
})

describe("submitting", () => {
	it("posts all five fields, converting the expiry to MM/dd/yyyy", async () => {
		const org = serveOrg({ view: ostaView({ ostaIdInfo: null }) })
		const user = userEvent.setup()
		const { onSaved } = renderForm()

		await user.click(await screen.findByRole("combobox", { name: /ID type/ }))
		await user.click(await screen.findByRole("option", { name: "Passport" }))
		await user.click(screen.getByRole("combobox", { name: /Issued in/ }))
		await user.click(await screen.findByRole("option", { name: "China" }))
		await user.type(screen.getByLabelText(/ID number/), " G12345678 ")
		fireEvent.change(screen.getByLabelText(/Expiry date/), {
			target: { value: "2030-04-09" },
		})
		await user.click(consentBox())
		await user.click(saveButton())

		await vi.waitFor(() => {
			expect(onSaved).toHaveBeenCalledTimes(1)
		})
		expect(org.saves).toHaveLength(1)
		expect(org.saves[0]).toEqual({
			idType: "Passport",
			idLocation: "China",
			idNumber: "G12345678",
			idExpireDate: "04/09/2030",
			ostaConsent: true,
		})
	})

	it("keeps the form open when Apex refuses the save", async () => {
		const org = serveOrg({
			saveRespond: () =>
				HttpResponse.json(
					memberPortalEnvelope({
						statusMessage: "The expiry date could not be read.",
						statusCode: 501,
					}),
				),
		})
		const user = userEvent.setup()
		const { onSaved } = renderForm()

		await user.type(await screen.findByLabelText(/ID number/), "G12345678")
		await user.click(consentBox())
		await user.click(saveButton())

		await vi.waitFor(() => {
			expect(org.saves).toHaveLength(1)
		})
		expect(onSaved).not.toHaveBeenCalled()
		await vi.waitFor(() => {
			expect(saveButton()).toBeEnabled()
		})
	})

	it("hands Cancel back without saving", async () => {
		const org = serveOrg()
		const user = userEvent.setup()
		const { onCancel } = renderForm()

		await screen.findByLabelText(/ID number/)
		await user.click(screen.getByRole("button", { name: "Cancel" }))

		expect(onCancel).toHaveBeenCalledTimes(1)
		expect(org.saves).toHaveLength(0)
	})
})
