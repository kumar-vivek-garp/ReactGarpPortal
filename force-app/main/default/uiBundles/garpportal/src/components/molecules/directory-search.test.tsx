import { screen, waitFor } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { describe, expect, it } from "vitest"

import { DirectorySearch } from "@/components/molecules/directory-search"
import { renderWithRouterProviders } from "@/testing/router"

const searchBox = () =>
	screen.getByRole("textbox", { name: "Search the member directory" })

describe("handing the term to the directory", () => {
	it("navigates to /member-directory carrying the trimmed term", async () => {
		const user = userEvent.setup()
		const { router } = await renderWithRouterProviders(<DirectorySearch />, {
			path: "/dashboard",
		})

		await user.type(searchBox(), "  Ada Lovelace  ")
		await user.click(screen.getByRole("button", { name: "Search" }))

		await waitFor(() => {
			expect(router.state.location.pathname).toBe("/member-directory")
		})
		expect(router.state.location.search).toEqual({ q: "Ada Lovelace" })
	})

	it("goes with no term at all rather than an empty q", async () => {
		const user = userEvent.setup()
		const { router } = await renderWithRouterProviders(<DirectorySearch />, {
			path: "/dashboard",
		})

		await user.click(screen.getByRole("button", { name: "Search" }))

		await waitFor(() => {
			expect(router.state.location.pathname).toBe("/member-directory")
		})
		expect(router.state.location.search).toEqual({})
	})
})
