import { screen, within } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { http, HttpResponse } from "msw"
import { describe, expect, it, vi } from "vitest"

import type { CurrentUser } from "@/api/auth/current-user"
import type { CountryOption } from "@/api/personal-info/types"
import { CvAddressForm } from "@/components/organisms/cv-address-form"
import { memberPortalEnvelope } from "@/testing/factories/envelope"
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
]

/** An OSTA candidate with a Chinese delivery address already on file. */
function ostaView() {
	return cvView({
		isOSTA: true,
		ostaRecipient: "王小明",
		ostaAddress: {
			street: "长安街1号",
			city: "北京",
			state: "北京市",
			postalCode: null,
			country: "China",
			isEmpty: false,
		},
		ostaDistrict: "东城区",
		ostaTown: "某村",
		ostaPhone: "13800138000",
	})
}

function serveOrg() {
	const saves: Array<Record<string, unknown>> = []
	server.use(
		sdkGraphqlHandler(
			personalInfoGraphqlResolvers(personalInfoEditData(), COUNTRIES),
		),
		http.post(CV_ADDRESS_PATH, async ({ request }) => {
			saves.push((await request.json()) as Record<string, unknown>)
			return HttpResponse.json(
				memberPortalEnvelope({ statusMessage: null, statusCode: 200 }),
			)
		}),
	)
	return { saves }
}

function renderForm(view = ostaView()) {
	const onSaved = vi.fn()
	const rendered = renderWithProviders(
		<CvAddressForm view={view} onSaved={onSaved} onCancel={vi.fn()} />,
		{ user: MEMBER },
	)
	return { ...rendered, onSaved }
}

/** The block names itself via aria-labelledby, so it is a landmark region. */
async function ostaRegion() {
	return within(
		await screen.findByRole("region", { name: "Chinese delivery address" }),
	)
}

describe("the OSTA block", () => {
	it("appears for an OSTA candidate, seeded from GET cv", async () => {
		serveOrg()
		renderForm()

		const region = await ostaRegion()
		expect(region.getByLabelText(/Recipient name/)).toHaveValue("王小明")
		expect(region.getByLabelText(/Province/)).toHaveValue("北京市")
		expect(region.getByLabelText(/City/)).toHaveValue("北京")
		expect(region.getByLabelText(/District/)).toHaveValue("东城区")
		expect(region.getByLabelText(/Building or village/)).toHaveValue("某村")
		expect(region.getByLabelText(/Street address/)).toHaveValue("长安街1号")
		expect(region.getByLabelText(/Phone in China/)).toHaveValue("13800138000")
	})

	it("requires Chinese characters, but tolerates numbers beside them", async () => {
		const org = serveOrg()
		const user = userEvent.setup()
		renderForm()

		const region = await ostaRegion()
		// Latin-only fails; the street keeps its number and passes.
		const city = region.getByLabelText(/City/)
		await user.clear(city)
		await user.type(city, "Beijing")
		await user.click(screen.getByRole("button", { name: "Save address" }))

		expect(
			await region.findByText("Please enter city in Chinese."),
		).toBeInTheDocument()
		expect(
			region.queryByText("Please enter street address in Chinese."),
		).not.toBeInTheDocument()
		expect(org.saves).toHaveLength(0)
	})

	it("requires every field of the block, including the phone", async () => {
		const org = serveOrg()
		const user = userEvent.setup()
		renderForm(cvView({ isOSTA: true }))

		const region = await ostaRegion()
		await user.click(screen.getByRole("button", { name: "Save address" }))

		expect(
			await region.findByText("Recipient name is required."),
		).toBeInTheDocument()
		expect(region.getByText("Province is required.")).toBeInTheDocument()
		expect(
			region.getByText("A phone number in China is required."),
		).toBeInTheDocument()
		expect(org.saves).toHaveLength(0)
	})

	it("posts the block with province as state and no postal code or country", async () => {
		const org = serveOrg()
		const user = userEvent.setup()
		const { onSaved } = renderForm()

		await ostaRegion()
		await user.click(screen.getByRole("button", { name: "Save address" }))

		await vi.waitFor(() => {
			expect(onSaved).toHaveBeenCalledTimes(1)
		})
		expect(org.saves[0]).toMatchObject({
			ostaRecipient: "王小明",
			ostaAddress: {
				street: "长安街1号",
				city: "北京",
				state: "北京市",
				// `saveAddress` reads neither; `GET cv` hard-codes China.
				postalCode: null,
				country: null,
				district: "东城区",
				town: "某村",
				phone: "13800138000",
			},
		})
		// The plain mailing address travels alongside it.
		expect(org.saves[0]).toHaveProperty("mailingAddress")
	})
})
