import { fireEvent, screen, within } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { http, HttpResponse } from "msw"
import { describe, expect, it, vi } from "vitest"

import type { CpdActivityFieldInfo } from "@/api/cpd"
import { CpdClaimDialog } from "@/components/molecules/cpd-claim-dialog"
import { cpdClaim } from "@/testing/factories/cpd"
import { memberPortalEnvelope } from "@/testing/factories/envelope"
import { server } from "@/testing/msw/server"
import { renderWithProviders } from "@/testing/render"

const ACTIVITY_TYPES_PATH = "/services/apexrest/memberportal/cpdActivityTypes"
const OPTIONS_PATH = "/services/apexrest/memberportal/options"
const CLAIM_PATH = "/services/apexrest/memberportal/cpdClaim"

/** No admin-configured extras — the shortest possible happy path. */
const SEMINAR: CpdActivityFieldInfo = {
	id: "type-seminar",
	name: "Seminar",
	organizationLabel: null,
	providerLabel: null,
	publicationLabel: null,
	titleLabel: null,
	contactEmailLabel: null,
}

function serveOrg() {
	const saves: Array<Record<string, unknown>> = []
	server.use(
		http.get(ACTIVITY_TYPES_PATH, () =>
			HttpResponse.json(memberPortalEnvelope([SEMINAR])),
		),
		http.get(OPTIONS_PATH, () =>
			HttpResponse.json(
				memberPortalEnvelope({
					picklists: {
						Area_of_Study__c: [{ label: "Credit Risk", value: "Credit Risk" }],
					},
					chapters: [],
				}),
			),
		),
		http.post(CLAIM_PATH, async ({ request }) => {
			saves.push((await request.json()) as Record<string, unknown>)
			return HttpResponse.json(
				memberPortalEnvelope({ status: "Success", msg: null, claimId: "claim-9" }),
			)
		}),
	)
	return { saves }
}

function renderDialog(claim: ReturnType<typeof cpdClaim> | null = null) {
	const onOpenChange = vi.fn()
	const rendered = renderWithProviders(
		<CpdClaimDialog open onOpenChange={onOpenChange} claim={claim} />,
	)
	return { ...rendered, onOpenChange }
}

describe("CpdClaimDialog", () => {
	it("closes itself after one full successful submission", async () => {
		const org = serveOrg()
		const user = userEvent.setup()
		const { onOpenChange } = renderDialog()

		const dialog = within(
			await screen.findByRole("dialog", { name: "Credit Details" }),
		)
		expect(
			dialog.getByText(/Log an activity for your current CPD cycle/),
		).toBeInTheDocument()

		await user.click(
			await dialog.findByRole("combobox", { name: "Activity Type*" }),
		)
		await user.click(await screen.findByRole("option", { name: "Seminar" }))
		fireEvent.change(dialog.getByLabelText("Date of Completion*"), {
			target: { value: "2026-02-01" },
		})
		await user.type(dialog.getByLabelText("Number of Credits*"), "3")
		await user.click(dialog.getByRole("button", { name: "Submit" }))

		// A saved claim is the only thing allowed to close this dialog.
		await vi.waitFor(() => {
			expect(onOpenChange).toHaveBeenCalledWith(false)
		})
		expect(org.saves).toHaveLength(1)
		expect(org.saves[0]).toMatchObject({
			activityType: "type-seminar",
			credits: 3,
			dateOfCompletionString: "2026-02-01",
		})
	})

	it("closes on Cancel without saving anything", async () => {
		const org = serveOrg()
		const user = userEvent.setup()
		const { onOpenChange } = renderDialog()

		const dialog = within(
			await screen.findByRole("dialog", { name: "Credit Details" }),
		)
		await user.click(await dialog.findByRole("button", { name: "Cancel" }))

		expect(onOpenChange).toHaveBeenCalledWith(false)
		expect(org.saves).toHaveLength(0)
	})

	it("describes an edit as an update to the pending activity", async () => {
		serveOrg()
		renderDialog(cpdClaim())

		const dialog = within(
			await screen.findByRole("dialog", { name: "Credit Details" }),
		)
		expect(dialog.getByText(/Update this activity/)).toBeInTheDocument()
		expect(
			await dialog.findByRole("button", { name: "Update" }),
		).toBeInTheDocument()
	})
})
