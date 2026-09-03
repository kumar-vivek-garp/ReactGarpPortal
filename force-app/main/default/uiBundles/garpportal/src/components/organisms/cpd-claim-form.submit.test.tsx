import { fireEvent, screen } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { http, HttpResponse } from "msw"
import { describe, expect, it, vi } from "vitest"

import type { CpdActivityFieldInfo, CpdClaim } from "@/api/cpd"
import { CpdClaimForm } from "@/components/organisms/cpd-claim-form"
import { cpdClaim } from "@/testing/factories/cpd"
import { memberPortalEnvelope } from "@/testing/factories/envelope"
import { server } from "@/testing/msw/server"
import { renderWithProviders } from "@/testing/render"

const ACTIVITY_TYPES_PATH = "/services/apexrest/memberportal/cpdActivityTypes"
const OPTIONS_PATH = "/services/apexrest/memberportal/options"
const CLAIM_PATH = "/services/apexrest/memberportal/cpdClaim"

const WEBINAR: CpdActivityFieldInfo = {
	id: "type-webinar",
	name: "Webinar",
	organizationLabel: "Organization",
	providerLabel: "Provider",
	publicationLabel: null,
	titleLabel: "Title",
	contactEmailLabel: null,
}
const READING: CpdActivityFieldInfo = {
	id: "type-reading",
	name: "Reading",
	organizationLabel: null,
	providerLabel: null,
	publicationLabel: "Journal",
	titleLabel: null,
	contactEmailLabel: "Contact email",
}

function pick(values: string[]) {
	return values.map((value) => ({ label: value, value }))
}

function serveOrg(
	saveRespond: () => Response = () =>
		HttpResponse.json(
			memberPortalEnvelope({ status: "Success", msg: null, claimId: "claim-9" }),
		),
) {
	const saves: Array<Record<string, unknown>> = []
	server.use(
		http.get(ACTIVITY_TYPES_PATH, () =>
			HttpResponse.json(memberPortalEnvelope([WEBINAR, READING])),
		),
		http.get(OPTIONS_PATH, () =>
			HttpResponse.json(
				memberPortalEnvelope({
					picklists: { Area_of_Study__c: pick(["Credit Risk", "Market Risk"]) },
					chapters: [],
				}),
			),
		),
		http.post(CLAIM_PATH, async ({ request }) => {
			saves.push((await request.json()) as Record<string, unknown>)
			return saveRespond()
		}),
	)
	return { saves }
}

function renderForm(claim: CpdClaim | null = null) {
	const onSaved = vi.fn()
	const rendered = renderWithProviders(
		<CpdClaimForm claim={claim} onSaved={onSaved} onCancel={vi.fn()} />,
	)
	return { ...rendered, onSaved }
}

type User = ReturnType<typeof userEvent.setup>

async function chooseType(user: User, name: string) {
	await user.click(await screen.findByRole("combobox", { name: "Activity Type*" }))
	await user.click(await screen.findByRole("option", { name }))
}

describe("creating a claim", () => {
	it("posts exactly the chosen type's fields — no claimId, stale extras dropped", async () => {
		const org = serveOrg()
		const user = userEvent.setup()
		const { onSaved } = renderForm()

		// Type into a Webinar-only extra first, then switch type: the value
		// must not survive into a claim for a type it means nothing for.
		await chooseType(user, "Webinar")
		await user.type(screen.getByLabelText("Organization*"), "GARP")
		await chooseType(user, "Reading")

		await user.click(screen.getByRole("checkbox", { name: "Credit Risk" }))
		await user.click(screen.getByRole("checkbox", { name: "Market Risk" }))
		fireEvent.change(screen.getByLabelText("Date of Completion*"), {
			target: { value: "2026-02-01" },
		})
		await user.type(screen.getByLabelText("Number of Credits*"), "2.5")
		await user.type(screen.getByLabelText("Journal*"), "Risk Journal")
		await user.type(screen.getByLabelText("Contact email*"), "editor@garp.org")
		await user.type(screen.getByLabelText("Comment"), "Great read")
		await user.click(screen.getByRole("button", { name: "Submit" }))

		await vi.waitFor(() => {
			expect(onSaved).toHaveBeenCalledTimes(1)
		})
		expect(org.saves).toHaveLength(1)
		expect(org.saves[0]).toEqual({
			activityType: "type-reading",
			credits: 2.5,
			dateOfCompletionString: "2026-02-01",
			areaOfStudy: "Credit Risk;Market Risk",
			comments: "Great read",
			URL: null,
			publication: "Risk Journal",
			contactEmail: "editor@garp.org",
		})
	})
})

describe("editing a claim", () => {
	it("seeds the fixed controls — but loses the dynamic extras (pinned defect)", async () => {
		serveOrg()
		renderForm(cpdClaim())

		expect(
			await screen.findByRole("combobox", { name: "Activity Type*" }),
		).toHaveTextContent("Webinar")
		expect(screen.getByLabelText("Date of Completion*")).toHaveValue("2026-02-01")
		expect(screen.getByLabelText("Number of Credits*")).toHaveValue(2)
		expect(screen.getByRole("checkbox", { name: "Credit Risk" })).toBeChecked()
		expect(
			screen.getByRole("checkbox", { name: "Market Risk" }),
		).not.toBeChecked()
		/*
		 * Pins a suspected DATA-LOSS defect, deliberately: the claim carries
		 * "Climate Risk Webinar", but the first render still watches the
		 * default empty activityType, so the unregister effect drops all five
		 * extras — destroying the values the seed had just applied — and they
		 * re-register empty when the watch catches up. A required extra then
		 * blocks an untouched Update; an optional one posts null. Flip this
		 * to the claim's title when the form is fixed.
		 */
		expect(screen.getByLabelText("Title*")).toHaveValue("")
		expect(screen.getByRole("button", { name: "Update" })).toBeInTheDocument()
	})

	it("carries the claimId on the wire once the wiped extras are retyped", async () => {
		const org = serveOrg()
		const user = userEvent.setup()
		const { onSaved } = renderForm(
			cpdClaim({ organizationName: "GARP", providerOther: "GARP Events" }),
		)

		// Required extras arrive empty (see above) and must be retyped before
		// Update goes anywhere; the optional provider stays lost.
		await user.type(await screen.findByLabelText("Organization*"), "GARP")
		await user.type(screen.getByLabelText("Title*"), "Climate Risk Webinar")
		await user.click(screen.getByRole("button", { name: "Update" }))

		await vi.waitFor(() => {
			expect(onSaved).toHaveBeenCalledTimes(1)
		})
		expect(org.saves[0]).toMatchObject({
			claimId: "claim-1",
			activityType: "type-webinar",
			organizationName: "GARP",
			title: "Climate Risk Webinar",
			// The claim's "GARP Events" — silently dropped. Same pinned defect.
			provider: null,
		})
	})
})

describe("refusal", () => {
	it("keeps the form open when the write comes back unsuccessful inside a 200", async () => {
		// CPD writes carry no statusCode — `status` is the only honest signal.
		const org = serveOrg(() =>
			HttpResponse.json(
				memberPortalEnvelope({
					status: "Error",
					msg: "Claim not found",
					claimId: null,
				}),
			),
		)
		const user = userEvent.setup()
		const { onSaved } = renderForm(cpdClaim())

		// The wiped required extras (pinned above) must be retyped first.
		await user.type(await screen.findByLabelText("Organization*"), "GARP")
		await user.type(screen.getByLabelText("Title*"), "Climate Risk Webinar")
		await user.click(screen.getByRole("button", { name: "Update" }))

		await vi.waitFor(() => {
			expect(org.saves).toHaveLength(1)
		})
		expect(onSaved).not.toHaveBeenCalled()
		await vi.waitFor(() => {
			expect(screen.getByRole("button", { name: "Update" })).toBeEnabled()
		})
	})
})
