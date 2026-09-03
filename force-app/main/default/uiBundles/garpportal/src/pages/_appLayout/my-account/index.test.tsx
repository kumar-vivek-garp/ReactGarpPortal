import { screen } from "@testing-library/react"
import { http, HttpResponse } from "msw"
import { describe, expect, it } from "vitest"

import type { CurrentUser } from "@/api/auth/current-user"
import { accountView } from "@/testing/factories/account"
import { memberPortalEnvelope } from "@/testing/factories/envelope"
import { renderFileRoute } from "@/testing/file-route"
import { server } from "@/testing/msw/server"

import { Route } from "./index"

const API = "/services/apexrest/memberportal"

/** Session member — seeded so `useCurrentUser` never hits the wire. */
const member: CurrentUser = {
	id: "005XX0000012345",
	name: "Ada Lovelace",
	garpId: "123456",
	contactId: "003XX0000012345",
	photoUrl: null,
}

function serveAccountOrg() {
	server.use(
		http.get(`${API}/account`, () =>
			HttpResponse.json(memberPortalEnvelope(accountView())),
		),
		// The account-information cards each pull their own feed on mount.
		http.get(`${API}/options`, () =>
			HttpResponse.json(
				memberPortalEnvelope({ picklists: {}, chapters: [] }),
			),
		),
		http.get(`${API}/expertise`, () =>
			HttpResponse.json(
				memberPortalEnvelope({
					statusMessage: null,
					statusCode: 200,
					values: {},
					options: {},
					labels: {},
				}),
			),
		),
		http.get(`${API}/orders`, () =>
			HttpResponse.json(memberPortalEnvelope([])),
		),
	)
}

const mount = (entry = "/my-account") =>
	renderFileRoute(Route, {
		id: "/_appLayout/my-account/",
		path: "/my-account/",
		initialEntries: [entry],
		user: member,
	})

describe("/my-account page", () => {
	it("renders the heading and the account-information tab by default", async () => {
		serveAccountOrg()
		await mount()

		expect(
			screen.getByRole("heading", { level: 1, name: "My Account" }),
		).toBeInTheDocument()
		expect(
			screen.getByRole("tab", { name: "Account Information" }),
		).toBeInTheDocument()
		expect(
			await screen.findByText("Ada Lovelace", { exact: false }),
		).toBeInTheDocument()
	})

	it("selects the order-history tab from ?tab=", async () => {
		serveAccountOrg()
		await mount("/my-account?tab=order-history")

		expect(
			screen.getByRole("tab", { name: "Order History", selected: true }),
		).toBeInTheDocument()
	})
})
