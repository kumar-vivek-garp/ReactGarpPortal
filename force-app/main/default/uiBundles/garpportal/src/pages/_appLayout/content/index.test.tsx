import { screen } from "@testing-library/react"
import { http, HttpResponse } from "msw"
import { describe, expect, it } from "vitest"

import { memberPortalEnvelope } from "@/testing/factories/envelope"
import { membershipView } from "@/testing/factories/identity"
import { renderFileRoute } from "@/testing/file-route"
import { server } from "@/testing/msw/server"

import { Route } from "./index"

/*
 * Thin shell over GatedContentPanel, which has its own deep suite — this only
 * proves the page mounts the panel at its route. With no `garp_gated_url`
 * cookie the panel resolves to the expired-link state.
 */
describe("/content page", () => {
	it("renders the gated-content panel", async () => {
		server.use(
			http.get("/services/apexrest/memberportal/membership", () =>
				HttpResponse.json(memberPortalEnvelope(membershipView())),
			),
		)
		await renderFileRoute(Route, {
			id: "/_appLayout/content/",
			path: "/content/",
			initialEntries: ["/content"],
		})

		expect(
			screen.getByRole("heading", { level: 1, name: "GARP Content" }),
		).toBeInTheDocument()
		expect(
			await screen.findByText("This link has expired"),
		).toBeInTheDocument()
	})
})
