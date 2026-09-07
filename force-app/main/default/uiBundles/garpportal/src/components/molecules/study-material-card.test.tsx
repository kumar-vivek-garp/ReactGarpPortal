import { fireEvent, screen, within } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { describe, expect, it } from "vitest"

import { StudyMaterialCard } from "@/components/molecules/study-material-card"
import { studyItem } from "@/testing/factories/study-materials"
import { renderWithRouterProviders } from "@/testing/router"

describe("StudyMaterialCard — badges", () => {
	it("always chips the program code; status and type only when there is one", async () => {
		await renderWithRouterProviders(
			<StudyMaterialCard item={studyItem({ typeLabel: null })} />,
		)
		expect(screen.getByText("FRM")).toBeInTheDocument()
		expect(screen.queryByText("Owned")).not.toBeInTheDocument()
	})

	it("chips ownership and the material type from the item's facts", async () => {
		await renderWithRouterProviders(
			<StudyMaterialCard item={studyItem({ isOwned: true, typeLabel: "eBook" })} />,
		)
		expect(screen.getByText("Owned")).toBeInTheDocument()
		expect(screen.getByText("eBook")).toBeInTheDocument()
	})
})

describe("StudyMaterialCard — body", () => {
	it("renders the stripped description and the artwork, hiding it on load failure", async () => {
		await renderWithRouterProviders(
			<StudyMaterialCard
				item={studyItem({
					description: "Four digital books covering Part I.",
					imageUrl: "https://hub.garp.org/frm-books.png",
				})}
				priority
			/>,
		)
		expect(screen.getByText("Four digital books covering Part I.")).toBeInTheDocument()
		const art = document.querySelector("img") as HTMLImageElement
		expect(art).toHaveAttribute("loading", "eager")
		fireEvent.error(art)
		expect(art).not.toBeVisible()
	})

	it("lists the eBook titles under Your eBooks only when the item carries a key", async () => {
		const { unmount } = await renderWithRouterProviders(
			<StudyMaterialCard
				item={studyItem({
					eBookSet: {
						expireDate: "2030-12-31",
						titles: [{ id: "111", label: "Part I", vendorId: "111", provider: null }],
					},
				})}
			/>,
		)
		expect(screen.getByText("Your eBooks")).toBeInTheDocument()
		expect(screen.getByRole("button", { name: /Read/ })).toBeInTheDocument()
		expect(screen.getByText(/Access until/)).toBeInTheDocument()
		unmount()

		await renderWithRouterProviders(<StudyMaterialCard item={studyItem()} />)
		expect(screen.queryByText("Your eBooks")).not.toBeInTheDocument()
	})

	it("shows the GARP Learning add-on only when Apex attached one", async () => {
		await renderWithRouterProviders(
			<StudyMaterialCard
				item={studyItem({
					addOn: {
						kind: "purchasable",
						heading: "Upgrade for Additional Content",
						description: "",
						price: 75,
						productCode: "FRM1BPPE",
						pendingOrderId: null,
					},
				})}
			/>,
		)
		expect(screen.getByText("Upgrade for Additional Content")).toBeInTheDocument()
	})
})

describe("StudyMaterialCard — footer", () => {
	it("renders the resolved action", async () => {
		await renderWithRouterProviders(
			<StudyMaterialCard item={studyItem({ canPurchase: true, price: 295 })} />,
		)
		expect(screen.getByText("USD 295")).toBeInTheDocument()
		expect(screen.getByRole("link", { name: /Purchase/ })).toHaveAttribute(
			"href",
			"/study-materials/purchase/FRM2H",
		)
	})

	it("renders no action at all when nothing applies", async () => {
		const item = studyItem()
		await renderWithRouterProviders(<StudyMaterialCard item={item} />)

		expect(screen.queryByRole("link")).not.toBeInTheDocument()
		// The details trigger is not an action — every card carries one, whether
		// or not the material can be read, downloaded or bought.
		const buttons = screen.getAllByRole("button")
		expect(buttons).toHaveLength(1)
		expect(buttons[0]).toHaveAccessibleName(`View details for ${item.title}`)
	})
})

describe("StudyMaterialCard — the details dialog", () => {
	/*
	 * The card clamps `description` to three lines to keep every card the same
	 * height, which cuts the longer catalogue blurbs mid-sentence. The dialog is
	 * where the rest of it lives (UI/UX request, Sep 2026).
	 */
	const LONG =
		"Ideal for finance professionals in risk, auditing, accounting, consulting, " +
		"compliance, IT and insurance, the FRR Series illustrates how financial risk " +
		"impacts assets, institutions and systems, and the global financial infrastructure."

	it("opens on the card and shows the description in full", async () => {
		const user = userEvent.setup()
		const item = studyItem({ description: LONG })
		await renderWithRouterProviders(<StudyMaterialCard item={item} />)

		expect(screen.queryByRole("dialog")).not.toBeInTheDocument()
		await user.click(
			screen.getByRole("button", { name: `View details for ${item.title}` }),
		)

		const dialog = await screen.findByRole("dialog")
		expect(within(dialog).getByText(LONG)).toBeInTheDocument()
		expect(within(dialog).getByRole("heading", { name: item.title })).toBeInTheDocument()
	})

	it("says so rather than opening onto an empty dialog", async () => {
		const user = userEvent.setup()
		const item = studyItem({ description: null })
		await renderWithRouterProviders(<StudyMaterialCard item={item} />)

		await user.click(
			screen.getByRole("button", { name: `View details for ${item.title}` }),
		)

		expect(
			await screen.findByText("No description is available for this item."),
		).toBeInTheDocument()
	})
})
