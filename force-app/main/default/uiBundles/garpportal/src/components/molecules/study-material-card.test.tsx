import { fireEvent, screen } from "@testing-library/react"
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
		expect(screen.getByText("$295")).toBeInTheDocument()
		expect(screen.getByRole("link", { name: /Purchase/ })).toHaveAttribute(
			"href",
			"/study-materials/purchase/FRM2H",
		)
	})

	it("renders no action at all when nothing applies", async () => {
		await renderWithRouterProviders(<StudyMaterialCard item={studyItem()} />)
		expect(screen.queryByRole("link")).not.toBeInTheDocument()
		expect(screen.queryByRole("button")).not.toBeInTheDocument()
	})
})
