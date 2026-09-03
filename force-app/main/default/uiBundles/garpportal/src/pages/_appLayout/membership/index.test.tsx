import { screen } from "@testing-library/react"
import { delay, http, HttpResponse } from "msw"
import { describe, expect, it } from "vitest"

import {
	memberPortalEnvelope,
	memberPortalError,
} from "@/testing/factories/envelope"
import { membershipView } from "@/testing/factories/identity"
import { renderFileRoute } from "@/testing/file-route"
import { server } from "@/testing/msw/server"

import { Route } from "./index"

const MEMBERSHIP_PATH = "/services/apexrest/memberportal/membership"

const mount = (entry = "/membership") =>
	renderFileRoute(Route, {
		id: "/_appLayout/membership/",
		path: "/membership/",
		initialEntries: [entry],
	})

describe("/membership page", () => {
	it("renders the heading, hero and benefits empty state with data", async () => {
		server.use(
			http.get(MEMBERSHIP_PATH, () =>
				HttpResponse.json(memberPortalEnvelope(membershipView())),
			),
		)
		await mount()

		expect(
			screen.getByRole("heading", { level: 1, name: "Membership Benefits" }),
		).toBeInTheDocument()
		expect(
			await screen.findByRole("heading", { name: "Ada Lovelace" }),
		).toBeInTheDocument()
		expect(
			screen.getByText("No benefits published yet"),
		).toBeInTheDocument()
	})

	it("keeps the heading up over the skeleton while loading", async () => {
		server.use(
			http.get(MEMBERSHIP_PATH, async () => {
				await delay("infinite")
				return HttpResponse.json(memberPortalEnvelope(membershipView()))
			}),
		)
		await mount()

		expect(
			screen.getByRole("heading", { level: 1, name: "Membership Benefits" }),
		).toBeInTheDocument()
		expect(
			screen.getByLabelText("Loading membership benefits"),
		).toBeInTheDocument()
	})

	it("shows the error state when the benefits fail to load", async () => {
		server.use(
			http.get(MEMBERSHIP_PATH, () =>
				HttpResponse.json(memberPortalError(500, "boom"), { status: 500 }),
			),
		)
		await mount()

		expect(
			await screen.findByText(
				"We couldn't load your membership benefits. Please try again later.",
			),
		).toBeInTheDocument()
	})
})
