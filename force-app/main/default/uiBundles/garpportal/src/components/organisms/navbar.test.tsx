import { screen } from "@testing-library/react"
import { http, HttpResponse } from "msw"
import { describe, expect, it } from "vitest"

import type { CurrentUser } from "@/api/auth/current-user"
import { TooltipProvider } from "@/components/atoms/tooltip"
import { Navbar } from "@/components/organisms/navbar"
import { memberPortalEnvelope } from "@/testing/factories/envelope"
import { server } from "@/testing/msw/server"
import { renderWithRouterProviders } from "@/testing/router"

const ALERT_BAR_PATH = "/services/apexrest/memberportal/alertBar"

const MEMBER: CurrentUser = {
	id: "005-member",
	name: "Ada Lovelace",
	garpId: "G-1",
	contactId: "003-member",
	photoUrl: null,
}

function serveNoAlert() {
	server.use(
		http.get(ALERT_BAR_PATH, () =>
			HttpResponse.json(
				memberPortalEnvelope({
					statusMessage: "No alerts found",
					statusCode: 200,
					examType: null,
					examPart: null,
					alertStatus: null,
					deadline: null,
					orderId: null,
					route: null,
				}),
			),
		),
	)
}

describe("Navbar", () => {
	it("anchors the wordmark to garp.org and carries the session controls", async () => {
		serveNoAlert()
		await renderWithRouterProviders(
			<TooltipProvider>
				<Navbar />
			</TooltipProvider>,
			{ user: MEMBER },
		)

		// Two banners by design: the desktop toolbar and the mobile toolbar.
		const banners = screen.getAllByRole("banner")
		expect(banners.length).toBeGreaterThanOrEqual(1)
		const logoLink = banners[0].querySelector(
			'a[href="https://www.garp.org/"]',
		)
		expect(logoLink).not.toBeNull()
		expect(
			screen.getAllByRole("button", { name: /sign out/i }).length,
		).toBeGreaterThanOrEqual(1)
	})
})
