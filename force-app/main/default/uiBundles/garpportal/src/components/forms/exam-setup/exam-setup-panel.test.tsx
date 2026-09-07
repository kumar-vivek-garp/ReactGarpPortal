import { screen } from "@testing-library/react"
import { http, HttpResponse } from "msw"
import { describe, expect, it } from "vitest"

import type { ExamSetupView } from "@/api/exam-setup"
import { ExamSetupPanel } from "@/components/forms/exam-setup/exam-setup-panel"
import { accountOptionsView } from "@/testing/factories/account-options"
import { memberPortalEnvelope } from "@/testing/factories/envelope"
import { examSetupView } from "@/testing/factories/exam-setup"
import { server } from "@/testing/msw/server"
import { renderWithRouterProviders } from "@/testing/router"

const FORM_PATH = "/services/apexrest/memberportal/examSetup"
const OPTIONS_PATH = "/services/apexrest/memberportal/options"

function org(view: ExamSetupView = examSetupView()) {
	server.use(
		http.get(FORM_PATH, () => HttpResponse.json(memberPortalEnvelope(view))),
		http.get(OPTIONS_PATH, () =>
			HttpResponse.json(memberPortalEnvelope(accountOptionsView())),
		),
	)
}

// A router, because the bar's back link is a real `Link`.
const mount = (programType = "frm") =>
	renderWithRouterProviders(<ExamSetupPanel programType={programType} />)

const heading = () =>
	screen.getByRole("heading", { level: 1, name: /Financial Risk Manager.*Exam Setup/ })

describe("ExamSetupPanel — chrome", () => {
	it("titles the page with the certification in full, on every screen", async () => {
		org()
		await mount()
		expect(heading()).toBeInTheDocument()
		expect(
			await screen.findByRole("button", { name: "Save exam setup" }),
		).toBeInTheDocument()
	})

	it("keeps the title and a back link over the skeleton while loading", async () => {
		server.use(http.get(FORM_PATH, () => new Promise<never>(() => undefined)))
		await mount()

		expect(heading()).toBeInTheDocument()
		expect(screen.getByLabelText("Loading exam setup")).toBeInTheDocument()
		expect(screen.getByRole("link", { name: /FRM/ })).toBeInTheDocument()
	})

	it("reads the current sitting out in the bar", async () => {
		org()
		await mount()
		await screen.findByRole("button", { name: "Save exam setup" })

		expect(screen.getByText("Sitting")).toBeInTheDocument()
		expect(screen.getByText("May 2026 · London")).toBeInTheDocument()
	})

	// The bar's back link is the way out; a second one below would say the
	// same thing twice.
	it("offers no 'Back to My Programs' button", async () => {
		org()
		await mount()
		await screen.findByRole("button", { name: "Save exam setup" })
		expect(
			screen.queryByRole("link", { name: /Back to My Programs/ }),
		).not.toBeInTheDocument()
	})
})

describe("ExamSetupPanel — refusals", () => {
	it("refuses an unknown programme without asking the server", async () => {
		// No MSW handler is registered; strict unhandled-request mode would fail
		// the test if a request escaped.
		await mount("ffr")
		expect(screen.getByText("This program isn't open for exam setup.")).toBeInTheDocument()
	})

	// A 502 used to throw in the api layer, so this panel fell through to the
	// generic "unavailable" copy and the member was never told there was an
	// unpaid order waiting.
	it("shows the pending-reschedule refusal, with a way to the order", async () => {
		org(examSetupView({ statusCode: 502 }))
		await mount()

		expect(
			await screen.findByText("You already have a pending exam reschedule."),
		).toBeInTheDocument()
		expect(screen.getByRole("link", { name: "View your orders" })).toBeInTheDocument()
	})

	it("shows the unsupported refusal for a 501", async () => {
		org(examSetupView({ statusCode: 501 }))
		await mount()
		expect(
			await screen.findByText("This program isn't open for exam setup."),
		).toBeInTheDocument()
	})

	it("says there is nothing to set up when no part has an administration", async () => {
		org(examSetupView({ examPart1SelectionInfo: [], examPart2SelectionInfo: [] }))
		await mount()
		expect(await screen.findByText("Nothing to set up right now")).toBeInTheDocument()
	})

	it("shows the unavailable refusal when the request never ran", async () => {
		server.use(
			http.get(FORM_PATH, () =>
				HttpResponse.json(
					{ status: "Error", statusCode: 500, errorMessage: "Boom", data: {} },
					{ status: 500 },
				),
			),
		)
		await mount()
		expect(await screen.findByText("We couldn't load exam setup")).toBeInTheDocument()
	})
})
