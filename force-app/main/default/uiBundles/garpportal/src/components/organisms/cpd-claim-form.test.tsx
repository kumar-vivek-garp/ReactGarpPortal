import { fireEvent, screen } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { http, HttpResponse } from "msw"
import { describe, expect, it, vi } from "vitest"

import type { CpdActivityFieldInfo } from "@/api/cpd"
import { CpdClaimForm } from "@/components/organisms/cpd-claim-form"
import { memberPortalEnvelope } from "@/testing/factories/envelope"
import { server } from "@/testing/msw/server"
import { renderWithProviders } from "@/testing/render"

const ACTIVITY_TYPES_PATH = "/services/apexrest/memberportal/cpdActivityTypes"
const OPTIONS_PATH = "/services/apexrest/memberportal/options"
const CLAIM_PATH = "/services/apexrest/memberportal/cpdClaim"

/** Admin-configured labels switch each extra field on; null switches it off. */
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

function serveOrg(activityTypes: CpdActivityFieldInfo[] = [WEBINAR, READING]) {
	const saves: Array<Record<string, unknown>> = []
	server.use(
		http.get(ACTIVITY_TYPES_PATH, () =>
			HttpResponse.json(memberPortalEnvelope(activityTypes)),
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
			return HttpResponse.json(
				memberPortalEnvelope({ status: "Success", msg: null, claimId: "claim-9" }),
			)
		}),
	)
	return { saves }
}

function renderForm() {
	const onSaved = vi.fn()
	const onCancel = vi.fn()
	const rendered = renderWithProviders(
		<CpdClaimForm claim={null} onSaved={onSaved} onCancel={onCancel} />,
	)
	return { ...rendered, onSaved, onCancel }
}

type User = ReturnType<typeof userEvent.setup>

async function chooseType(user: User, name: string) {
	await user.click(await screen.findByRole("combobox", { name: "Activity Type*" }))
	await user.click(await screen.findByRole("option", { name }))
}

describe("no activity types", () => {
	it("says the form cannot be used instead of rendering a dead dropdown", async () => {
		serveOrg([])
		const user = userEvent.setup()
		const { onCancel } = renderForm()

		expect(
			await screen.findByText("Activity types are unavailable"),
		).toBeInTheDocument()
		expect(screen.queryByRole("combobox")).not.toBeInTheDocument()

		await user.click(screen.getByRole("button", { name: "Close" }))
		expect(onCancel).toHaveBeenCalledTimes(1)
	})
})

describe("dynamic fields", () => {
	it("rebuilds the extras when the activity type changes", async () => {
		serveOrg()
		const user = userEvent.setup()
		renderForm()

		await chooseType(user, "Webinar")
		expect(screen.getByLabelText("Organization*")).toBeInTheDocument()
		// Provider is the one extra shown but never required — no asterisk.
		expect(screen.getByLabelText("Provider")).toBeInTheDocument()
		expect(screen.getByLabelText("Title*")).toBeInTheDocument()
		expect(screen.queryByLabelText("Journal*")).not.toBeInTheDocument()

		await chooseType(user, "Reading")
		expect(screen.queryByLabelText("Organization*")).not.toBeInTheDocument()
		expect(screen.getByLabelText("Journal*")).toBeInTheDocument()
		expect(screen.getByLabelText("Contact email*")).toBeInTheDocument()
	})

	it("requires the configured extras and validates the email one", async () => {
		const org = serveOrg()
		const user = userEvent.setup()
		renderForm()

		await chooseType(user, "Reading")
		await user.type(screen.getByLabelText("Contact email*"), "not-an-email")
		await user.click(screen.getByRole("button", { name: "Submit" }))

		expect(await screen.findByText("Journal is required")).toBeInTheDocument()
		expect(
			screen.getByText("Contact email must be a valid email address"),
		).toBeInTheDocument()
		expect(org.saves).toHaveLength(0)
	})
})

describe("fixed-field validation", () => {
	it("names the three always-required answers and posts nothing", async () => {
		const org = serveOrg()
		const user = userEvent.setup()
		const { onSaved } = renderForm()

		await screen.findByRole("combobox", { name: "Activity Type*" })
		await user.click(screen.getByRole("button", { name: "Submit" }))

		expect(
			await screen.findByText("Activity Type is required"),
		).toBeInTheDocument()
		expect(
			screen.getByText("Date of Completion is required"),
		).toBeInTheDocument()
		expect(screen.getByText("Credits is required")).toBeInTheDocument()
		expect(org.saves).toHaveLength(0)
		expect(onSaved).not.toHaveBeenCalled()
	})

	it("refuses a completion date in the future", async () => {
		const org = serveOrg()
		const user = userEvent.setup()
		renderForm()

		fireEvent.change(await screen.findByLabelText("Date of Completion*"), {
			target: { value: "2999-01-01" },
		})
		await user.click(screen.getByRole("button", { name: "Submit" }))

		expect(
			await screen.findByText("Date must be on or before today"),
		).toBeInTheDocument()
		expect(org.saves).toHaveLength(0)
	})

	it("holds credits to the 0.5–50 band", async () => {
		const org = serveOrg()
		const user = userEvent.setup()
		renderForm()

		const credits = await screen.findByLabelText("Number of Credits*")
		await user.type(credits, "0.25")
		await user.click(screen.getByRole("button", { name: "Submit" }))
		expect(
			await screen.findByText("Credits must be at least 0.5"),
		).toBeInTheDocument()

		await user.clear(credits)
		await user.type(credits, "51")
		await user.click(screen.getByRole("button", { name: "Submit" }))
		expect(
			await screen.findByText("Credits cannot exceed 50"),
		).toBeInTheDocument()
		expect(org.saves).toHaveLength(0)
	})

	it("checks the optional comment and URL only when given", async () => {
		const org = serveOrg()
		const user = userEvent.setup()
		renderForm()

		await user.type(await screen.findByLabelText("Comment"), "x")
		await user.type(screen.getByLabelText("URL"), "not a url")
		await user.click(screen.getByRole("button", { name: "Submit" }))

		expect(
			await screen.findByText("Comment must be at least 2 characters long"),
		).toBeInTheDocument()
		expect(screen.getByText("URL must be a valid URL")).toBeInTheDocument()
		expect(org.saves).toHaveLength(0)
	})
})
