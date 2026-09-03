import { screen, waitFor } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { http, HttpResponse } from "msw"
import { afterEach, describe, expect, it, vi } from "vitest"

import type { PortalOrder } from "@/api/orders/types"
import { OrderDetailPanel } from "@/components/organisms/order-detail-panel"
import { memberPortalEnvelope } from "@/testing/factories/envelope"
import { portalOrder } from "@/testing/factories/orders"
import { server } from "@/testing/msw/server"
import { renderWithRouterProviders } from "@/testing/router"

const ORDER_DETAIL_PATH = "/services/apexrest/memberportal/orderDetail"
const PAY_ORDER_PATH = "/services/apexrest/memberportal/payOrder"
const CANCEL_ORDER_PATH = "/services/apexrest/memberportal/cancelOrder"
const CHECKOUT_COOKIE = "garp-checkout-session-token"

function serveDetail(order: PortalOrder | null) {
	server.use(
		http.get(ORDER_DETAIL_PATH, () =>
			HttpResponse.json(
				memberPortalEnvelope({
					statusCode: 200,
					statusMessage: null,
					order,
				}),
			),
		),
	)
}

const paidOrder = () =>
	portalOrder({
		invoiceNumber: "INV-1001",
		description: "2026 Individual Membership",
		amount: 195,
		stage: "Closed Won",
		paymentStatus: "Paid",
		paymentMethod: "Credit Card",
		isPaid: true,
		isClosed: true,
		canPay: false,
	})

const renderPanel = () =>
	renderWithRouterProviders(<OrderDetailPanel orderNumber="INV-0001" />)

afterEach(() => {
	document.cookie = `${CHECKOUT_COOKIE}=; path=/; max-age=0`
})

describe("OrderDetailPanel — what a payable order offers", () => {
	it("shows Pay, Cancel and Download together with the unpaid callout", async () => {
		serveDetail(portalOrder())
		await renderPanel()

		expect(
			await screen.findByRole("heading", { level: 1, name: "FRM Part I Exam" }),
		).toBeInTheDocument()
		expect(screen.getByRole("button", { name: "Pay Order" })).toBeEnabled()
		expect(screen.getByRole("button", { name: "Cancel Order" })).toBeEnabled()
		expect(screen.getByRole("button", { name: "Download Order" })).toBeEnabled()
		expect(screen.getByRole("link", { name: "View Orders" })).toBeInTheDocument()
	})

	it("offers neither Pay nor Cancel on a settled order", async () => {
		serveDetail(paidOrder())
		await renderPanel()

		await screen.findByRole("heading", {
			level: 1,
			name: "2026 Individual Membership",
		})
		expect(
			screen.queryByRole("button", { name: "Pay Order" }),
		).not.toBeInTheDocument()
		expect(
			screen.queryByRole("button", { name: "Cancel Order" }),
		).not.toBeInTheDocument()
		expect(screen.getByRole("button", { name: "Download Order" })).toBeEnabled()
	})

	it("falls back to the not-found line when the payload carries no order", async () => {
		serveDetail(null)
		await renderPanel()

		expect(
			await screen.findByText(
				"This order could not be found on your account.",
			),
		).toBeInTheDocument()
	})
})

describe("OrderDetailPanel — actions", () => {
	it("a zero-value payment (201) returns to Order History without Stripe", async () => {
		const user = userEvent.setup()
		serveDetail(portalOrder())
		let payBody: Record<string, string> | null = null
		server.use(
			http.post(PAY_ORDER_PATH, async ({ request }) => {
				payBody = (await request.json()) as Record<string, string>
				return HttpResponse.json(
					memberPortalEnvelope({ statusCode: 201, statusMessage: null }),
				)
			}),
		)
		const { router } = await renderPanel()

		await user.click(await screen.findByRole("button", { name: "Pay Order" }))

		await waitFor(() => {
			expect(router.state.location.pathname).toBe("/my-account")
		})
		expect(router.state.location.search).toMatchObject({ tab: "order-history" })
		expect(payBody).toEqual({ orderId: "006xx1" })
		// No Stripe hand-off happened: the checkout cookie was never written.
		expect(document.cookie).not.toContain(CHECKOUT_COOKIE)
	})

	it("cancelling posts the order id and returns to Order History", async () => {
		const user = userEvent.setup()
		serveDetail(portalOrder())
		let cancelBody: Record<string, string> | null = null
		server.use(
			http.post(CANCEL_ORDER_PATH, async ({ request }) => {
				cancelBody = (await request.json()) as Record<string, string>
				return HttpResponse.json(
					memberPortalEnvelope({ statusCode: 200, statusMessage: null }),
				)
			}),
		)
		const { router } = await renderPanel()

		await user.click(
			await screen.findByRole("button", { name: "Cancel Order" }),
		)

		await waitFor(() => {
			expect(router.state.location.pathname).toBe("/my-account")
		})
		expect(cancelBody).toEqual({ orderId: "006xx1" })
	})

	it("Download opens the invoice PDF in a new tab", async () => {
		const user = userEvent.setup()
		serveDetail(paidOrder())
		const open = vi.spyOn(window, "open").mockReturnValue(null)
		await renderPanel()

		await user.click(
			await screen.findByRole("button", { name: "Download Order" }),
		)

		expect(open).toHaveBeenCalledWith(
			"/apex/InvoicePrintAsPDF?id=006xx1",
			"_blank",
			"noopener,noreferrer",
		)
		open.mockRestore()
	})
})
