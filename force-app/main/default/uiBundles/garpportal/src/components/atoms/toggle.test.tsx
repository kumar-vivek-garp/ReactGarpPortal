import { screen } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { describe, expect, it } from "vitest"

import { Toggle } from "@/components/atoms/toggle"
import { renderWithProviders } from "@/testing/render"

describe("Toggle", () => {
	it("presses and releases", async () => {
		const user = userEvent.setup()
		renderWithProviders(<Toggle>Bold</Toggle>)

		const toggle = screen.getByRole("button", { name: "Bold" })
		expect(toggle).toHaveAttribute("aria-pressed", "false")

		await user.click(toggle)
		expect(toggle).toHaveAttribute("aria-pressed", "true")
	})

	it("renders every variant and size without losing its role", () => {
		renderWithProviders(
			<>
				<Toggle variant="outline" size="sm">
					Small
				</Toggle>
				<Toggle size="lg" defaultPressed>
					Large
				</Toggle>
			</>,
		)

		expect(screen.getByRole("button", { name: "Small" })).toBeInTheDocument()
		expect(screen.getByRole("button", { name: "Large" })).toHaveAttribute(
			"aria-pressed",
			"true",
		)
	})
})
