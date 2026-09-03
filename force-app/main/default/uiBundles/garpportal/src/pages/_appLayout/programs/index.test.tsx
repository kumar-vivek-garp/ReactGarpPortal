import { screen } from "@testing-library/react"
import { http, HttpResponse } from "msw"
import { describe, expect, it } from "vitest"

import { memberPortalEnvelope } from "@/testing/factories/envelope"
import { renderFileRoute } from "@/testing/file-route"
import { server } from "@/testing/msw/server"

import { Route } from "./index"

const PROGRAMS_PATH = "/services/apexrest/memberportal/programs"

/*
 * The route's loader AWAITS `ensureQueryData(programsQueryOptions)`, so the
 * happy payload must be served before mounting; pending/error live behind
 * `router.load()` and are not reachable from this harness.
 */
function servePrograms(overrides: Record<string, unknown> = {}) {
	server.use(
		http.get(PROGRAMS_PATH, () =>
			HttpResponse.json(
				memberPortalEnvelope({
					statusMessage: null,
					statusCode: 200,
					enrolledPrograms: [],
					completedPrograms: [],
					otherPrograms: [],
					hasCPDProgram: false,
					hasExamResults: false,
					microCourseConfig: null,
					...overrides,
				}),
			),
		),
	)
}

const enrolled = {
	programType: "frm",
	adminPartIName: null,
	adminPartIIName: null,
	// A logo URL so the route's head() preloads a program image too.
	programInformation: {
		myProgramsLogoURL: "https://hub.garp.org/logos/frm.png",
	},
}

const mount = (entry = "/programs") =>
	renderFileRoute(Route, {
		id: "/_appLayout/programs/",
		path: "/programs/",
		initialEntries: [entry],
	})

describe("/programs page", () => {
	it("renders the heading and the in-progress bucket with data", async () => {
		servePrograms({ enrolledPrograms: [enrolled] })
		// `?tab=all` renders the bucket sections; without it a member with an
		// enrollment lands on the in-progress bucket, which has no section h2.
		await mount("/programs?tab=all")

		expect(
			screen.getByRole("heading", { level: 1, name: "My Programs" }),
		).toBeInTheDocument()
		expect(
			await screen.findByRole("heading", { name: /In Progress/ }),
		).toBeInTheDocument()
	})

	it("scopes to a bucket from ?tab= and shows its own empty state", async () => {
		servePrograms()
		await mount("/programs?tab=completed")

		expect(
			await screen.findByText("No completed programs"),
		).toBeInTheDocument()
	})

	it("shows the overall empty state when there are no programs at all", async () => {
		servePrograms()
		await mount()

		expect(
			await screen.findByText("No programs to show"),
		).toBeInTheDocument()
	})
})
