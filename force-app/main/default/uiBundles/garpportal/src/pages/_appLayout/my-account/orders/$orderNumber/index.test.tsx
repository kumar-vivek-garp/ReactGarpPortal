import { screen } from "@testing-library/react"
import { delay, http, HttpResponse } from "msw"
import { describe, expect, it } from "vitest"

import { memberPortalEnvelope } from "@/testing/factories/envelope"
import { renderFileRoute } from "@/testing/file-route"
import { server } from "@/testing/msw/server"

import { Route } from "./index"

const ORDER_DETAIL_PATH = "/services/apexrest/memberportal/orderDetail"

const happyPayload = {
	statusCode: 200,
	statusMessage: null,
	order: {
		id: "006x1",
		invoiceNumber: "INV-1001",
		description: "2026 Individual Membership",
		orderDate: "2026-01-15",
		amount: 195,
		currencyCode: "USD",
		stage: "Closed Won",
		paymentStatus: "Paid",
		paymentMethod: "Credit Card",
		isPaid: true,
		isClosed: true,
		canPay: false,
	},
}

const mount = () =>
	renderFileRoute(Route, {
		id: "/_appLayout/my-account/orders/$orderNumber/",
		path: "/my-account/orders/$orderNumber/",
		initialEntries: ["/my-account/orders/INV-1001"],
	})

describe("/my-account/orders/$orderNumber page", () => {
	it("renders the order description as the heading with data", async () => {
		server.use(
			http.get(ORDER_DETAIL_PATH, () =>
				HttpResponse.json(memberPortalEnvelope(happyPayload)),
			),
		)
		await mount()

		expect(
			await screen.findByRole("heading", {
				level: 1,
				name: "2026 Individual Membership",
			}),
		).toBeInTheDocument()
	})

	it("shows the order skeleton while loading", async () => {
		server.use(
			http.get(ORDER_DETAIL_PATH, async () => {
				await delay("infinite")
				return HttpResponse.json(memberPortalEnvelope(happyPayload))
			}),
		)
		await mount()

		expect(
			screen.getByLabelText("Loading order details"),
		).toBeInTheDocument()
	})

	it("surfaces the refusal message when the order is not on the account", async () => {
		server.use(
			http.get(ORDER_DETAIL_PATH, () =>
				HttpResponse.json(
					memberPortalEnvelope({
						statusCode: 404,
						statusMessage: "Order not found",
						order: null,
					}),
				),
			),
		)
		await mount()

		expect(await screen.findByText("Order not found")).toBeInTheDocument()
	})
})
