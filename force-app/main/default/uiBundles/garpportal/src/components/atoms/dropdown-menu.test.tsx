import { fireEvent, screen } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { describe, expect, it, vi } from "vitest"

import {
	DropdownMenu,
	DropdownMenuCheckboxItem,
	DropdownMenuContent,
	DropdownMenuGroup,
	DropdownMenuItem,
	DropdownMenuLabel,
	DropdownMenuPortal,
	DropdownMenuRadioGroup,
	DropdownMenuRadioItem,
	DropdownMenuSeparator,
	DropdownMenuShortcut,
	DropdownMenuSub,
	DropdownMenuSubContent,
	DropdownMenuSubTrigger,
	DropdownMenuTrigger,
} from "@/components/atoms/dropdown-menu"
import { renderWithProviders } from "@/testing/render"

function renderMenu(onSelectProfile = vi.fn()) {
	renderWithProviders(
		<DropdownMenu defaultOpen>
			<DropdownMenuTrigger>Account</DropdownMenuTrigger>
			<DropdownMenuPortal>
				<DropdownMenuContent>
					<DropdownMenuLabel inset>Signed in as Grace</DropdownMenuLabel>
					<DropdownMenuGroup>
						<DropdownMenuItem onSelect={onSelectProfile}>
							Profile
							<DropdownMenuShortcut>⇧P</DropdownMenuShortcut>
						</DropdownMenuItem>
						<DropdownMenuCheckboxItem checked>
							Email updates
						</DropdownMenuCheckboxItem>
					</DropdownMenuGroup>
					<DropdownMenuSeparator />
					<DropdownMenuRadioGroup value="light">
						<DropdownMenuRadioItem value="light">Light</DropdownMenuRadioItem>
						<DropdownMenuRadioItem value="dark">Dark</DropdownMenuRadioItem>
					</DropdownMenuRadioGroup>
					<DropdownMenuSub defaultOpen>
						<DropdownMenuSubTrigger inset>More</DropdownMenuSubTrigger>
						<DropdownMenuSubContent>
							<DropdownMenuItem variant="destructive">
								Sign out
							</DropdownMenuItem>
						</DropdownMenuSubContent>
					</DropdownMenuSub>
				</DropdownMenuContent>
			</DropdownMenuPortal>
		</DropdownMenu>,
	)
	return onSelectProfile
}

describe("DropdownMenu", () => {
	it("renders every part of a fully-loaded open menu", () => {
		renderMenu()

		expect(screen.getByText("Signed in as Grace")).toBeInTheDocument()
		expect(
			screen.getByRole("menuitem", { name: /Profile/ }),
		).toBeInTheDocument()
		expect(
			screen.getByRole("menuitemcheckbox", { name: "Email updates" }),
		).toBeChecked()
		expect(
			screen.getByRole("menuitemradio", { name: "Light" }),
		).toBeChecked()
		expect(
			screen.getByRole("menuitemradio", { name: "Dark" }),
		).not.toBeChecked()
	})

	it("opens the submenu from its trigger and shows the destructive item", async () => {
		renderMenu()

		const more = screen.getByRole("menuitem", { name: "More" })
		fireEvent.keyDown(more, { key: "ArrowRight" })

		const signOut = await screen.findByRole("menuitem", { name: "Sign out" })
		expect(signOut).toHaveAttribute("data-variant", "destructive")
	})

	it("selecting an item fires and closes the menu", async () => {
		const user = userEvent.setup()
		const onSelect = renderMenu()

		await user.click(screen.getByRole("menuitem", { name: /Profile/ }))
		expect(onSelect).toHaveBeenCalledTimes(1)
		expect(screen.queryByRole("menu")).not.toBeInTheDocument()
	})

	it("opens from its trigger", async () => {
		const user = userEvent.setup()
		renderWithProviders(
			<DropdownMenu>
				<DropdownMenuTrigger>Options</DropdownMenuTrigger>
				<DropdownMenuContent>
					<DropdownMenuItem>Only entry</DropdownMenuItem>
				</DropdownMenuContent>
			</DropdownMenu>,
		)

		expect(screen.queryByRole("menu")).not.toBeInTheDocument()
		await user.click(screen.getByRole("button", { name: "Options" }))
		expect(
			screen.getByRole("menuitem", { name: "Only entry" }),
		).toBeInTheDocument()
	})
})
