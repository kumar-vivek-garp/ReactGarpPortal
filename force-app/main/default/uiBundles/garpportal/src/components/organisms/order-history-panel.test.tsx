import { screen, waitFor } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { delay, http, HttpResponse } from "msw"
import { describe, expect, it } from "vitest"

import type { PortalOrder } from "@/api/orders/types"
import { OrderHistoryPanel } from "@/components/organisms/order-history-panel"
import type { OrderFilter } from "@/config/order-history"
import {
	memberPortalEnvelope,
	memberPortalError,
} from "@/testing/factories/envelope"
import { portalOrder } from "@/testing/factories/orders"
import { server } from "@/testing/msw/server"
import { renderWithRouterProviders } from "@/testing/router"

const ORDERS_PATH = "/services/apexrest/memberportal/orders"

function serveOrders(unpaid: PortalOrder[], paid: PortalOrder[]) {
	server.use(
		http.get(ORDERS_PATH, () =>
			HttpResponse.json(
				memberPortalEnvelope({ unpaidOrders: unpaid, paidOrders: paid }),
			),
		),
	)
}

const unpaidOrder = () => portalOrder()
const paidOrder = () =>
	portalOrder({
		id: "006xx2",
		invoiceNumber: "INV-0002",
		description: "2026 Individual Membership",
		amount: 195,
		isPaid: true,
		isClosed: true,
		canPay: false,
		paymentStatus: "Paid",
	})

async function renderPanel(filter?: OrderFilter, entry = "/my-account") {
	return renderWithRouterProviders(
		<OrderHistoryPanel enabled filter={filter} />,
		{ path: "/my-account", initialEntries: [entry] },
	)
}

describe("OrderHistoryPanel — load states", () => {
	it("shows the skeleton while orders are on the wire", async () => {
		server.use(
			http.get(ORDERS_PATH, async () => {
				await delay("infinite")
				return HttpResponse.json(memberPortalEnvelope({}))
			}),
		)
		await renderPanel()

		expect(screen.getByLabelText("Loading orders")).toBeInTheDocument()
	})

	it("shows the error line when the service fails", async () => {
		server.use(
			http.get(ORDERS_PATH, () =>
				HttpResponse.json(memberPortalError(500, "boom"), { status: 500 }),
			),
		)
		await renderPanel()

		expect(
			await screen.findByText(/couldn't load your order history/),
		).toBeInTheDocument()
	})

	it("shows the zero state when the member has never bought anything", async () => {
		serveOrders([], [])
		await renderPanel()

		expect(await screen.findByText("No orders yet")).toBeInTheDocument()
		// The filter bar earns no place over an empty history.
		expect(screen.queryByRole("group")).not.toBeInTheDocument()
	})
})

describe("OrderHistoryPanel — the All view", () => {
	it("renders both sections with headed counts and the summary stats", async () => {
		serveOrders([unpaidOrder()], [paidOrder()])
		await renderPanel()

		expect(
			await screen.findByRole("heading", { name: /Unpaid Purchases/ }),
		).toBeInTheDocument()
		expect(
			screen.getByRole("heading", { name: /Paid Purchases/ }),
		).toBeInTheDocument()
		expect(
			screen.getByRole("link", { name: "View order FRM Part I Exam" }),
		).toBeInTheDocument()
		expect(
			screen.getByRole("link", {
				name: "View order 2026 Individual Membership",
			}),
		).toBeInTheDocument()
		// Toggle counts: all 2, unpaid 1, paid 1.
		expect(screen.getByRole("radio", { name: /All.*\(2\)/ })).toBeInTheDocument()
		expect(
			screen.getByRole("radio", { name: /Unpaid.*\(1\)/ }),
		).toBeInTheDocument()
	})

	it("keeps an empty bucket visible with its own empty panel", async () => {
		serveOrders([unpaidOrder()], [])
		await renderPanel()

		expect(
			await screen.findByText("No paid purchases"),
		).toBeInTheDocument()
		expect(
			screen.getByText("Completed purchases will appear here once they settle."),
		).toBeInTheDocument()
	})
})

describe("OrderHistoryPanel — scoping to one bucket", () => {
	it("renders only that bucket, without a heading over a lone section", async () => {
		serveOrders([unpaidOrder()], [paidOrder()])
		await renderPanel("unpaid")

		expect(
			await screen.findByRole("link", { name: "View order FRM Part I Exam" }),
		).toBeInTheDocument()
		expect(
			screen.queryByRole("heading", { name: /Unpaid Purchases/ }),
		).not.toBeInTheDocument()
		expect(
			screen.queryByRole("link", {
				name: "View order 2026 Individual Membership",
			}),
		).not.toBeInTheDocument()
	})

	it("writes the picked filter into ?orders= without dropping other params", async () => {
		const user = userEvent.setup()
		serveOrders([unpaidOrder()], [paidOrder()])
		const { router } = await renderPanel(
			undefined,
			"/my-account?status=success",
		)
		await screen.findByRole("link", { name: "View order FRM Part I Exam" })

		await user.click(screen.getByRole("radio", { name: /Paid.*\(1\)/ }))

		await waitFor(() => {
			expect(router.state.location.search).toMatchObject({
				orders: "paid",
				status: "success",
			})
		})
	})
})

describe("OrderHistoryPanel — search", () => {
	it("narrows rows by invoice and swaps empty copy to the search variant", async () => {
		const user = userEvent.setup()
		serveOrders([unpaidOrder()], [paidOrder()])
		await renderPanel()
		await screen.findByRole("link", { name: "View order FRM Part I Exam" })

		await user.type(screen.getByRole("textbox", { name: "Search orders" }), "INV-0002")

		expect(
			screen.getByRole("link", {
				name: "View order 2026 Individual Membership",
			}),
		).toBeInTheDocument()
		expect(
			screen.queryByRole("link", { name: "View order FRM Part I Exam" }),
		).not.toBeInTheDocument()
		expect(
			screen.getByText("No unpaid purchases match your search"),
		).toBeInTheDocument()
	})
})
