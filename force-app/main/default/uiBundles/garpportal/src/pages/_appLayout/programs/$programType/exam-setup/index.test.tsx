import { screen } from "@testing-library/react"
import { delay, http, HttpResponse } from "msw"
import { describe, expect, it } from "vitest"

import { memberPortalEnvelope } from "@/testing/factories/envelope"
import { examSetupView } from "@/testing/factories/exam-setup"
import { renderFileRoute } from "@/testing/file-route"
import { server } from "@/testing/msw/server"

import { Route } from "./index"

const EXAM_SETUP_PATH = "/services/apexrest/memberportal/examSetup"

const mount = () =>
	renderFileRoute(Route, {
		id: "/_appLayout/programs/$programType/exam-setup/",
		path: "/programs/$programType/exam-setup/",
		initialEntries: ["/programs/frm/exam-setup"],
	})

/* Thin shell over ExamSetupPanel, which has its own four-file suite. */
describe("/programs/$programType/exam-setup page", () => {
	it("renders the heading and the sitting step with data", async () => {
		server.use(
			http.get(EXAM_SETUP_PATH, () =>
				HttpResponse.json(memberPortalEnvelope(examSetupView())),
			),
		)
		await mount()

		expect(
			screen.getByRole("heading", { level: 1, name: "Exam setup" }),
		).toBeInTheDocument()
		expect(
			await screen.findByText("Choose your sitting"),
		).toBeInTheDocument()
	})

	it("keeps the heading up over the skeleton while loading", async () => {
		server.use(
			http.get(EXAM_SETUP_PATH, async () => {
				await delay("infinite")
				return HttpResponse.json(memberPortalEnvelope(examSetupView()))
			}),
		)
		await mount()

		expect(
			screen.getByRole("heading", { level: 1, name: "Exam setup" }),
		).toBeInTheDocument()
		expect(screen.getByLabelText("Loading exam setup")).toBeInTheDocument()
	})
})
