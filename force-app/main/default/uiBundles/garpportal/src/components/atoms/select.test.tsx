import { screen } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { describe, expect, it } from "vitest"

import {
	Select,
	SelectContent,
	SelectGroup,
	SelectItem,
	SelectLabel,
	SelectSeparator,
	SelectTrigger,
	SelectValue,
} from "@/components/atoms/select"
import { renderWithProviders } from "@/testing/render"

function renderSelect(
	props: { defaultOpen?: boolean } = {},
	contentProps: { position?: "popper" | "item-aligned" } = {},
) {
	return renderWithProviders(
		<Select defaultValue="frm" {...props}>
			<SelectTrigger aria-label="Programme">
				<SelectValue />
			</SelectTrigger>
			<SelectContent {...contentProps}>
				<SelectGroup>
					<SelectLabel>Certifications</SelectLabel>
					<SelectItem value="frm">FRM</SelectItem>
					<SelectSeparator />
					<SelectItem value="scr">SCR</SelectItem>
				</SelectGroup>
			</SelectContent>
		</Select>,
	)
}

describe("Select", () => {
	it("shows the chosen value on its trigger", () => {
		renderSelect()
		expect(
			screen.getByRole("combobox", { name: "Programme" }),
		).toHaveTextContent("FRM")
	})

	it("opens with group label, items, and marks the selection", () => {
		renderSelect({ defaultOpen: true })

		expect(screen.getByRole("listbox")).toBeInTheDocument()
		expect(screen.getByText("Certifications")).toBeInTheDocument()
		expect(screen.getByRole("option", { name: "FRM" })).toHaveAttribute(
			"data-state",
			"checked",
		)
		expect(screen.getByRole("option", { name: "SCR" })).toHaveAttribute(
			"data-state",
			"unchecked",
		)
	})

	it("picking an option updates the trigger and closes the list", async () => {
		const user = userEvent.setup()
		renderSelect({ defaultOpen: true })

		await user.click(screen.getByRole("option", { name: "SCR" }))

		expect(screen.queryByRole("listbox")).not.toBeInTheDocument()
		expect(
			screen.getByRole("combobox", { name: "Programme" }),
		).toHaveTextContent("SCR")
	})

	it("supports the item-aligned position with its scroll buttons", () => {
		renderSelect({ defaultOpen: true }, { position: "item-aligned" })
		expect(screen.getByRole("listbox")).toBeInTheDocument()
		expect(screen.getByRole("option", { name: "FRM" })).toBeInTheDocument()
	})
})
