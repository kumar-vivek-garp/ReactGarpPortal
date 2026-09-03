import { screen, waitFor, within } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { http, HttpResponse } from "msw"
import { describe, expect, it } from "vitest"

import type { CurrentUser } from "@/api/auth/current-user"
import { personalInfoQueryKeys } from "@/api/personal-info/query-options"
import type { CountryOption } from "@/api/personal-info/types"
import { WorkExperiencePanel } from "@/components/organisms/work-experience-panel"
import { memberPortalEnvelope } from "@/testing/factories/envelope"
import { personalInfoEditData } from "@/testing/factories/personal-info"
import {
	cvView,
	experienceFormView,
	workExperience,
} from "@/testing/factories/work-experience"
import { server } from "@/testing/msw/server"
import { createTestQueryClient } from "@/testing/query-client"
import { renderWithRouterProviders } from "@/testing/router"

const CV_PATH = "/services/apexrest/memberportal/cv"
const CV_EXPERIENCE_PATH = "/services/apexrest/memberportal/cvExperience"
const CV_EXPERIENCE_DELETE_PATH =
	"/services/apexrest/memberportal/cvExperienceDelete"

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

/** GET cvExperience spy — records each request URL for param assertions. */
function experienceFormHandler() {
	const urls: string[] = []
	const handler = http.get(CV_EXPERIENCE_PATH, ({ request }) => {
		urls.push(request.url)
		return HttpResponse.json(memberPortalEnvelope(experienceFormView()))
	})
	return { urls, handler }
}

async function renderPanel() {
	server.use(
		http.get(CV_PATH, () => HttpResponse.json(memberPortalEnvelope(cvView()))),
	)
	const queryClient = createTestQueryClient(MEMBER)
	// The address form seeds itself from personal-info, not from `GET cv` —
	// pre-cached here the same way the exam registration tests do.
	queryClient.setQueryData(
		personalInfoQueryKeys.edit(MEMBER.contactId ?? ""),
		personalInfoEditData(),
	)
	queryClient.setQueryData(personalInfoQueryKeys.countries, COUNTRIES)
	const view = await renderWithRouterProviders(
		<WorkExperiencePanel programType="frm" />,
		{ user: MEMBER, queryClient },
	)
	await screen.findByText("In progress")
	return view
}

describe("WorkExperiencePanel — dialogs", () => {
	it("opens the Add dialog blank, fetching the picklists with no experienceId", async () => {
		const form = experienceFormHandler()
		server.use(form.handler)

		const user = userEvent.setup()
		await renderPanel()

		await user.click(screen.getByRole("button", { name: "Add experience" }))

		const dialog = await screen.findByRole("dialog", {
			name: "Add experience",
		})
		expect(
			await within(dialog).findByLabelText(/Organisation/),
		).toHaveValue("")
		// The Add form is its own cache entry — no experienceId travels.
		expect(form.urls[0]).toContain("programType=FRM")
		expect(form.urls[0]).not.toContain("experienceId")
	})

	it("opens the Edit dialog seeded with the clicked row", async () => {
		const form = experienceFormHandler()
		server.use(form.handler)

		const user = userEvent.setup()
		await renderPanel()

		await user.click(screen.getByRole("button", { name: "Edit Abrdn plc" }))

		const dialog = await screen.findByRole("dialog", {
			name: "Edit experience",
		})
		expect(
			await within(dialog).findByLabelText(/Organisation/),
		).toHaveValue("Abrdn plc")
		expect(form.urls[0]).toContain("experienceId=a1Q-exp-1")
	})

	it("names the row in the delete dialog, and Cancel closes without deleting", async () => {
		// No delete handler: a stray POST here would fail the strict MSW server.
		const user = userEvent.setup()
		await renderPanel()

		await user.click(screen.getByRole("button", { name: "Delete Abrdn plc" }))

		const dialog = await screen.findByRole("dialog", {
			name: "Remove this experience?",
		})
		expect(dialog).toHaveTextContent("Abrdn plc — Jan 2020 – Jan 2022")

		await user.click(within(dialog).getByRole("button", { name: "Cancel" }))
		await waitFor(() => {
			expect(screen.queryByRole("dialog")).not.toBeInTheDocument()
		})
	})

	it("posts the row's id on confirm and closes the delete dialog", async () => {
		const bodies: unknown[] = []
		server.use(
			http.post(CV_EXPERIENCE_DELETE_PATH, async ({ request }) => {
				bodies.push(await request.json())
				return HttpResponse.json(
					memberPortalEnvelope({
						statusCode: 200,
						statusMessage: null,
						newExperienceId: null,
					}),
				)
			}),
		)

		const user = userEvent.setup()
		await renderPanel()

		await user.click(screen.getByRole("button", { name: "Delete Abrdn plc" }))
		const dialog = await screen.findByRole("dialog", {
			name: "Remove this experience?",
		})
		await user.click(within(dialog).getByRole("button", { name: "Remove" }))

		await waitFor(() => {
			expect(screen.queryByRole("dialog")).not.toBeInTheDocument()
		})
		expect(bodies).toEqual([{ experienceId: "a1Q-exp-1" }])
	})

	it("opens the address dialog seeded from personal-info, not from the CV view", async () => {
		const user = userEvent.setup()
		await renderPanel()

		// Address on file → the section starts collapsed; open it first.
		await user.click(
			screen.getByRole("button", { name: /Where to post your certificate/ }),
		)
		await user.click(screen.getByRole("button", { name: "Change address" }))

		const dialog = await screen.findByRole("dialog", {
			name: "Delivery address",
		})
		// "2 Ship St" is the personal-info mailing seed; `GET cv` says
		// "12 Example Road" — the form must prefer the personal-info copy.
		expect(
			await within(dialog).findByLabelText(/Address line 1/),
		).toHaveValue("2 Ship St")
	})

	it("keeps the Edit dialog closed for a different row's data — remount per row", async () => {
		const form = experienceFormHandler()
		const second = workExperience({
			id: "a1Q-exp-2",
			company: "Lloyds",
			timeAllotted: 6,
		})
		server.use(
			form.handler,
			http.get(CV_PATH, () =>
				HttpResponse.json(
					memberPortalEnvelope(
						cvView({ workExperiences: [workExperience(), second] }),
					),
				),
			),
		)

		const user = userEvent.setup()
		const queryClient = createTestQueryClient(MEMBER)
		await renderWithRouterProviders(
			<WorkExperiencePanel programType="frm" />,
			{ user: MEMBER, queryClient },
		)
		await screen.findByText("In progress")

		await user.click(screen.getByRole("button", { name: "Edit Lloyds" }))
		const dialog = await screen.findByRole("dialog", {
			name: "Edit experience",
		})
		expect(
			await within(dialog).findByLabelText(/Organisation/),
		).toHaveValue("Lloyds")
		expect(form.urls[0]).toContain("experienceId=a1Q-exp-2")
	})
})
