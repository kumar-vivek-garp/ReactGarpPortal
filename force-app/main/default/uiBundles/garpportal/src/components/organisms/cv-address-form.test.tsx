import { screen } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { http, HttpResponse } from "msw"
import { describe, expect, it, vi } from "vitest"

import type { CurrentUser } from "@/api/auth/current-user"
import type { CountryOption } from "@/api/personal-info/types"
import type { CvView } from "@/api/work-experience"
import { CvAddressForm } from "@/components/organisms/cv-address-form"
import { memberPortalEnvelope, memberPortalError } from "@/testing/factories/envelope"
import { personalInfoEditData } from "@/testing/factories/personal-info"
import { personalInfoGraphqlResolvers } from "@/testing/factories/personal-info-graphql"
import { cvView } from "@/testing/factories/work-experience"
import { sdkGraphqlHandler } from "@/testing/msw/handlers/sdk-graphql"
import { server } from "@/testing/msw/server"
import { renderWithProviders } from "@/testing/render"

const CV_ADDRESS_PATH = "/services/apexrest/memberportal/cvAddress"

const MEMBER: CurrentUser = {
	id: "005-member",
	name: "Ada Lovelace",
	garpId: "G-1",
	contactId: "003-member",
	photoUrl: null,
}

const COUNTRIES: CountryOption[] = [
	{ label: "United States", value: "United States", phoneCode: "+1" },
	{ label: "United Kingdom", value: "United Kingdom", phoneCode: "+44" },
]

function serveOrg(
	saveRespond: () => Response = () =>
		HttpResponse.json(
			memberPortalEnvelope({ statusMessage: null, statusCode: 200 }),
		),
) {
	const saves: Array<Record<string, unknown>> = []
	server.use(
		sdkGraphqlHandler(
			personalInfoGraphqlResolvers(personalInfoEditData(), COUNTRIES),
		),
		http.post(CV_ADDRESS_PATH, async ({ request }) => {
			saves.push((await request.json()) as Record<string, unknown>)
			return saveRespond()
		}),
	)
	return { saves }
}

function renderForm(view: CvView | null = cvView()) {
	const onSaved = vi.fn()
	const onCancel = vi.fn()
	const rendered = renderWithProviders(
		<CvAddressForm view={view} onSaved={onSaved} onCancel={onCancel} />,
		{ user: MEMBER },
	)
	return { ...rendered, onSaved, onCancel }
}

describe("hydration", () => {
	it("seeds from the personal-info mailing address, never from GET cv", async () => {
		serveOrg()
		renderForm()

		// The factory's CvView carries "12 Example Road" — it must NOT appear:
		// seeding from the CV view would blank company and phone on save.
		expect(await screen.findByLabelText(/Address line 1/)).toHaveValue(
			"2 Ship St",
		)
		expect(screen.getByLabelText(/City/)).toHaveValue("Boston")
		expect(screen.getByLabelText(/Postal code/)).toHaveValue("02110")
		expect(screen.getByLabelText(/^Phone$/)).toHaveValue("5551234")
		expect(screen.getByRole("combobox", { name: /Country/ })).toHaveTextContent(
			"United States",
		)
		// A non-OSTA candidate gets no Chinese delivery block.
		expect(
			screen.queryByRole("heading", { name: "Chinese delivery address" }),
		).not.toBeInTheDocument()
	})
})

describe("validation", () => {
	it("requires address, city, postal code — and posts nothing", async () => {
		const org = serveOrg()
		const user = userEvent.setup()
		const { onSaved } = renderForm()

		await user.clear(await screen.findByLabelText(/Address line 1/))
		await user.clear(screen.getByLabelText(/City/))
		await user.clear(screen.getByLabelText(/Postal code/))
		await user.click(screen.getByRole("button", { name: "Save address" }))

		expect(await screen.findByText("An address is required.")).toBeInTheDocument()
		expect(screen.getByText("A city is required.")).toBeInTheDocument()
		expect(screen.getByText("A postal code is required.")).toBeInTheDocument()
		expect(org.saves).toHaveLength(0)
		expect(onSaved).not.toHaveBeenCalled()
	})
})

describe("submitting", () => {
	it("posts all seven mailing fields and no OSTA block, then reports back", async () => {
		const org = serveOrg()
		const user = userEvent.setup()
		const { onSaved } = renderForm()

		const city = await screen.findByLabelText(/City/)
		await user.clear(city)
		await user.type(city, "Cambridge")
		await user.click(screen.getByRole("button", { name: "Save address" }))

		await vi.waitFor(() => {
			expect(onSaved).toHaveBeenCalledTimes(1)
		})
		expect(org.saves).toHaveLength(1)
		expect(org.saves[0]).toEqual({
			mailingAddress: {
				// "" in the org → null on the wire, but the key is still sent:
				// Apex assigns all seven unconditionally.
				company: null,
				street: "2 Ship St",
				city: "Cambridge",
				state: "MA",
				postalCode: "02110",
				country: "United States",
				phone: "5551234",
			},
		})
	})

	it("keeps the form open when Apex refuses inside an HTTP 200", async () => {
		const org = serveOrg(() =>
			HttpResponse.json(
				memberPortalEnvelope({
					statusMessage: "Country not recognised",
					statusCode: 501,
				}),
			),
		)
		const user = userEvent.setup()
		const { onSaved } = renderForm()

		await screen.findByLabelText(/Address line 1/)
		await user.click(screen.getByRole("button", { name: "Save address" }))

		await vi.waitFor(() => {
			expect(org.saves).toHaveLength(1)
		})
		expect(onSaved).not.toHaveBeenCalled()
		await vi.waitFor(() => {
			expect(screen.getByRole("button", { name: "Save address" })).toBeEnabled()
		})
	})

	it("keeps the form open on a transport failure too", async () => {
		const org = serveOrg(() =>
			HttpResponse.json(memberPortalError(500, "CV service down"), {
				status: 500,
			}),
		)
		const user = userEvent.setup()
		const { onSaved } = renderForm()

		await screen.findByLabelText(/Address line 1/)
		await user.click(screen.getByRole("button", { name: "Save address" }))

		await vi.waitFor(() => {
			expect(org.saves).toHaveLength(1)
		})
		expect(onSaved).not.toHaveBeenCalled()
	})

	it("hands Cancel back without saving", async () => {
		const org = serveOrg()
		const user = userEvent.setup()
		const { onCancel } = renderForm()

		await screen.findByLabelText(/Address line 1/)
		await user.click(screen.getByRole("button", { name: "Cancel" }))

		expect(onCancel).toHaveBeenCalledTimes(1)
		expect(org.saves).toHaveLength(0)
	})
})
