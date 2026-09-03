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

const PROGRAM_DETAIL_PATH = "/services/apexrest/memberportal/programDetail"

const happyPayload = {
	statusMessage: null,
	statusCode: 200,
	programsDetailInfo: {
		statusCode: 200,
		statusMessage: null,
		programType: "FRM",
		programState: "ExamAttempt",
		programInformation: {
			formalName: "Financial Risk Manager",
			informalName: null,
			abbrevName: null,
			myProgramsLogoURL: null,
		},
		examPart1Info: null,
		examPart2Info: null,
	},
}

const mount = () =>
	renderFileRoute(Route, {
		id: "/_appLayout/programs/$programType/",
		path: "/programs/$programType/",
		initialEntries: ["/programs/frm"],
	})

describe("/programs/$programType page", () => {
	it("renders the program's name as the page heading with data", async () => {
		server.use(
			http.get(PROGRAM_DETAIL_PATH, () =>
				HttpResponse.json(memberPortalEnvelope(happyPayload)),
			),
		)
		await mount()

		expect(
			await screen.findByRole("heading", {
				level: 1,
				name: /Financial Risk Manager/,
			}),
		).toBeInTheDocument()
	})

	it("shows the detail skeleton while loading", async () => {
		server.use(
			http.get(PROGRAM_DETAIL_PATH, async () => {
				await delay("infinite")
				return HttpResponse.json(memberPortalEnvelope(happyPayload))
			}),
		)
		await mount()

		expect(
			screen.getByLabelText("Loading program details"),
		).toBeInTheDocument()
	})

	it("surfaces the server's message when the load fails", async () => {
		server.use(
			http.get(PROGRAM_DETAIL_PATH, () =>
				HttpResponse.json(memberPortalError(500, "Program unavailable"), {
					status: 500,
				}),
			),
		)
		await mount()

		expect(
			await screen.findByText("Program unavailable"),
		).toBeInTheDocument()
	})
})
