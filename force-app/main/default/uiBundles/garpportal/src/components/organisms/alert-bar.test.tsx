import { screen, waitFor } from "@testing-library/react"
import { http, HttpResponse } from "msw"
import { beforeEach, describe, expect, it } from "vitest"

import type { AlertBarView } from "@/api/alert-bar/types"
import { AlertBar } from "@/components/organisms/alert-bar"
import { useAlertBarStore } from "@/store/alert-bar-store"
import { memberPortalEnvelope } from "@/testing/factories/envelope"
import { server } from "@/testing/msw/server"
import { renderWithRouterProviders } from "@/testing/router"
import { skipSpringAnimations } from "@/testing/springs"

// Safe: AlertBarCard's springs only (no useSubpageTransition in this tree).
skipSpringAnimations()

const ALERT_BAR_PATH = "/services/apexrest/memberportal/alertBar"

function alertBarView(overrides: Partial<AlertBarView> = {}): AlertBarView {
	return {
		statusMessage: null,
		statusCode: 200,
		examType: "FRM",
		examPart: "I",
		alertStatus: "Exam Unpaid",
		deadline: "2026-10-01",
		orderId: "006xx0000001",
		route: "Complete Payment",
		...overrides,
	}
}

beforeEach(() => {
	useAlertBarStore.setState({
		phase: "expanded",
		phaseFor: null,
		anchors: { desktop: null, mobile: null },
	})
})

describe("AlertBar", () => {
	it("surfaces the one live alert as the expanded card", async () => {
		server.use(
			http.get(ALERT_BAR_PATH, () =>
				HttpResponse.json(memberPortalEnvelope(alertBarView())),
			),
		)
		await renderWithRouterProviders(<AlertBar />)

		const alert = await screen.findByRole("alert")
		expect(alert).toHaveTextContent("FRM Part I")
	})

	it("renders nothing at all when the member has no alert", async () => {
		let served = false
		server.use(
			http.get(ALERT_BAR_PATH, () => {
				served = true
				return HttpResponse.json(
					memberPortalEnvelope(
						alertBarView({ alertStatus: null, statusMessage: "No alerts found" }),
					),
				)
			}),
		)
		const { container } = await renderWithRouterProviders(<AlertBar />)

		await waitFor(() => expect(served).toBe(true))
		await waitFor(() => expect(container).toBeEmptyDOMElement())
	})
})
