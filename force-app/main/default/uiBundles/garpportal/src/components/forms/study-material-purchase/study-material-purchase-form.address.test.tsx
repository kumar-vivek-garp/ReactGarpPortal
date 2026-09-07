import { screen, waitFor } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { describe, expect, it } from "vitest"

import {
	materialQuote,
	materialShipTo,
} from "@/testing/factories/study-material-purchase"
import { renderWithRouterProviders } from "@/testing/router"

import { StudyMaterialPurchaseForm } from "./study-material-purchase-form"

const mount = (quote = materialQuote()) =>
	renderWithRouterProviders(
		<StudyMaterialPurchaseForm productCode="SCRH" quote={quote} checkoutCancelled={false} />,
		{ path: "/study-materials/purchase/SCRH" },
	)

describe("StudyMaterialPurchaseForm — the shipping address", () => {
	it("is seeded from the member's record", async () => {
		await mount()
		expect(screen.getByLabelText(/Street address/)).toHaveValue("111 Main Street")
		expect(screen.getByLabelText(/City/)).toHaveValue("Jersey City")
		expect(screen.getByLabelText(/Postal code/)).toHaveValue("07302")
		expect(screen.getByRole("combobox", { name: /Country/ })).toHaveTextContent(
			"United States",
		)
		expect(screen.getByText(/We have filled in the address on your record/)).toBeInTheDocument()
	})

	it("holds Pay until street, city and country are all there", async () => {
		const user = userEvent.setup()
		await mount(materialQuote({ shipTo: materialShipTo({ street: null }) }))

		const pay = screen.getByRole("button", { name: /Continue to Payment/ })
		expect(pay).toBeDisabled()
		expect(
			screen.getByText("A street, city and country are needed to post a book."),
		).toBeInTheDocument()

		await user.type(screen.getByLabelText(/Street address/), "5 Harbour Road")

		await waitFor(() => expect(pay).toBeEnabled())
		expect(
			screen.queryByText("A street, city and country are needed to post a book."),
		).not.toBeInTheDocument()
	})

	it("flags a required field the member has emptied, inline", async () => {
		const user = userEvent.setup()
		await mount()

		await user.clear(screen.getByLabelText(/City/))
		await user.tab()

		expect(await screen.findByText("City is required.")).toBeInTheDocument()
		expect(screen.getByLabelText(/City/)).toHaveAttribute("aria-invalid", "true")
		expect(screen.getByRole("button", { name: /Continue to Payment/ })).toBeDisabled()
	})

	it("leaves the country unchosen when the record's is not one GARP posts to", async () => {
		await mount(materialQuote({ shipTo: materialShipTo({ country: "Atlantis" }) }))
		expect(screen.getByRole("combobox", { name: /Country/ })).toHaveTextContent(
			"Select country",
		)
		expect(screen.getByRole("button", { name: /Continue to Payment/ })).toBeDisabled()
	})

	it("falls back to free text when no shippable list came back", async () => {
		await mount(materialQuote({ shippableCountries: [] }))
		expect(screen.getByRole("textbox", { name: /Country/ })).toHaveValue("United States")
		expect(screen.queryByRole("combobox", { name: /Country/ })).not.toBeInTheDocument()
	})
})
