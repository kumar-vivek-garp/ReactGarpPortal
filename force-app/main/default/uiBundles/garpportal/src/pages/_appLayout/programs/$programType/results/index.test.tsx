import { screen } from "@testing-library/react"
import { delay, http, HttpResponse } from "msw"
import { describe, expect, it } from "vitest"

import {
	memberPortalEnvelope,
	memberPortalError,
} from "@/testing/factories/envelope"
import { renderFileRoute } from "@/testing/file-route"
import { server } from "@/testing/msw/server"

import { Route } from "./index"

const EXAM_RESULTS_PATH = "/services/apexrest/memberportal/examResults"
const RESULT_VIEWED_PATH = "/services/apexrest/memberportal/examResultViewed"

const passRow = {
	id: "a0X1",
	examLabel: "FRM Part I",
	examType: null,
	programType: "FRM",
	examPart: "I",
	examDate: "2025-05-17",
	administrationName: "May 2025",
	result: "Pass",
	outcome: "pass",
	message: null,
	showQuartiles: false,
	quartiles: [],
	resultsReleaseDate: null,
	resultsLetterUrl: null,
	quartilesUrl: null,
}

function serveResults(rows: unknown[]) {
	server.use(
		http.get(EXAM_RESULTS_PATH, () =>
			HttpResponse.json(memberPortalEnvelope(rows)),
		),
		// A released result is marked viewed from a mount effect.
		http.post(RESULT_VIEWED_PATH, () =>
			HttpResponse.json(memberPortalEnvelope({})),
		),
	)
}

const mount = () =>
	renderFileRoute(Route, {
		id: "/_appLayout/programs/$programType/results/",
		path: "/programs/$programType/results/",
		initialEntries: ["/programs/frm/results"],
	})

describe("/programs/$programType/results page", () => {
	it("renders the program heading and the released result", async () => {
		serveResults([passRow])
		await mount()

		expect(
			await screen.findByRole("heading", {
				level: 1,
				name: "FRM Exam Results",
			}),
		).toBeInTheDocument()
		expect(screen.getByText("FRM Part I")).toBeInTheDocument()
	})

	it("shows the program's empty state when no results exist", async () => {
		serveResults([])
		await mount()

		expect(
			await screen.findByText("No exam results for FRM yet"),
		).toBeInTheDocument()
	})

	it("shows the results skeleton while loading", async () => {
		server.use(
			http.get(EXAM_RESULTS_PATH, async () => {
				await delay("infinite")
				return HttpResponse.json(memberPortalEnvelope([]))
			}),
		)
		await mount()

		expect(
			screen.getByLabelText("Loading exam results"),
		).toBeInTheDocument()
	})

	it("surfaces the server's message when the load fails", async () => {
		server.use(
			http.get(EXAM_RESULTS_PATH, () =>
				HttpResponse.json(memberPortalError(500, "Results unavailable"), {
					status: 500,
				}),
			),
		)
		await mount()

		expect(
			await screen.findByText("Results unavailable"),
		).toBeInTheDocument()
	})
})
