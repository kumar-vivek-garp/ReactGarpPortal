import { screen } from "@testing-library/react"
import { describe, expect, it } from "vitest"

import { GarpLearningAddOnCard } from "@/components/molecules/garp-learning-add-on"
import { renderWithRouterProviders } from "@/testing/router"

describe("GarpLearningAddOnCard", () => {
	it("offers the upgrade with its price, and no purchase link", async () => {
		await renderWithRouterProviders(
			<GarpLearningAddOnCard
				addOn={{
					kind: "purchasable",
					heading: "Upgrade for Additional Content",
					description: "Purchase a third full-length practice exam for the FRM Part I.",
					price: 75,
					productCode: "FRM1BPPE",
					pendingOrderId: null,
				}}
			/>,
		)
		expect(screen.getByText("Upgrade for Additional Content")).toBeInTheDocument()
		expect(
			screen.getByText("Purchase a third full-length practice exam for the FRM Part I."),
		).toBeInTheDocument()
		expect(screen.getByText("$75")).toBeInTheDocument()
		expect(screen.queryByRole("link")).not.toBeInTheDocument()
	})

	it("points a pending add-on order at the order itself", async () => {
		await renderWithRouterProviders(
			<GarpLearningAddOnCard
				addOn={{
					kind: "purchasable",
					heading: "Upgrade for Additional Content",
					description: "",
					price: 75,
					productCode: "FRM1BPPE",
					pendingOrderId: "006ADDON",
				}}
			/>,
		)
		expect(screen.getByRole("link", { name: /Order awaiting payment/ })).toHaveAttribute(
			"href",
			"/my-account/orders/006ADDON",
		)
	})

	it("describes the owned add-on with no price and no link", async () => {
		await renderWithRouterProviders(
			<GarpLearningAddOnCard
				addOn={{
					kind: "owned",
					heading: "Add-On Content",
					description: "Access your third full-length practice exam for the FRM Part I.",
					purchasedDate: "2026-03-20",
				}}
			/>,
		)
		expect(screen.getByText("Add-On Content")).toBeInTheDocument()
		expect(screen.queryByText(/^\$/)).not.toBeInTheDocument()
		expect(screen.queryByRole("link")).not.toBeInTheDocument()
	})
})
