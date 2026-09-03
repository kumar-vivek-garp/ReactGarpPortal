import { render, screen } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { describe, expect, it, vi } from "vitest"

import { AccountFieldGrid, type AccountFieldGridRow } from "./account-field-grid"

describe("AccountFieldGrid", () => {
	it("shows filled rows and hides empty non-addable ones", () => {
		render(
			<AccountFieldGrid
				rows={[
					{ label: "Email", value: "ada@example.com" },
					{ label: "Phone", value: "" },
				]}
			/>,
		)

		expect(screen.getByText("Email")).toBeInTheDocument()
		expect(screen.getByText("ada@example.com")).toBeInTheDocument()
		expect(screen.queryByText("Phone")).not.toBeInTheDocument()
	})

	it("falls back to the empty message when nothing is showable", () => {
		render(
			<AccountFieldGrid
				rows={[{ label: "Phone", value: null }]}
				emptyMessage="No contact details yet."
			/>,
		)

		expect(screen.getByText("No contact details yet.")).toBeInTheDocument()
	})

	it("keeps an addable empty row as an Add prompt wired to onAdd", async () => {
		const user = userEvent.setup()
		const onAdd = vi.fn()
		const row: AccountFieldGridRow = {
			label: "Phone",
			value: null,
			addable: true,
		}
		render(<AccountFieldGrid rows={[row]} onAdd={onAdd} />)

		await user.click(screen.getByRole("button", { name: "Add Phone" }))

		expect(onAdd).toHaveBeenCalledWith(row)
	})

	it("hides an addable empty row when no onAdd handler exists", () => {
		// An Add button that opens nothing is a dead end — the row must vanish
		// rather than dangle.
		render(
			<AccountFieldGrid
				rows={[{ label: "Phone", value: null, addable: true }]}
				emptyMessage="Nothing here."
			/>,
		)

		expect(screen.queryByRole("button", { name: /Add/ })).not.toBeInTheDocument()
		expect(screen.getByText("Nothing here.")).toBeInTheDocument()
	})
})
