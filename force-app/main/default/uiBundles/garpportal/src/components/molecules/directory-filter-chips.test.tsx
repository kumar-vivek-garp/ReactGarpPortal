import { render, screen } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { describe, expect, it, vi } from "vitest"

import {
	EMPTY_DIRECTORY_FILTERS,
	type DirectoryFilterState,
} from "@/components/molecules/directory-filters-dialog"

import { activeFilterChips, DirectoryFilterChips } from "./directory-filter-chips"

function filters(overrides: Partial<DirectoryFilterState> = {}): DirectoryFilterState {
	return {
		...EMPTY_DIRECTORY_FILTERS,
		...overrides,
		values: { ...EMPTY_DIRECTORY_FILTERS.values, ...overrides.values },
	}
}

describe("activeFilterChips — one chip per filter in effect", () => {
	it("removing the company chip clears only the company", () => {
		const state = filters({ company: "  Acme Bank  ", certifications: ["FRM"] })
		const chip = activeFilterChips(state).find((entry) => entry.id === "company")

		expect(chip?.label).toBe("Company: Acme Bank")
		expect(chip?.remove(state)).toEqual(
			filters({ company: "", certifications: ["FRM"] }),
		)
	})

	it("removing a certification chip leaves the others standing", () => {
		const state = filters({ certifications: ["FRM", "SCR"] })
		const chip = activeFilterChips(state).find(
			(entry) => entry.id === "cert-FRM",
		)

		expect(chip?.remove(state)).toEqual(filters({ certifications: ["SCR"] }))
	})

	it("removing a picklist value chip clears only that value", () => {
		const state = filters({
			values: {
				...EMPTY_DIRECTORY_FILTERS.values,
				industries: ["Banking", "Insurance"],
			},
		})
		const chip = activeFilterChips(state).find(
			(entry) => entry.id === "industries-Banking",
		)

		expect(chip?.label).toBe("Banking")
		expect(chip?.remove(state)).toEqual(
			filters({
				values: { ...EMPTY_DIRECTORY_FILTERS.values, industries: ["Insurance"] },
			}),
		)
	})

	it("reports nothing for the empty state", () => {
		expect(activeFilterChips(EMPTY_DIRECTORY_FILTERS)).toEqual([])
	})
})

describe("DirectoryFilterChips", () => {
	it("renders nothing at all with no active filters", () => {
		const { container } = render(
			<DirectoryFilterChips
				state={EMPTY_DIRECTORY_FILTERS}
				onChange={vi.fn()}
				onClearAll={vi.fn()}
			/>,
		)

		expect(container).toBeEmptyDOMElement()
	})

	it("clicking a chip hands back the state without that filter", async () => {
		const user = userEvent.setup()
		const onChange = vi.fn()
		render(
			<DirectoryFilterChips
				state={filters({ company: "Acme" })}
				onChange={onChange}
				onClearAll={vi.fn()}
			/>,
		)

		await user.click(
			screen.getByRole("button", { name: /Company: Acme/ }),
		)

		expect(onChange).toHaveBeenCalledWith(filters({ company: "" }))
	})

	it("offers Clear all only once there is more than one chip", async () => {
		const user = userEvent.setup()
		const onClearAll = vi.fn()
		const { rerender } = render(
			<DirectoryFilterChips
				state={filters({ company: "Acme" })}
				onChange={vi.fn()}
				onClearAll={onClearAll}
			/>,
		)
		expect(
			screen.queryByRole("button", { name: "Clear all" }),
		).not.toBeInTheDocument()

		rerender(
			<DirectoryFilterChips
				state={filters({ company: "Acme", certifications: ["FRM"] })}
				onChange={vi.fn()}
				onClearAll={onClearAll}
			/>,
		)
		await user.click(screen.getByRole("button", { name: "Clear all" }))

		expect(onClearAll).toHaveBeenCalled()
	})
})
