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
		/*
		 * No pending claims in this payload, so the page opens on Approved —
		 * landing on an empty Pending tab with the member's credits one click
		 * away is the case `resolveCpdTab` exists to avoid.
		 */
		expect(await screen.findByText("Risk seminar")).toBeInTheDocument()
		expect(
			screen.getByRole("tab", { name: /Approved/, selected: true }),
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

		/*
		 * The shared `EmptyState`: headline then supporting line, both plain
		 * paragraphs — it is a state, not a section, so it claims no heading.
		 */
		expect(
			await screen.findByText("We couldn't load your CPD record"),
		).toBeInTheDocument()
		expect(screen.getByText("Please try again later.")).toBeInTheDocument()
	})
})
