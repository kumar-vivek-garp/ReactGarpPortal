import { createFileRoute } from "@tanstack/react-router"
import { screen } from "@testing-library/react"
import { describe, expect, it } from "vitest"

import { renderFileRoute } from "@/testing/file-route"

import { OrderDetailPending } from "./order-detail-pending"

const ROUTE_ID = "/_appLayout/my-account/orders/$orderNumber/"

describe("OrderDetailPending — route wrapper", () => {
	it("renders the order-detail shell with its loading landmark", async () => {
		const route = createFileRoute(ROUTE_ID)({
			component: OrderDetailPending,
		})
		await renderFileRoute(route, {
			id: ROUTE_ID,
			path: "/my-account/orders/$orderNumber/",
			initialEntries: ["/my-account/orders/00012345"],
		})

		expect(screen.getByLabelText("Loading order details")).toHaveAttribute(
			"aria-busy",
		)
		// The real back link renders, so the header does not jump on load.
		expect(
			screen.getByRole("link", { name: /order history/i }),
		).toBeInTheDocument()
	})
})
