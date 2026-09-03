import { screen } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { describe, expect, it, vi } from "vitest"

import {
	InputGroup,
	InputGroupAddon,
	InputGroupButton,
	InputGroupInput,
	InputGroupText,
	InputGroupTextarea,
} from "@/components/atoms/input-group"
import { renderWithProviders } from "@/testing/render"

describe("InputGroup", () => {
	it("clicking an addon hands focus to the input it decorates", async () => {
		const user = userEvent.setup()
		renderWithProviders(
			<InputGroup>
				<InputGroupAddon aria-label="Currency">
					<InputGroupText>USD</InputGroupText>
				</InputGroupAddon>
				<InputGroupInput aria-label="Amount" />
			</InputGroup>,
		)

		await user.click(screen.getByText("USD"))
		expect(screen.getByRole("textbox", { name: "Amount" })).toHaveFocus()
	})

	it("a button inside the addon keeps the click to itself", async () => {
		const user = userEvent.setup()
		const onClear = vi.fn()
		renderWithProviders(
			<InputGroup>
				<InputGroupInput aria-label="Search" />
				<InputGroupAddon align="inline-end" aria-label="Actions">
					<InputGroupButton size="icon-sm" onClick={onClear}>
						Clear
					</InputGroupButton>
				</InputGroupAddon>
			</InputGroup>,
		)

		await user.click(screen.getByRole("button", { name: "Clear" }))
		expect(onClear).toHaveBeenCalledTimes(1)
		expect(screen.getByRole("textbox", { name: "Search" })).not.toHaveFocus()
	})

	it("hosts a textarea with block-aligned addons", async () => {
		const user = userEvent.setup()
		renderWithProviders(
			<InputGroup>
				<InputGroupAddon align="block-start" aria-label="Header">
					<InputGroupText>Notes</InputGroupText>
				</InputGroupAddon>
				<InputGroupTextarea aria-label="Description" />
				<InputGroupAddon align="block-end" aria-label="Footer">
					<InputGroupText>Max 500 characters</InputGroupText>
				</InputGroupAddon>
			</InputGroup>,
		)

		const textarea = screen.getByRole("textbox", { name: "Description" })
		await user.type(textarea, "Some risk notes")
		expect(textarea).toHaveValue("Some risk notes")
		expect(screen.getByText("Max 500 characters")).toBeInTheDocument()
	})
})
