import { render, screen } from "@testing-library/react"
import { describe, expect, it } from "vitest"

import { StudyMaterialsContentSkeleton } from "./study-materials-pending"

/**
 * Pins the skeleton↔component contract: the wrappers must match the geometry
 * `StudyItemCollection` renders, so the layout does not jump when data lands.
 */
function frames(container: HTMLElement) {
	return container.querySelectorAll('[data-slot="skeleton-frame"]')
}

describe("StudyMaterialsContentSkeleton — grid", () => {
	it("matches StudyItemCollection's grid wrapper", () => {
		const { container } = render(<StudyMaterialsContentSkeleton view="grid" />)
		const wrapper = screen.getByLabelText("Loading study materials")
		expect(wrapper).toHaveClass("grid", "gap-6", "sm:grid-cols-2", "lg:grid-cols-3")
		expect(wrapper).toHaveAttribute("aria-busy")
		expect(frames(container)).toHaveLength(6)
	})

	it("mirrors StudyMaterialCard's regions", () => {
		const { container } = render(<StudyMaterialsContentSkeleton view="grid" />)
		const card = frames(container)[0]
		// Artwork panel, header (chips + title), content, footer.
		expect(card.children).toHaveLength(4)
		// Same h-36 artwork panel as the real card, so cards do not resize on load.
		expect(card.children[0]).toHaveClass("h-36")
		expect(card.children[3]).toHaveClass("mt-auto")
	})
})

describe("StudyMaterialsContentSkeleton — list", () => {
	it("matches StudyItemCollection's list wrapper", () => {
		const { container } = render(<StudyMaterialsContentSkeleton view="list" />)
		const wrapper = screen.getByLabelText("Loading study materials")
		expect(wrapper).toHaveClass("flex", "flex-col", "gap-3")
		expect(frames(container)).toHaveLength(4)
	})

	it("mirrors StudyMaterialRow's horizontal layout", () => {
		const { container } = render(<StudyMaterialsContentSkeleton view="list" />)
		const row = frames(container)[0]
		expect(row).toHaveClass("flex-col", "sm:flex-row", "sm:items-center")
		expect(row.children).toHaveLength(3)
		expect(row.children[0]).toHaveClass("h-16", "sm:w-24")
	})
})

describe("StudyMaterialsContentSkeleton — default", () => {
	it("defaults to grid, matching the page default", () => {
		render(<StudyMaterialsContentSkeleton />)
		expect(screen.getByLabelText("Loading study materials")).toHaveClass("grid")
	})
})
