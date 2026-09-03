import { screen, waitFor } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { describe, expect, it } from "vitest"

import { portalOrder } from "@/testing/factories/orders"
import { renderWithRouterProviders } from "@/testing/router"

import { OrderRow } from "./order-row"

describe("OrderRow", () => {
	it("presents the order as a single accessible link-row", async () => {
		await renderWithRouterProviders(<OrderRow order={portalOrder()} />)

		expect(
			screen.getByRole("link", { name: "View order FRM Part I Exam" }),
		).toBeInTheDocument()
		expect(screen.getByText("Unpaid")).toBeInTheDocument()
	})

	it("navigates to the order detail page once the press settles", async () => {
		const user = userEvent.setup()
		const { router } = await renderWithRouterProviders(
			<OrderRow order={portalOrder({ id: "006xx42" })} />,
		)

		await user.click(
			screen.getByRole("link", { name: "View order FRM Part I Exam" }),
		)

		// `onActivate` fires on a short settle timer so the press motion
		// completes before the route change — wait for the destination.
		await waitFor(() => {
			expect(router.state.location.pathname).toBe(
				"/my-account/orders/006xx42",
			)
		})
	})
})
