import { screen, waitFor } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { delay, http, HttpResponse } from "msw"
import { describe, expect, it, vi } from "vitest"

import { memberPortalError } from "@/testing/factories/envelope"
import {
	MATERIAL_QUOTE_PATH,
	materialPurchaseOrg,
} from "@/testing/msw/handlers/study-materials"
import { server } from "@/testing/msw/server"
import { createTestQueryClient } from "@/testing/query-client"
import { renderWithRouterProviders } from "@/testing/router"

import { StudyMaterialPurchasePanel } from "./study-material-purchase-panel"

const mount = (checkoutCancelled = false) =>
	renderWithRouterProviders(
		<StudyMaterialPurchasePanel productCode="SCRH" checkoutCancelled={checkoutCancelled} />,
		{ path: "/study-materials/purchase/SCRH" },
	)

describe("StudyMaterialPurchasePanel", () => {
	it("shows the checkout-shaped skeleton while the quote loads", async () => {
		server.use(
			http.get(MATERIAL_QUOTE_PATH, async () => {
				await delay("infinite")
				return HttpResponse.json({})
			}),
		)
		await mount()

		// Like every registration skeleton: the bar's slot is drawn, not titled.
		expect(screen.getByLabelText("Loading your purchase")).toBeInTheDocument()
		expect(screen.queryByRole("heading", { level: 1 })).not.toBeInTheDocument()
	})

	it("renders the form once the quote is in", async () => {
		server.use(...materialPurchaseOrg().handlers)
		await mount()

		expect(await screen.findByRole("button", { name: "Continue to Payment" })).toBeInTheDocument()
		// The way back rides in the sticky bar, as on every registration form.
		expect(screen.getByRole("link", { name: /Study Materials/ })).toBeInTheDocument()
	})

	it("says the item is not available for the service's 404, with a way back", async () => {
		server.use(...materialPurchaseOrg({ quote: null }).handlers)
		await mount()

		expect(
			await screen.findByRole("heading", { name: "This item is not available to purchase" }),
		).toBeInTheDocument()
		expect(screen.getByText(/It may already be yours/)).toBeInTheDocument()
		expect(screen.getAllByRole("link", { name: "Study Materials" }).length).toBeGreaterThan(0)
		expect(screen.queryByRole("button", { name: /Continue to Payment/ })).not.toBeInTheDocument()
	})

	it("renders a failure with the server's message and retries on request", async () => {
		let hits = 0
		server.use(
			http.get(MATERIAL_QUOTE_PATH, () => {
				hits += 1
				return HttpResponse.json(memberPortalError(500, "Pricing is down"), { status: 500 })
			}),
		)
		const user = userEvent.setup()
		await mount()

		expect(
			await screen.findByRole("heading", { name: "We couldn't load this purchase" }),
		).toBeInTheDocument()
		expect(screen.getByText("Pricing is down")).toBeInTheDocument()

		await user.click(screen.getByRole("button", { name: "Try again" }))
		await waitFor(() => expect(hits).toBe(2))
	})

	it("refreshes the catalogue and order history exactly once on the cancel leg", async () => {
		server.use(...materialPurchaseOrg().handlers)
		// The refresh fires on mount, so the spy has to be in place before it.
		const queryClient = createTestQueryClient()
		const spy = vi.spyOn(queryClient, "invalidateQueries")
		await renderWithRouterProviders(
			<StudyMaterialPurchasePanel productCode="SCRH" checkoutCancelled />,
			{ path: "/study-materials/purchase/SCRH", queryClient },
		)

		await screen.findByText("Payment cancelled")
		await waitFor(() => expect(spy).toHaveBeenCalled())
		const keys = spy.mock.calls.map(([options]) => JSON.stringify(options?.queryKey))
		expect(keys.filter((k) => k === '["study-materials"]')).toHaveLength(1)
		expect(keys.filter((k) => k === '["orders"]')).toHaveLength(1)
	})
})
