import { screen } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { describe, expect, it } from "vitest"

import {
	Sheet,
	SheetClose,
	SheetContent,
	SheetDescription,
	SheetFooter,
	SheetHeader,
	SheetTitle,
	SheetTrigger,
} from "@/components/atoms/sheet"
import { renderWithProviders } from "@/testing/render"

describe("Sheet", () => {
	it("opens from its trigger and closes from the built-in close button", async () => {
		const user = userEvent.setup()
		renderWithProviders(
			<Sheet>
				<SheetTrigger>Open filters</SheetTrigger>
				<SheetContent>
					<SheetHeader>
						<SheetTitle>Filters</SheetTitle>
						<SheetDescription>Narrow the results.</SheetDescription>
					</SheetHeader>
					<SheetFooter>
						<SheetClose>Done</SheetClose>
					</SheetFooter>
				</SheetContent>
			</Sheet>,
		)

		expect(screen.queryByRole("dialog")).not.toBeInTheDocument()

		await user.click(screen.getByRole("button", { name: "Open filters" }))
		const dialog = screen.getByRole("dialog", { name: "Filters" })
		expect(dialog).toHaveTextContent("Narrow the results.")

		await user.click(screen.getByRole("button", { name: "Close" }))
		expect(screen.queryByRole("dialog")).not.toBeInTheDocument()
	})

	it("slides in from any of the four sides", () => {
		for (const side of ["right", "left", "top", "bottom"] as const) {
			const { unmount } = renderWithProviders(
				<Sheet defaultOpen>
					<SheetContent side={side}>
						<SheetTitle>{`From ${side}`}</SheetTitle>
					</SheetContent>
				</Sheet>,
			)
			expect(
				screen.getByRole("dialog", { name: `From ${side}` }),
			).toBeInTheDocument()
			unmount()
		}
	})

	it("can drop the built-in close button", () => {
		renderWithProviders(
			<Sheet defaultOpen>
				<SheetContent showCloseButton={false}>
					<SheetTitle>No escape hatch</SheetTitle>
				</SheetContent>
			</Sheet>,
		)
		expect(
			screen.queryByRole("button", { name: "Close" }),
		).not.toBeInTheDocument()
	})
})
