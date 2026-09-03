import { screen } from "@testing-library/react"
import { http, HttpResponse } from "msw"
import { describe, expect, it } from "vitest"

import {
	memberPortalEnvelope,
	memberPortalError,
} from "@/testing/factories/envelope"
import { renderFileRoute } from "@/testing/file-route"
import { server } from "@/testing/msw/server"

import { Route } from "./index"

const ERRATA_FORM_PATH = "/services/apexrest/memberportal/errataForm"

function serveErrata(errataPicklistOption: Record<string, string[]>) {
	server.use(
		http.get(ERRATA_FORM_PATH, () =>
			HttpResponse.json(
				memberPortalEnvelope({
					statusMessage: null,
					statusCode: 200,
					errataPicklistOption,
				}),
			),
		),
	)
}

const mount = () =>
	renderFileRoute(Route, {
		id: "/_appLayout/programs/$programType/errata/",
		path: "/programs/$programType/errata/",
		initialEntries: ["/programs/frm/errata"],
	})

describe("/programs/$programType/errata page", () => {
	it("renders the heading and the report form with materials", async () => {
		serveErrata({
			"FRM Part I Book 1": ["Foundations of Risk Management"],
		})
		await mount()

		expect(
			screen.getByRole("heading", { level: 1, name: "Curriculum errata" }),
		).toBeInTheDocument()
		expect(
			await screen.findByRole("heading", { name: "Report an error" }),
		).toBeInTheDocument()
	})

	it("shows the no-materials state when nothing is published", async () => {
		serveErrata({})
		await mount()

		expect(
			await screen.findByText("No study material listed yet"),
		).toBeInTheDocument()
	})

	it("shows the error state when the form fails to load", async () => {
		server.use(
			http.get(ERRATA_FORM_PATH, () =>
				HttpResponse.json(memberPortalError(500, "boom"), { status: 500 }),
			),
		)
		await mount()

		expect(
			await screen.findByText(/We couldn't load the errata form/),
		).toBeInTheDocument()
	})
})
