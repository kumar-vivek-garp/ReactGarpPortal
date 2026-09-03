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

const STUDY_MATERIALS_PATH = "/services/apexrest/memberportal/studyMaterials"

/** Legacy Apex shape — normalized client-side into the catalogue buckets. */
const happyPayload = {
	statusMessage: null,
	statusCode: 200,
	studyMaterialsInfo: {
		frmStudyMaterials: [{ title: "FRM Study Guide", productCode: "SM-1" }],
	},
}

const mount = (entry = "/study-materials") =>
	renderFileRoute(Route, {
		id: "/_appLayout/study-materials/",
		path: "/study-materials/",
		initialEntries: [entry],
	})

describe("/study-materials page", () => {
	it("renders the heading and the catalogue once data arrives", async () => {
		server.use(
			http.get(STUDY_MATERIALS_PATH, () =>
				HttpResponse.json(memberPortalEnvelope(happyPayload)),
			),
		)
		await mount()

		expect(
			screen.getByRole("heading", {
				level: 1,
				name: "Study Materials for Risk Professionals",
			}),
		).toBeInTheDocument()
		expect(
			await screen.findByText("FRM Study Guide"),
		).toBeInTheDocument()
	})

	it("keeps the heading up over the skeleton while loading", async () => {
		server.use(
			http.get(STUDY_MATERIALS_PATH, async () => {
				await delay("infinite")
				return HttpResponse.json(memberPortalEnvelope(happyPayload))
			}),
		)
		await mount()

		expect(
			screen.getByRole("heading", {
				level: 1,
				name: "Study Materials for Risk Professionals",
			}),
		).toBeInTheDocument()
		expect(
			screen.getByLabelText("Loading study materials"),
		).toBeInTheDocument()
	})

	it("shows the error state when the catalogue fails", async () => {
		server.use(
			http.get(STUDY_MATERIALS_PATH, () =>
				HttpResponse.json(memberPortalError(500, "boom"), { status: 500 }),
			),
		)
		await mount()

		expect(
			await screen.findByText(
				"We couldn't load your study materials. Please try again later.",
			),
		).toBeInTheDocument()
	})
})
