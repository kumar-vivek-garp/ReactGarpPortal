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

const CPD_PROGRAM_PATH = "/services/apexrest/memberportal/cpdProgram"

const happyPayload = {
	currentCycle: "2025/2026",
	cycles: [
		{
			cycleName: "2025/2026",
			status: "active",
			creditsApproved: 20,
			creditsRequired: 40,
			isFRMActive: true,
			approvedClaims: [
				{
					claimId: "a01",
					title: "Risk seminar",
					activityTypeName: "Seminar",
					credits: 10,
					dateOfCompletion: "2025-06-01",
				},
			],
			pendingClaims: [],
		},
	],
}

const mount = (entry = "/cpd") =>
	renderFileRoute(Route, {
		id: "/_appLayout/cpd/",
		path: "/cpd/",
		initialEntries: [entry],
	})

describe("/cpd page", () => {
	it("renders the heading and the active cycle's claims with data", async () => {
		server.use(
			http.get(CPD_PROGRAM_PATH, () =>
				HttpResponse.json(memberPortalEnvelope(happyPayload)),
			),
		)
		await mount()

		expect(
			screen.getByRole("heading", {
				level: 1,
				name: "Continuing Professional Development",
			}),
		).toBeInTheDocument()
		expect(await screen.findByText("Risk seminar")).toBeInTheDocument()
		expect(
			screen.getByRole("heading", { name: /Approved Activities/ }),
		).toBeInTheDocument()
	})

	it("shows the zero state when no cycle exists yet", async () => {
		server.use(
			http.get(CPD_PROGRAM_PATH, () =>
				HttpResponse.json(
					memberPortalEnvelope({ currentCycle: null, cycles: [] }),
				),
			),
		)
		await mount()

		expect(await screen.findByText("No CPD cycle yet")).toBeInTheDocument()
	})

	it("keeps the heading up over the skeleton while loading", async () => {
		server.use(
			http.get(CPD_PROGRAM_PATH, async () => {
				await delay("infinite")
				return HttpResponse.json(memberPortalEnvelope(happyPayload))
			}),
		)
		await mount()

		expect(
			screen.getByRole("heading", {
				level: 1,
				name: "Continuing Professional Development",
			}),
		).toBeInTheDocument()
		expect(screen.getByLabelText("Loading CPD credits")).toBeInTheDocument()
	})

	it("shows the error state when the record fails to load", async () => {
		server.use(
			http.get(CPD_PROGRAM_PATH, () =>
				HttpResponse.json(memberPortalError(500, "boom"), { status: 500 }),
			),
		)
		await mount()

		expect(
			await screen.findByText(
				"We couldn't load your CPD record. Please try again later.",
			),
		).toBeInTheDocument()
	})
})
