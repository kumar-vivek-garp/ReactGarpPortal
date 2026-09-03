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

const CASES_PATH = "/services/apexrest/memberportal/cases"

function serveCases(cases: unknown[]) {
	server.use(
		http.get(CASES_PATH, () =>
			HttpResponse.json(memberPortalEnvelope(cases)),
		),
	)
}

const mount = (entry = "/help-center") =>
	renderFileRoute(Route, {
		id: "/_appLayout/help-center/",
		path: "/help-center/",
		initialEntries: [entry],
	})

describe("/help-center page", () => {
	it("renders the heading and the support form on the default tab", async () => {
		serveCases([])
		await mount()

		expect(
			screen.getByRole("heading", { level: 1, name: "Help Center" }),
		).toBeInTheDocument()
		expect(
			await screen.findByText("Open a support case"),
		).toBeInTheDocument()
	})

	it("lists raised requests on ?tab=requests", async () => {
		serveCases([
			{
				id: "500x1",
				caseNumber: "00012345",
				subject: "Cannot download certificate",
				status: "New",
				createdDate: "2026-02-01T10:00:00.000Z",
			},
		])
		await mount("/help-center?tab=requests")

		expect(
			await screen.findByText("Cannot download certificate"),
		).toBeInTheDocument()
	})

	it("shows the requests empty state when nothing was raised", async () => {
		serveCases([])
		await mount("/help-center?tab=requests")

		expect(
			await screen.findByText("You haven't raised any requests yet"),
		).toBeInTheDocument()
	})

	it("shows the requests error state when the listing fails", async () => {
		server.use(
			http.get(CASES_PATH, () =>
				HttpResponse.json(memberPortalError(500, "boom"), { status: 500 }),
			),
		)
		await mount("/help-center?tab=requests")

		expect(
			await screen.findByText("We couldn't load your requests"),
		).toBeInTheDocument()
	})
})
