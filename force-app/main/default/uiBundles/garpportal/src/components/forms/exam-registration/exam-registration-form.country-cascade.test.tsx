import { screen, waitFor } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { describe, expect, it } from "vitest"

import { feesResult } from "@/testing/factories/exam"
import {
	chooseSelectOption,
	renderExamForm,
} from "@/testing/exam-registration-ui"
import { examregPost } from "@/testing/msw/handlers/examreg"
import { server } from "@/testing/msw/server"

/**
 * Changing the billing country has three coupled consequences — the address
 * card follows it, the province is cleared, and the payment method is
 * re-picked — and BOTH entry points (the Location select and the billing
 * card's own country select) must apply all three. Each of these shipped as a
 * bug once (`registration-forms.md` §6/§7).
 *
 * Fixture geography: the member is seeded in the United States (everything
 * allowed, province select); France forbids card and ACH; Germany forbids
 * card and wire.
 */
function armPricedFees() {
	const fees = examregPost("fees", () => feesResult(600))
	server.use(fees.handler)
	return fees
}

const paymentTile = (name: string | RegExp) => screen.getByRole("radio", { name })

describe("ExamRegistrationForm — billing country cascade", () => {
	it("re-picks a forbidden payment method when Location changes, and syncs the address card", async () => {
		armPricedFees()
		const user = userEvent.setup()
		await renderExamForm()

		// Card is allowed in the US; a card order shows no address card, so
		// Location stays the only country control on screen.
		await user.click(await screen.findByRole("radio", { name: "Card" }))
		expect(paymentTile("Card")).toBeChecked()
		expect(screen.queryByText("Billing & shipping")).not.toBeInTheDocument()
		expect(screen.getByRole("combobox", { name: "Location" })).toBeInTheDocument()

		await chooseSelectOption(user, "Location", "France")

		// France forbids card: the VALUE is re-picked, not just the tile's
		// rendering — wire is now genuinely selected.
		await waitFor(() => {
			expect(paymentTile(/Wire transfer/)).toBeChecked()
		})
		expect(paymentTile(/Card/)).not.toBeChecked()

		// Wire is offline, so the address card appears — already on France,
		// because Location and the billing country are the same fact.
		expect(
			await screen.findByRole("combobox", { name: "Country" }),
		).toHaveTextContent("France")
		// The old country's province did not survive the move.
		expect(screen.getByLabelText("State / Province")).toHaveValue("")
		// And Location hands over to the address card rather than asking twice.
		expect(
			screen.queryByRole("combobox", { name: "Location" }),
		).not.toBeInTheDocument()
	})

	it("applies the same cascade from the billing card's own country select", async () => {
		armPricedFees()
		const user = userEvent.setup()
		await renderExamForm()

		await user.click(await screen.findByRole("radio", { name: "Wire transfer" }))
		// The seeded US address renders with its province select on NJ.
		expect(
			await screen.findByRole("combobox", { name: "State / Province" }),
		).toHaveTextContent("NJ")
		expect(
			screen.queryByRole("combobox", { name: "Location" }),
		).not.toBeInTheDocument()

		await chooseSelectOption(user, "Country", "Germany")

		// Germany forbids wire: re-picked to ACH from THIS entry point too.
		await waitFor(() => {
			expect(paymentTile(/ACH/)).toBeChecked()
		})
		expect(paymentTile(/Wire transfer/)).not.toBeChecked()
		// Germany has no province list — the field is free text again, and the
		// US province was cleared rather than left to be submitted.
		expect(screen.getByLabelText("State / Province")).toHaveValue("")
	})

	it("keeps a payment method the new country still permits", async () => {
		armPricedFees()
		const user = userEvent.setup()
		await renderExamForm()

		await user.click(await screen.findByRole("radio", { name: "Wire transfer" }))
		await screen.findByText("Billing & shipping")

		// France permits wire — the choice survives the move.
		await chooseSelectOption(user, "Country", "France")

		await waitFor(() => {
			expect(
				screen.getByRole("combobox", { name: "Country" }),
			).toHaveTextContent("France")
		})
		expect(paymentTile(/Wire transfer/)).toBeChecked()
	})

	it("copies billing over shipping when 'same as billing' is re-ticked", async () => {
		armPricedFees()
		const user = userEvent.setup()
		await renderExamForm()

		await user.click(await screen.findByRole("radio", { name: "Wire transfer" }))
		await screen.findByText("Billing & shipping")

		// Unticking reveals the shipping block with its own values.
		const sameAsBilling = screen.getByRole("checkbox", {
			name: /shipping address is the same/,
		})
		await user.click(sameAsBilling)
		const shippingCity = await screen.findByLabelText(/City/, {
			selector: "#shipping-city",
		})
		await user.clear(shippingCity)
		await user.type(shippingCity, "Lyon")

		// Re-ticking copies billing over it — leaving stale values visible
		// behind read-only fields would misrepresent where the books go.
		await user.click(sameAsBilling)
		await user.click(sameAsBilling)
		expect(
			await screen.findByLabelText(/City/, { selector: "#shipping-city" }),
		).toHaveValue("Hoboken")
	})

	it("shows a forbidden method disabled with its reason rather than hiding it", async () => {
		armPricedFees()
		const user = userEvent.setup()
		await renderExamForm()

		await user.click(await screen.findByRole("radio", { name: "Wire transfer" }))
		await chooseSelectOption(user, "Country", "Germany")

		// The absent options are explained, not mysterious.
		const card = paymentTile(/Card/)
		const wire = paymentTile(/Wire transfer/)
		expect(card).toBeDisabled()
		expect(wire).toBeDisabled()
		expect(screen.getAllByText("Not available here")).toHaveLength(2)
	})
})
