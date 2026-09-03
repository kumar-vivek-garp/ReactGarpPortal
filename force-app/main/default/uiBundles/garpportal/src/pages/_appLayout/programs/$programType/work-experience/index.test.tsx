import { screen } from "@testing-library/react"
import { delay, http, HttpResponse } from "msw"
import { describe, expect, it } from "vitest"

import { memberPortalEnvelope } from "@/testing/factories/envelope"
import { cvView } from "@/testing/factories/work-experience"
import { renderFileRoute } from "@/testing/file-route"
import { server } from "@/testing/msw/server"

import { Route } from "./index"

const CV_PATH = "/services/apexrest/memberportal/cv"

const mount = () =>
	renderFileRoute(Route, {
		id: "/_appLayout/programs/$programType/work-experience/",
		path: "/programs/$programType/work-experience/",
		initialEntries: ["/programs/frm/work-experience"],
	})

/* Thin shell over WorkExperiencePanel, which has its own two-file suite. */
describe("/programs/$programType/work-experience page", () => {
	it("renders the heading and the empty CV state with data", async () => {
		server.use(
			http.get(CV_PATH, () =>
				HttpResponse.json(
					memberPortalEnvelope(cvView({ workExperiences: [] })),
				),
			),
		)
		await mount()

		expect(
			screen.getByRole("heading", { level: 1, name: "Work Experience" }),
		).toBeInTheDocument()
		expect(
			await screen.findByText("No experience added yet"),
		).toBeInTheDocument()
	})

	it("keeps the heading up over the skeleton while loading", async () => {
		server.use(
			http.get(CV_PATH, async () => {
				await delay("infinite")
				return HttpResponse.json(memberPortalEnvelope(cvView()))
			}),
		)
		await mount()

		expect(
			screen.getByRole("heading", { level: 1, name: "Work Experience" }),
		).toBeInTheDocument()
		expect(
			screen.getByLabelText("Loading work experience"),
		).toBeInTheDocument()
	})
})
