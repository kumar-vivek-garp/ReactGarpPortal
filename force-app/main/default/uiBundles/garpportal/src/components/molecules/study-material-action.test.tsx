import { screen } from "@testing-library/react"
import { describe, expect, it } from "vitest"

import { StudyMaterialAction } from "@/components/molecules/study-material-action"
import { renderWithRouterProviders } from "@/testing/router"

describe("StudyMaterialAction — links", () => {
	it("renders GARP Learning as a link CTA opening the SSO in a new tab", async () => {
		await renderWithRouterProviders(
			<StudyMaterialAction
				action={{ kind: "garpLearning", url: "https://learning.garp.org/sso?prog=FRM" }}
			/>,
		)
		const link = screen.getByRole("link", { name: "Access GARP Learning" })
		expect(link).toHaveAttribute("href", "https://learning.garp.org/sso?prog=FRM")
		expect(link).toHaveAttribute("target", "_blank")
		expect(link).toHaveAttribute("rel", expect.stringContaining("noopener"))
	})

	it("renders Read eBook and Download Now as external new-tab links", async () => {
		await renderWithRouterProviders(
			<>
				<StudyMaterialAction
					action={{ kind: "external", label: "Read eBook", url: "https://r.example", icon: "read" }}
				/>
				<StudyMaterialAction
					action={{ kind: "external", label: "Download Now", url: "https://d.example/x.pdf", icon: "download" }}
				/>
			</>,
		)
		expect(screen.getByRole("link", { name: /Read eBook/ })).toHaveAttribute("target", "_blank")
		expect(screen.getByRole("link", { name: /Download Now/ })).toHaveAttribute(
			"href",
			"https://d.example/x.pdf",
		)
	})

	it("renders Complete your order as an in-app link to the order", async () => {
		await renderWithRouterProviders(
			<StudyMaterialAction action={{ kind: "completeOrder", path: "/my-account/orders/006X" }} />,
		)
		const link = screen.getByRole("link", { name: /Complete your order/ })
		expect(link).toHaveAttribute("href", "/my-account/orders/006X")
		expect(link).not.toHaveAttribute("target")
	})

	it("renders the price beside an in-app Purchase link", async () => {
		await renderWithRouterProviders(
			<StudyMaterialAction
				action={{ kind: "purchase", priceLabel: "USD 295", path: "/study-materials/purchase/FRM2H" }}
			/>,
		)
		expect(screen.getByText("USD 295")).toBeInTheDocument()
		expect(screen.getByRole("link", { name: /Purchase/ })).toHaveAttribute(
			"href",
			"/study-materials/purchase/FRM2H",
		)
	})

	it("omits the price when Apex sent none", async () => {
		await renderWithRouterProviders(
			<StudyMaterialAction
				action={{ kind: "purchase", priceLabel: null, path: "/study-materials/purchase/X" }}
			/>,
		)
		expect(screen.queryByText(/^\$/)).not.toBeInTheDocument()
		expect(screen.getByRole("link", { name: /Purchase/ })).toBeInTheDocument()
	})
})

describe("StudyMaterialAction — statements", () => {
	/*
	 * There is no `owned` action any more — what the member paid and when is a
	 * meta line on the card (`materialMetaLines`), not the card's action.
	 */
	it("renders out of stock and contact as plain text with no link", async () => {
		await renderWithRouterProviders(
			<>
				<StudyMaterialAction action={{ kind: "outOfStock", text: "Out of stock" }} />
				<StudyMaterialAction
					action={{ kind: "contact", text: "Contact member services to buy this." }}
				/>
			</>,
		)
		expect(screen.getByText("Out of stock")).toBeInTheDocument()
		expect(screen.getByText("Contact member services to buy this.")).toBeInTheDocument()
		expect(screen.queryByRole("link")).not.toBeInTheDocument()
	})

	it("renders coming soon with a Notify me link only when there is somewhere to go", async () => {
		const { unmount } = await renderWithRouterProviders(
			<StudyMaterialAction
				action={{ kind: "comingSoon", text: "Available soon", notifyUrl: "https://www.garp.org/notify" }}
			/>,
		)
		expect(screen.getByText("Available soon")).toBeInTheDocument()
		expect(screen.getByRole("link", { name: /Notify me/ })).toHaveAttribute(
			"href",
			"https://www.garp.org/notify",
		)
		unmount()

		await renderWithRouterProviders(
			<StudyMaterialAction action={{ kind: "comingSoon", text: "Available soon", notifyUrl: null }} />,
		)
		expect(screen.queryByRole("link")).not.toBeInTheDocument()
	})

	it("renders nothing at all for none", async () => {
		const { container } = await renderWithRouterProviders(
			<StudyMaterialAction action={{ kind: "none" }} />,
		)
		expect(container.textContent).toBe("")
	})
})
