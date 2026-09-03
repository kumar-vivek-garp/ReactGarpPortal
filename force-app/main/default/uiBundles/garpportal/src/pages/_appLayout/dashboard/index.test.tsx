import { screen } from "@testing-library/react"
import { delay, http, HttpResponse } from "msw"
import { describe, expect, it } from "vitest"

import {
	memberPortalEnvelope,
	memberPortalError,
} from "@/testing/factories/envelope"
import { completeness } from "@/testing/factories/account"
import { identity } from "@/testing/factories/identity"
import { renderFileRoute } from "@/testing/file-route"
import { server } from "@/testing/msw/server"

import { Route } from "./index"

const API = "/services/apexrest/memberportal"

const emptyPrograms = {
	statusMessage: null,
	statusCode: 200,
	enrolledPrograms: [],
	completedPrograms: [],
	otherPrograms: [],
	hasCPDProgram: false,
	hasExamResults: false,
	microCourseConfig: null,
}

const emptyEvents = {
	statusMessage: null,
	statusCode: 200,
	registeredEvents: [],
	upcomingChapterMeetings: [],
	upcomingOtherEvents: [],
}

/** The five listing feeds beside the dashboard manifest itself. */
function serveListings() {
	server.use(
		http.get(`${API}/programs`, () =>
			HttpResponse.json(memberPortalEnvelope(emptyPrograms)),
		),
		http.get(`${API}/events`, () =>
			HttpResponse.json(memberPortalEnvelope(emptyEvents)),
		),
		http.get(`${API}/cpd`, () =>
			HttpResponse.json(
				memberPortalEnvelope({
					statusMessage: null,
					statusCode: 200,
					cpdCycle: null,
					frmTotalNeeded: null,
					frmCompleted: null,
					erpTotalNeeded: null,
					erpCompleted: null,
					scrTotalNeeded: null,
					scrCompleted: null,
				}),
			),
		),
		http.get(`${API}/ad`, () =>
			HttpResponse.json(memberPortalEnvelope({})),
		),
		http.get(`${API}/examNotifications`, () =>
			HttpResponse.json(
				memberPortalEnvelope({
					statusMessage: null,
					statusCode: 200,
					notifications: [],
				}),
			),
		),
	)
}

function serveDashboard() {
	server.use(
		http.get(`${API}/dashboard`, () =>
			HttpResponse.json(
				memberPortalEnvelope({
					identity: identity(),
					completeness: completeness(),
					dashboardComponents: [
						{ name: "Member Directory", rankOrder: 1 },
					],
					adType: null,
				}),
			),
		),
	)
}

const mount = () =>
	renderFileRoute(Route, {
		id: "/_appLayout/dashboard/",
		path: "/dashboard/",
		initialEntries: ["/dashboard"],
	})

describe("/dashboard page", () => {
	it("renders the heading and the manifest's cards once data arrives", async () => {
		serveListings()
		serveDashboard()
		await mount()

		expect(
			await screen.findByRole("heading", { level: 1, name: "Dashboard" }),
		).toBeInTheDocument()
		expect(
			await screen.findByText(/Member Directory/),
		).toBeInTheDocument()
		expect(
			screen.queryByLabelText("Loading dashboard"),
		).not.toBeInTheDocument()
	})

	it("keeps the heading up over the skeleton while loading", async () => {
		serveListings()
		server.use(
			http.get(`${API}/dashboard`, async () => {
				await delay("infinite")
				return HttpResponse.json(memberPortalEnvelope({}))
			}),
		)
		await mount()

		expect(
			screen.getByRole("heading", { level: 1, name: "Dashboard" }),
		).toBeInTheDocument()
		expect(screen.getByLabelText("Loading dashboard")).toBeInTheDocument()
	})

	it("shows the dashboard error state when the manifest fails", async () => {
		serveListings()
		server.use(
			http.get(`${API}/dashboard`, () =>
				HttpResponse.json(memberPortalError(500, "boom"), {
					status: 500,
				}),
			),
		)
		await mount()

		expect(
			await screen.findByText(
				"We couldn't load your dashboard. Please try again later.",
			),
		).toBeInTheDocument()
	})
})
