import { screen } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { BookUser, Car } from "lucide-react"
import { describe, expect, it, vi } from "vitest"

import { TileRadioGroup } from "@/components/molecules/tile-radio-group"
import { renderWithProviders } from "@/testing/render"

const OPTIONS = [
	{ value: "passport", label: "Passport", icon: BookUser },
	{ value: "driver license", label: "Driver's License", icon: Car },
]

describe("TileRadioGroup", () => {
	it("is a labelled radiogroup of radios, with the chosen one checked", () => {
		renderWithProviders(
			<TileRadioGroup
				id="id-type"
				legend="ID type"
				value="passport"
				options={OPTIONS}
				onChange={() => undefined}
			/>,
		)

		expect(screen.getByRole("radiogroup", { name: "ID type" })).toBeInTheDocument()
		expect(screen.getByRole("radio", { name: "Passport" })).toBeChecked()
		expect(screen.getByRole("radio", { name: "Driver's License" })).not.toBeChecked()
	})

	it("reports a click as the option's value", async () => {
		const user = userEvent.setup()
		const onChange = vi.fn()
		renderWithProviders(
			<TileRadioGroup
				id="id-type"
				legend="ID type"
				value=""
				options={OPTIONS}
				onChange={onChange}
			/>,
		)

		await user.click(screen.getByRole("radio", { name: "Driver's License" }))
		expect(onChange).toHaveBeenCalledWith("driver license")
	})

	it("shows the error under the tiles and marks the group invalid", () => {
		renderWithProviders(
			<TileRadioGroup
				id="id-type"
				legend="ID type"
				value=""
				options={OPTIONS}
				onChange={() => undefined}
				error="ID Type is required."
			/>,
		)

		expect(screen.getByRole("alert")).toHaveTextContent("ID Type is required.")
		expect(screen.getByRole("radiogroup")).toHaveAttribute("aria-invalid", "true")
	})

	it("does nothing while disabled", async () => {
		const user = userEvent.setup()
		const onChange = vi.fn()
		renderWithProviders(
			<TileRadioGroup
				id="id-type"
				legend="ID type"
				value=""
				options={OPTIONS}
				onChange={onChange}
				disabled
			/>,
		)

		await user.click(screen.getByRole("radio", { name: "Passport" }))
		expect(onChange).not.toHaveBeenCalled()
	})
})
