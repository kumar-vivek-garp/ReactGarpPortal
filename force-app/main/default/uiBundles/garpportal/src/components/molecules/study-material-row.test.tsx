import { fireEvent, screen } from "@testing-library/react"
import { describe, expect, it } from "vitest"

import { studyItem } from "@/testing/factories/study-materials"
import { renderWithRouterProviders } from "@/testing/router"

import { StudyMaterialRow } from "./study-material-row"

describe("StudyMaterialRow", () => {
	it("falls back to the code label when there is no artwork", async () => {
		await renderWithRouterProviders(<StudyMaterialRow item={studyItem()} />)

		expect(
			screen.getByRole("heading", { name: "2026 FRM Exam Part II Books" }),
		).toBeInTheDocument()
		// Code appears twice: the artwork fallback and the chip.
		expect(screen.getAllByText("FRM").length).toBeGreaterThanOrEqual(2)
	})

	it("hides a broken artwork image instead of showing the broken glyph", async () => {
		const { container } = await renderWithRouterProviders(
			<StudyMaterialRow item={studyItem({ imageUrl: "https://cdn/broken.png" })} />,
		)

		const img = container.querySelector("img")
		expect(img).not.toBeNull()
		fireEvent.error(img as HTMLImageElement)

		expect((img as HTMLImageElement).style.display).toBe("none")
	})

	it("shares the card's rules — status chip, eBook titles, add-on and action", async () => {
		await renderWithRouterProviders(
			<StudyMaterialRow
				item={studyItem({
					isOwned: true,
					wasOrderedWithReg: true,
					eBookSet: {
						expireDate: null,
						titles: [{ id: "111", label: "Part I", vendorId: "111", provider: null }],
					},
					addOn: {
						kind: "owned",
						heading: "Add-On Content",
						description: "",
						purchasedDate: null,
					},
				})}
			/>,
		)
		expect(screen.getByText("Owned")).toBeInTheDocument()
		expect(screen.getByRole("button", { name: /Read/ })).toBeInTheDocument()
		expect(screen.getByText("Add-On Content")).toBeInTheDocument()
		expect(screen.getByText("Included with your registration")).toBeInTheDocument()
	})
})
