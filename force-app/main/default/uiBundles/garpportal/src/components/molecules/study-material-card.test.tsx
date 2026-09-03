import { fireEvent, screen } from "@testing-library/react"
import { describe, expect, it } from "vitest"

import { StudyMaterialCard } from "@/components/molecules/study-material-card"
import type { StudyItemPresentation } from "@/lib/study-materials-presentation"
import { renderWithProviders } from "@/testing/render"

function item(
	overrides: Partial<StudyItemPresentation> = {},
): StudyItemPresentation {
	return {
		id: "sm-1",
		variant: "owned",
		title: "FRM Exam Part I Books",
		programKey: "frm",
		codeLabel: "FRM",
		typeLabel: null,
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

describe("StudyMaterialCard — badges", () => {
	it("always chips the program code; status and type only when present", () => {
		renderWithProviders(<StudyMaterialCard item={item()} />)

		expect(screen.getByText("FRM")).toBeInTheDocument()
		expect(screen.queryByText("eBook")).not.toBeInTheDocument()
	})

	it("adds the status and type badges when the item carries them", () => {
		renderWithProviders(
			<StudyMaterialCard
				item={item({
					statusLabel: "Active",
					statusTone: "success",
					typeLabel: "eBook",
				})}
			/>,
		)

		expect(screen.getByText("Active")).toBeInTheDocument()
		expect(screen.getByText("eBook")).toBeInTheDocument()
	})

	it("needs BOTH status label and tone before it badges the status", () => {
		renderWithProviders(
			<StudyMaterialCard item={item({ statusLabel: "Active", statusTone: null })} />,
		)

		expect(screen.queryByText("Active")).not.toBeInTheDocument()
	})
})

describe("StudyMaterialCard — body copy", () => {
	it("joins the paragraphs into the clamped blurb", () => {
		renderWithProviders(
			<StudyMaterialCard
				item={item({ paragraphs: ["First sentence.", "Second sentence."] })}
			/>,
		)

		expect(
			screen.getByText("First sentence. Second sentence."),
		).toBeInTheDocument()
	})

	it("renders the artwork when a URL exists, and hides it on load failure", () => {
		renderWithProviders(
			<StudyMaterialCard
				item={item({ imageUrl: "https://hub.garp.org/frm-books.png" })}
				priority
			/>,
		)

		const art = document.querySelector("img") as HTMLImageElement
		expect(art).toHaveAttribute("src", "https://hub.garp.org/frm-books.png")
		expect(art).toHaveAttribute("loading", "eager")
		fireEvent.error(art)
		expect(art).not.toBeVisible()
	})
})

describe("StudyMaterialCard — footer actions", () => {
	it("renders primary and secondary CTAs when the item offers them", () => {
		renderWithProviders(
			<StudyMaterialCard
				item={item({
					primaryAction: {
						label: "Access",
						url: "https://learning.garp.org/frm",
						isExternal: true,
						newWindow: true,
					},
					secondaryAction: {
						label: "Need help?",
						url: "mailto:memberservices@garp.com",
						isExternal: true,
					},
				})}
			/>,
		)

		expect(screen.getByRole("link", { name: /Access/ })).toHaveAttribute(
			"href",
			"https://learning.garp.org/frm",
		)
		expect(screen.getByRole("link", { name: /Need help/ })).toHaveAttribute(
			"href",
			"mailto:memberservices@garp.com",
		)
	})

	it("renders no footer at all when the item has no actions", () => {
		renderWithProviders(<StudyMaterialCard item={item()} />)

		expect(screen.queryByRole("link")).not.toBeInTheDocument()
	})
})
