import { screen, waitFor } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { http, HttpResponse } from "msw"
import { describe, expect, it } from "vitest"

import { HelpCenterPanel } from "@/components/organisms/help-center-panel"
import { memberPortalEnvelope } from "@/testing/factories/envelope"
import { server } from "@/testing/msw/server"
import { renderWithRouterProviders } from "@/testing/router"

const CASES_PATH = "/services/apexrest/memberportal/cases"
const SUBMIT_CASE_PATH = "/services/apexrest/memberportal/submitCase"

function serveOrg() {
	server.use(
		http.get(CASES_PATH, () =>
			HttpResponse.json(memberPortalEnvelope([])),
		),
		http.post(SUBMIT_CASE_PATH, () =>
			HttpResponse.json(
				memberPortalEnvelope({
					id: "500-case",
					caseNumber: "00001234",
					subject: "Exam question",
					status: "New",
					createdDate: "2026-09-01T00:00:00.000Z",
				}),
			),
		),
	)
}

async function renderPanel(tab: "get-help" | "requests" = "get-help") {
	return renderWithRouterProviders(<HelpCenterPanel tab={tab} />, {
		path: "/help-center/",
	})
}

describe("HelpCenterPanel — tab routing", () => {
	it("switching tab writes ?tab= into the URL instead of local state", async () => {
		serveOrg()
		const user = userEvent.setup()
		const { router } = await renderPanel()

		await user.click(screen.getByRole("tab", { name: /My Requests/ }))

		await waitFor(() => {
			expect(router.state.location.search).toMatchObject({ tab: "requests" })
		})
	})

	it("lands on My Requests after a successful submission", async () => {
		serveOrg()
		const user = userEvent.setup()
		const { router } = await renderPanel()

		await user.type(
			screen.getByRole("textbox", { name: "Subject" }),
			"Exam question",
		)
		await user.type(
			screen.getByRole("textbox", { name: "Description" }),
			"Where do I sit in November?",
		)
		await user.click(screen.getByRole("button", { name: "Submit" }))

		// The new case appearing in the list is the confirmation, so the
		// panel must route there rather than showing a thank-you here.
		await waitFor(() => {
			expect(router.state.location.search).toMatchObject({ tab: "requests" })
		})
	})
})
