import { screen } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { http, HttpResponse } from "msw"
import { describe, expect, it, vi } from "vitest"

import type { CurrentUser } from "@/api/auth/current-user"
import type { CountryOption } from "@/api/personal-info/types"
import { memberPortalEnvelope } from "@/testing/factories/envelope"
import { personalInfoEditData } from "@/testing/factories/personal-info"
import { personalInfoGraphqlResolvers } from "@/testing/factories/personal-info-graphql"
import { cvView } from "@/testing/factories/work-experience"
import { sdkGraphqlHandler } from "@/testing/msw/handlers/sdk-graphql"
import { server } from "@/testing/msw/server"
import { renderWithProviders } from "@/testing/render"

import { CvAddressDialog } from "./cv-address-dialog"

const CV_ADDRESS_PATH = "/services/apexrest/memberportal/cvAddress"

const MEMBER: CurrentUser = {
	id: "005-member",
	name: "Ada Lovelace",
	garpId: "G-1",
	contactId: "003-member",
	photoUrl: null,
}

const COUNTRIES: CountryOption[] = [
	{ label: "United Kingdom", value: "United Kingdom", phoneCode: "+44" },
]

function serveOrg() {
	server.use(
		sdkGraphqlHandler(
			personalInfoGraphqlResolvers(personalInfoEditData(), COUNTRIES),
		),
		http.post(CV_ADDRESS_PATH, () =>
			HttpResponse.json(
				memberPortalEnvelope({ statusMessage: null, statusCode: 200 }),
			),
		),
	)
}

describe("CvAddressDialog", () => {
	it("opens on the delivery-address title wrapping the address form", async () => {
		serveOrg()
		renderWithProviders(
			<CvAddressDialog open onOpenChange={vi.fn()} view={cvView()} />,
		)

		expect(
			screen.getByRole("heading", { name: "Delivery address" }),
		).toBeInTheDocument()
		expect(
			await screen.findByRole("button", { name: "Cancel" }),
		).toBeInTheDocument()
	})

	it("closes when the wrapped form cancels", async () => {
		serveOrg()
		const user = userEvent.setup()
		const onOpenChange = vi.fn()
		renderWithProviders(
			<CvAddressDialog open onOpenChange={onOpenChange} view={cvView()} />,
		)

		await user.click(await screen.findByRole("button", { name: "Cancel" }))

		expect(onOpenChange).toHaveBeenCalledWith(false)
	})

	it("closes once the wrapped form saves", async () => {
		serveOrg()
		const user = userEvent.setup()
		const onOpenChange = vi.fn()
		renderWithProviders(
			<CvAddressDialog open onOpenChange={onOpenChange} view={cvView()} />,
			{ user: MEMBER },
		)

		// Seeded from the personal-info mailing address, so it saves as-is.
		await screen.findByLabelText(/Address line 1/)
		await user.click(screen.getByRole("button", { name: "Save address" }))

		await vi.waitFor(() => {
			expect(onOpenChange).toHaveBeenCalledWith(false)
		})
	})
})
