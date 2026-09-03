import { render, screen } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { describe, expect, it, vi } from "vitest"

import { AccountFieldList, type AccountFieldRow } from "./account-field-list"

describe("AccountFieldList", () => {
	it("renders label/value rows and drops empty non-addable ones", () => {
		render(
			<AccountFieldList
				rows={[
					{ label: "Member since", value: "2020" },
					{ label: "Chapter", value: undefined },
				]}
			/>,
		)

		expect(screen.getByText("Member since")).toBeInTheDocument()
		expect(screen.getByText("2020")).toBeInTheDocument()
		expect(screen.queryByText("Chapter")).not.toBeInTheDocument()
	})

	it("falls back to the empty message when no row survives", () => {
		render(
			<AccountFieldList
				rows={[{ label: "Chapter", value: "" }]}
				emptyMessage="No membership details yet."
			/>,
		)

		expect(screen.getByText("No membership details yet.")).toBeInTheDocument()
	})

	it("offers Add for an addable empty row and hands back the row", async () => {
		const user = userEvent.setup()
		const onAdd = vi.fn()
		const row: AccountFieldRow = { label: "Chapter", value: null, addable: true }
		render(<AccountFieldList rows={[row]} onAdd={onAdd} />)

		await user.click(screen.getByRole("button", { name: "Add Chapter" }))

		expect(onAdd).toHaveBeenCalledWith(row)
	})
})
