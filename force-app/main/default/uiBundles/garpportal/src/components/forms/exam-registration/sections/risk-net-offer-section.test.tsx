import { useForm, useWatch } from "react-hook-form"
import { screen } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { describe, expect, it } from "vitest"

import {
	EMPTY_EXAM_FORM_VALUES,
	type ExamFormValues,
} from "@/components/forms/exam-registration/exam-form-values"
import { RiskNetOfferSection } from "@/components/forms/exam-registration/sections/risk-net-offer-section"
import { renderWithProviders } from "@/testing/render"

/** Owns the react-hook-form instance the way the registration form does. */
/*
 * No default for `amount`/`months`: a destructuring default would turn the
 * "nothing priced" case into a priced one.
 */
function Harness({
	amount,
	months,
	disabled,
}: {
	amount?: number
	months?: number
	disabled?: boolean
}) {
	const form = useForm<ExamFormValues>({
		defaultValues: EMPTY_EXAM_FORM_VALUES,
	})
	const selected = useWatch({ control: form.control, name: "riskNetSelected" })

	return (
		<>
			<RiskNetOfferSection
				control={form.control}
				amount={amount}
				months={months}
				disabled={disabled}
			/>
			<output aria-label="observed">{String(selected)}</output>
		</>
	)
}

const observed = () => screen.getByLabelText("observed").textContent

describe("RiskNetOfferSection", () => {
	it("starts out of the cart and says what the click does", () => {
		renderWithProviders(<Harness amount={100} months={12} />)

		expect(
			screen.getByText(/Exclusive Offer for Members/),
		).toBeInTheDocument()
		const add = screen.getByRole("button", { name: /Add/ })
		expect(add).toHaveAttribute("aria-pressed", "false")
		expect(observed()).toBe("false")
	})

	it("Add ⇄ Remove writes the form value, never showing a passive 'Added'", async () => {
		const user = userEvent.setup()
		renderWithProviders(<Harness amount={100} months={12} />)

		await user.click(screen.getByRole("button", { name: /Add/ }))
		expect(observed()).toBe("true")
		const remove = screen.getByRole("button", { name: /Remove/ })
		expect(remove).toHaveAttribute("aria-pressed", "true")
		expect(screen.queryByText(/Added/)).not.toBeInTheDocument()

		await user.click(remove)
		expect(observed()).toBe("false")
		expect(screen.getByRole("button", { name: /Add/ })).toBeInTheDocument()
	})

	it("shows the server's price and the months it buys, and a dash without one", () => {
		const { unmount } = renderWithProviders(<Harness amount={200.4} months={24} />)
		expect(screen.getByText("$200.40")).toBeInTheDocument()
		expect(screen.getByText("for 24 months")).toBeInTheDocument()
		unmount()

		renderWithProviders(<Harness />)
		expect(screen.getByText("—")).toBeInTheDocument()
		expect(screen.queryByText(/for \d+ months/)).not.toBeInTheDocument()
	})

	it("links Risk.net's own privacy policy in a new tab", () => {
		renderWithProviders(<Harness amount={100} months={12} />)

		const link = screen.getByRole("link", { name: "privacy policy" })
		expect(link).toHaveAttribute(
			"href",
			"https://www.infopro-digital.com/privacy-policy/",
		)
		expect(link).toHaveAttribute("target", "_blank")
	})

	it("disabled freezes the cart control", () => {
		renderWithProviders(<Harness amount={100} months={12} disabled />)
		expect(screen.getByRole("button", { name: /Add/ })).toBeDisabled()
	})
})
