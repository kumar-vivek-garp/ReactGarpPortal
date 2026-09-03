import { screen } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { beforeEach, describe, expect, it, vi } from "vitest"

import { logoutToSalesforce } from "@/auth/logout"
import { SignOutButton } from "@/components/molecules/sign-out-button"
import { renderWithProviders } from "@/testing/render"

// vi.mock rather than MSW: logout is a window.location navigation, not an
// HTTP call — jsdom cannot perform it and there is no wire to intercept.
vi.mock("@/auth/logout", () => ({ logoutToSalesforce: vi.fn() }))

beforeEach(() => {
	vi.clearAllMocks()
})

describe("signing out", () => {
	it("hands off to Salesforce and locks itself while redirecting", async () => {
		const user = userEvent.setup()
		renderWithProviders(<SignOutButton />)

		await user.click(screen.getByRole("button", { name: "Sign Out" }))

		expect(logoutToSalesforce).toHaveBeenCalledTimes(1)
		const busy = screen.getByRole("button", { name: "Signing out…" })
		expect(busy).toBeDisabled()
		expect(busy).toHaveAttribute("aria-busy", "true")
	})

	it("cannot fire the redirect twice", async () => {
		const user = userEvent.setup()
		renderWithProviders(<SignOutButton />)

		const button = screen.getByRole("button", { name: "Sign Out" })
		await user.click(button)
		// The disabled state blocks the pointer; the guard covers programmatic fires.
		await user.click(screen.getByRole("button", { name: "Signing out…" }))

		expect(logoutToSalesforce).toHaveBeenCalledTimes(1)
	})
})
