import { screen, waitFor } from "@testing-library/react"
import { describe, expect, it } from "vitest"

import { OrderSummaryBar } from "@/components/molecules/order-summary-bar"
import type { OrdersSummary } from "@/lib/order-presentation"
import { renderWithRouterProviders } from "@/testing/router"

function summary(overrides: Partial<OrdersSummary> = {}): OrdersSummary {
	return {
		outstanding: [{ currency: "USD", total: 750, formatted: "$750.00" }],
		hasPayable: true,
		unpaidCount: 2,
		paidCount: 5,
		totalCount: 7,
		...overrides,
	}
}

describe("what do I owe?", () => {
	it("headlines a single-currency balance and offers Pay now", async () => {
		await renderWithRouterProviders(<OrderSummaryBar summary={summary()} />)

		// The balance counts up via a spring; wait for it to settle.
		await waitFor(() => {
			expect(screen.getByText("$750.00")).toBeInTheDocument()
		})
		const pay = screen.getByRole("link", { name: "Pay now" })
		expect(pay.getAttribute("href")).toContain("orders=unpaid")
		expect(screen.getByText("2")).toBeInTheDocument()
		expect(screen.getByText("7")).toBeInTheDocument()
	})

	it("says Nothing due plainly, with no Pay control", async () => {
		await renderWithRouterProviders(
			<OrderSummaryBar
				summary={summary({
					outstanding: [],
					hasPayable: false,
					unpaidCount: 0,
					totalCount: 5,
				})}
			/>,
		)
		expect(screen.getByText("Nothing due")).toBeInTheDocument()
		expect(
			screen.queryByRole("link", { name: "Pay now" }),
		).not.toBeInTheDocument()
	})

	it("lists each currency separately rather than faking one total", async () => {
		await renderWithRouterProviders(
			<OrderSummaryBar
				summary={summary({
					outstanding: [
						{ currency: "USD", total: 100, formatted: "$100.00" },
						{ currency: "EUR", total: 50, formatted: "€50.00" },
					],
				})}
			/>,
		)
		await waitFor(() => {
			expect(screen.getByText("$100.00")).toBeInTheDocument()
			expect(screen.getByText("€50.00")).toBeInTheDocument()
		})
	})

	it("keeps the Pay control back when the balance is not payable", async () => {
		// Outstanding money can exist on orders Apex marks canPay: false.
		await renderWithRouterProviders(
			<OrderSummaryBar summary={summary({ hasPayable: false })} />,
		)
		expect(
			screen.queryByRole("link", { name: "Pay now" }),
		).not.toBeInTheDocument()
	})
})
