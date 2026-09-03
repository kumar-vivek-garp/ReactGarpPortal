import { screen } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { describe, expect, it, vi } from "vitest"

import { ConfirmEventRegistrationDialog } from "@/components/forms/event-registration/sections/confirm-event-registration-dialog"
import { renderWithProviders } from "@/testing/render"

function renderDialog(overrides: Partial<{ confirming: boolean }> = {}) {
	const onConfirm = vi.fn()
	const onCancel = vi.fn()
	renderWithProviders(
		<ConfirmEventRegistrationDialog
			open
			eventTitle="Risk Summit 2026"
			amountDue={250}
			confirming={overrides.confirming ?? false}
			onConfirm={onConfirm}
			onCancel={onCancel}
		/>,
	)
	return { onConfirm, onCancel }
}

describe("one more look at the money", () => {
	it("names the event and the amount before the unretryable write", () => {
		renderDialog()
		expect(
			screen.getByRole("dialog", { name: "Confirm your registration" }),
		).toBeInTheDocument()
		expect(screen.getByText("Risk Summit 2026")).toBeInTheDocument()
		expect(screen.getByText("$250.00")).toBeInTheDocument()
	})

	it("fires the mutation only from Confirm, and Back cancels", async () => {
		const user = userEvent.setup()
		const { onConfirm, onCancel } = renderDialog()

		await user.click(screen.getByRole("button", { name: "Back" }))
		expect(onCancel).toHaveBeenCalledTimes(1)
		expect(onConfirm).not.toHaveBeenCalled()

		await user.click(screen.getByRole("button", { name: "Confirm and Pay" }))
		expect(onConfirm).toHaveBeenCalledTimes(1)
	})

	it("treats dismissing the dialog as a cancel", async () => {
		const user = userEvent.setup()
		const { onCancel } = renderDialog()

		await user.keyboard("{Escape}")
		expect(onCancel).toHaveBeenCalledTimes(1)
	})

	it("locks both buttons and relabels while the hand-off is in flight", () => {
		renderDialog({ confirming: true })
		expect(
			screen.getByRole("button", { name: "Taking you to payment…" }),
		).toBeDisabled()
		expect(screen.getByRole("button", { name: "Back" })).toBeDisabled()
	})
})
