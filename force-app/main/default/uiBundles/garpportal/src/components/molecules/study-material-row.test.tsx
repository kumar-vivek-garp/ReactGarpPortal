import { fireEvent, render, screen } from "@testing-library/react"
import { describe, expect, it } from "vitest"

import type { StudyItemPresentation } from "@/lib/study-materials-presentation"

import { StudyMaterialRow } from "./study-material-row"

function item(
	overrides: Partial<StudyItemPresentation> = {},
): StudyItemPresentation {
	return {
		id: "mat-1",
		variant: "owned",
		title: "FRM Exam Part I Books",
		programKey: "FRM",
		codeLabel: "FRM",
		typeLabel: "eBook",
		statusLabel: null,
		statusTone: null,
		paragraphs: [],
		imageUrl: null,
		metaLines: [],
		primaryAction: null,
		secondaryAction: null,
		...overrides,
	}
}

describe("StudyMaterialRow", () => {
	it("falls back to the code label when there is no artwork", () => {
		render(<StudyMaterialRow item={item()} />)

		expect(screen.getByRole("heading", { name: "FRM Exam Part I Books" }))
			.toBeInTheDocument()
		// Code appears twice: the artwork fallback and the chip.
		expect(screen.getAllByText("FRM").length).toBeGreaterThanOrEqual(2)
	})

	it("hides a broken artwork image instead of showing the broken glyph", () => {
		const { container } = render(
			<StudyMaterialRow item={item({ imageUrl: "https://cdn/broken.png" })} />,
		)

		const img = container.querySelector("img")
		expect(img).not.toBeNull()
		fireEvent.error(img as HTMLImageElement)

		expect((img as HTMLImageElement).style.display).toBe("none")
	})
})
