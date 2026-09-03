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

const CPD_ACTIVITIES_PATH = "/services/apexrest/memberportal/cpdActivities"

function serveActivities(rows: unknown[], totalCount = rows.length) {
	server.use(
		http.get(CPD_ACTIVITIES_PATH, () =>
			HttpResponse.json(
				memberPortalEnvelope({
					cpdActivities: rows,
					totalCount,
					activityTypes: ["Webcast"],
					areasOfStudy: [],
					providers: ["GARP"],
					sortOptions: [],
				}),
			),
		),
	)
}

const activity = {
	id: "a05",
	title: "Model Risk Webcast",
	credits: 2,
	activityType: "Webcast",
	provider: "GARP",
	activityDate: "June 2025",
	url: "https://garp.org/a05",
}

const mount = (entry = "/cpd/activities") =>
	renderFileRoute(Route, {
		id: "/_appLayout/cpd/activities/",
		path: "/cpd/activities/",
		initialEntries: [entry],
	})

describe("/cpd/activities page", () => {
	it("renders the heading and the activity list with data", async () => {
		serveActivities([activity])
		await mount()

		expect(
			screen.getByRole("heading", { level: 1, name: "Browse CPD Activities" }),
		).toBeInTheDocument()
		expect(
			await screen.findByText("Model Risk Webcast"),
		).toBeInTheDocument()
	})

	it("shows the delisted state for an activityId that no longer resolves", async () => {
		serveActivities([])
		await mount("/cpd/activities?activityId=a99")

		expect(
			await screen.findByText("This activity is no longer listed"),
		).toBeInTheDocument()
	})

	it("shows the filter zero state when nothing matches", async () => {
		serveActivities([])
		await mount()

		expect(
			await screen.findByText("No CPD activity found"),
		).toBeInTheDocument()
	})

	it("shows the error state when the listing fails", async () => {
		server.use(
			http.get(CPD_ACTIVITIES_PATH, () =>
				HttpResponse.json(memberPortalError(500, "boom"), { status: 500 }),
			),
		)
		await mount()

		expect(
			await screen.findByText(
				"We couldn't load credit opportunities. Please try again later.",
			),
		).toBeInTheDocument()
	})
})
