import { screen } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { afterEach, describe, expect, it } from "vitest"

import { ThemeToggle } from "@/components/molecules/theme-toggle"
import { useThemeStore } from "@/store/theme-store"
import { renderWithProviders } from "@/testing/render"

afterEach(() => {
	useThemeStore.getState().setMode("light")
})

describe("flipping the appearance", () => {
	it("announces the mode it would switch TO, and flips the store", async () => {
		const user = userEvent.setup()
		useThemeStore.getState().setMode("light")
		renderWithProviders(<ThemeToggle />)

		const toggle = screen.getByRole("button", { name: "Switch to dark mode" })
		await user.click(toggle)

		expect(useThemeStore.getState().resolved).toBe("dark")
		expect(
			screen.getByRole("button", { name: "Switch to light mode" }),
		).toBeInTheDocument()

		await user.click(
			screen.getByRole("button", { name: "Switch to light mode" }),
		)
		expect(useThemeStore.getState().resolved).toBe("light")
	})

	it("keeps the document element in sync", async () => {
		const user = userEvent.setup()
		useThemeStore.getState().setMode("light")
		renderWithProviders(<ThemeToggle />)

		await user.click(screen.getByRole("button", { name: "Switch to dark mode" }))
		expect(document.documentElement.classList.contains("dark")).toBe(true)

		await user.click(
			screen.getByRole("button", { name: "Switch to light mode" }),
		)
		expect(document.documentElement.classList.contains("dark")).toBe(false)
	})
})
