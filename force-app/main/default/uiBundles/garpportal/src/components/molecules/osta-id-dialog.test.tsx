import { fireEvent, screen } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { http, HttpResponse } from "msw"
import { describe, expect, it, vi } from "vitest"

import type { CurrentUser } from "@/api/auth/current-user"
import type { CountryOption } from "@/api/personal-info/types"
import { memberPortalEnvelope } from "@/testing/factories/envelope"
import { personalInfoEditData } from "@/testing/factories/personal-info"
import { personalInfoGraphqlResolvers } from "@/testing/factories/personal-info-graphql"
import { sdkGraphqlHandler } from "@/testing/msw/handlers/sdk-graphql"
import { server } from "@/testing/msw/server"
import { renderWithProviders } from "@/testing/render"

import { OstaIdDialog } from "./osta-id-dialog"

const OSTA_PATH = "/services/apexrest/memberportal/osta"

const COUNTRIES: CountryOption[] = [
	{ label: "China", value: "China", phoneCode: "+86" },
]

const MEMBER: CurrentUser = {
	id: "005-member",
	name: "Ada Lovelace",
	garpId: "G-1",
	contactId: "003-member",
	photoUrl: null,
}

function serveOrg() {
	server.use(
		sdkGraphqlHandler(
			personalInfoGraphqlResolvers(personalInfoEditData(), COUNTRIES),
		),
		http.get(OSTA_PATH, () =>
			HttpResponse.json(
				memberPortalEnvelope({
					statusMessage: null,
					statusCode: 200,
					ostaIdInfo: null,
				}),
			),
		),
		http.post(OSTA_PATH, () =>
			HttpResponse.json(
				memberPortalEnvelope({
					statusMessage: "OSTA Information Updated",
					statusCode: 200,
				}),
			),
		),
	)
}

describe("OstaIdDialog", () => {
	it("opens on the identity title wrapping the OSTA form", async () => {
		serveOrg()
		renderWithProviders(<OstaIdDialog open onOpenChange={vi.fn()} />)

		expect(
			screen.getByRole("heading", { name: "Identity details" }),
		).toBeInTheDocument()
		expect(
			await screen.findByRole("button", { name: "Cancel" }),
		).toBeInTheDocument()
	})

	it("closes when the wrapped form cancels", async () => {
		serveOrg()
		const user = userEvent.setup()
		const onOpenChange = vi.fn()
		renderWithProviders(<OstaIdDialog open onOpenChange={onOpenChange} />)

		await user.click(await screen.findByRole("button", { name: "Cancel" }))

		expect(onOpenChange).toHaveBeenCalledWith(false)
	})

	it("closes once the wrapped form saves", async () => {
		serveOrg()
		const user = userEvent.setup()
		const onOpenChange = vi.fn()
		renderWithProviders(<OstaIdDialog open onOpenChange={onOpenChange} />, {
			user: MEMBER,
		})

		await user.click(await screen.findByRole("combobox", { name: /ID type/ }))
		await user.click(await screen.findByRole("option", { name: "Passport" }))
		await user.click(screen.getByRole("combobox", { name: /Issued in/ }))
		await user.click(await screen.findByRole("option", { name: "China" }))
		await user.type(screen.getByLabelText(/ID number/), "G12345678")
		fireEvent.change(screen.getByLabelText(/Expiry date/), {
			target: { value: "2030-04-09" },
		})
		await user.click(
			screen.getByRole("checkbox", { name: /I consent to GARP sharing/ }),
		)
		await user.click(
			screen.getByRole("button", { name: "Save identity details" }),
		)

		await vi.waitFor(() => {
			expect(onOpenChange).toHaveBeenCalledWith(false)
		})
	})
})
