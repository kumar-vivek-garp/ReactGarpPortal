import { createFileRoute } from "@tanstack/react-router"
import { render, screen } from "@testing-library/react"
import { describe, expect, it } from "vitest"

import { renderFileRoute } from "@/testing/file-route"

import { ProgramsContentSkeleton, ProgramsPending } from "./programs-pending"

/**
 * The skeleton exists to hold the same geometry as the loaded page. These
 * assertions pin the contract with `ProgramCard` / `ProgramRow` and the grid /
 * list wrappers in `ProgramCollection`, so a future restyle of either side
 * cannot silently drift from the other.
 */
function frames(container: HTMLElement) {
	return container.querySelectorAll('[data-slot="skeleton-frame"]')
}

describe("ProgramsContentSkeleton — grid view", () => {
	it("uses the same wrapper geometry as ProgramCollection's grid", () => {
		const { container } = render(<ProgramsContentSkeleton view="grid" />)
		const wrapper = screen.getByLabelText("Loading programs")
		// Mirrors ProgramCollection: "grid gap-6 sm:grid-cols-2 lg:grid-cols-3".
		expect(wrapper).toHaveClass("grid", "gap-6", "sm:grid-cols-2", "lg:grid-cols-3")
		expect(wrapper).toHaveAttribute("aria-busy")
		expect(frames(container)).toHaveLength(6)
	})

	it("mirrors ProgramCard's regions in order", () => {
		const { container } = render(<ProgramsContentSkeleton view="grid" />)
		const card = frames(container)[0]

		// Card children: logo panel, header (chip row + title), content, footer.
		expect(card.children).toHaveLength(4)

		// Logo panel keeps ProgramCard's h-36 so cards do not jump on load.
		expect(card.children[0]).toHaveClass("h-36")

		// Header holds the code chip + status badge row, then the title.
		const chipRow = card.children[1].firstElementChild
		expect(chipRow?.children).toHaveLength(2)

		// Footer is pinned to the bottom exactly as the real CardFooter is.
		expect(card.children[3]).toHaveClass("mt-auto")
	})
})

describe("ProgramsContentSkeleton — list view", () => {
	it("uses the same wrapper geometry as ProgramCollection's list", () => {
		const { container } = render(<ProgramsContentSkeleton view="list" />)
		const wrapper = screen.getByLabelText("Loading programs")
		// Mirrors ProgramCollection: "flex flex-col gap-3".
		expect(wrapper).toHaveClass("flex", "flex-col", "gap-3")
		expect(frames(container)).toHaveLength(3)
	})

	it("mirrors ProgramRow's horizontal layout", () => {
		const { container } = render(<ProgramsContentSkeleton view="list" />)
		const row = frames(container)[0]
		// ProgramRow stacks on mobile and goes horizontal from `sm`.
		expect(row).toHaveClass("flex-col", "sm:flex-row", "sm:items-center")
		// Logo thumb, content column, CTA column.
		expect(row.children).toHaveLength(3)
		expect(row.children[0]).toHaveClass("h-16", "sm:w-24")
	})
})

describe("ProgramsContentSkeleton — default", () => {
	it("defaults to the grid layout", () => {
		render(<ProgramsContentSkeleton />)
		expect(screen.getByLabelText("Loading programs")).toHaveClass("grid")
	})
})

describe("ProgramsPending — route wrapper", () => {
	it("reads the destination view so the skeleton matches what lands", async () => {
		const ROUTE_ID = "/_appLayout/programs/"
		const route = createFileRoute(ROUTE_ID)({
			validateSearch: (search: Record<string, unknown>) => search,
			component: ProgramsPending,
		})
		await renderFileRoute(route, {
			id: ROUTE_ID,
			path: "/programs/",
			initialEntries: ["/programs/?view=list"],
		})

		expect(
			screen.getByRole("heading", { level: 1, name: "My Programs" }),
		).toBeInTheDocument()
		expect(screen.getByLabelText("Loading programs")).toHaveClass(
			"flex",
			"flex-col",
			"gap-3",
		)
	})
})
